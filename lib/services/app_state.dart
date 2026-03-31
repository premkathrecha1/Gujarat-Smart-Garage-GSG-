// lib/services/app_state.dart
// Firebase-backed AppState:
//   • Session restore on app restart via FirebaseAuth.currentUser
//   • Real-time Firestore streams for cars and work posts
//   • All mutations go to Firestore first, then reflect locally
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/car_model.dart';
import '../models/work_post.dart';
import 'firebase_service.dart';

class AppState extends ChangeNotifier {
  // ── State ────────────────────────────────────────────────────────────────────
  UserModel? _user;
  List<CarModel> _cars = [];
  List<WorkPost> _workPosts = [];
  bool _isGujarati = false;
  bool _isLoading = false;
  String? _error;

  StreamSubscription<List<CarModel>>? _carSub;
  StreamSubscription<List<WorkPost>>? _workSub;

  // ── Getters ──────────────────────────────────────────────────────────────────
  UserModel? get user => _user;
  List<CarModel> get cars => List.unmodifiable(_cars);
  List<WorkPost> get workPosts => List.unmodifiable(_workPosts);
  bool get isGujarati => _isGujarati;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isCarOwner => _user?.role == UserRole.carOwner;
  bool get isGarageOwner => _user?.role == UserRole.garageOwner;

  // ── Session restore (called from SplashScreen) ───────────────────────────────
  /// Tries to re-authenticate from FirebaseAuth persisted session.
  /// Returns true if a valid session was found.
  Future<bool> tryRestoreSession() async {
    _setLoading(true);
    try {
      final user = await FirebaseService.restoreSession();
      if (user != null) {
        await _setUser(user);
        return true;
      }
    } catch (e) {
      debugPrint('Session restore failed: $e');
    } finally {
      _setLoading(false);
    }
    return false;
  }

  // ── Login / Register ─────────────────────────────────────────────────────────
  Future<void> loginWithFirebase({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      final user = await FirebaseService.loginUser(
        email: email,
        password: password,
      );
      await _setUser(user);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> registerWithFirebase({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
    String? garageName,
    String? city,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      final user = await FirebaseService.registerUser(
        email: email,
        password: password,
        name: name,
        phone: phone,
        role: role,
        garageName: garageName,
        city: city,
      );
      await _setUser(user);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Quick/demo login without Firebase — still supported for testing
  void manualLogin(UserModel user) {
    if (_user?.id == user.id) return; // idempotent guard
    _user = user;
    _cancelStreams();
    if (user.isCarOwner) {
      _cars = [];
      _workPosts = [];
    } else {
      _cars = [];
      _workPosts = [];
    }
    notifyListeners();
  }

  // ── Set user and start streams ────────────────────────────────────────────────
  Future<void> _setUser(UserModel user) async {
    _cancelStreams();
    _user = user;
    _cars = [];
    _workPosts = [];
    notifyListeners(); // show dashboard immediately, data streams in after

    if (user.isCarOwner) {
      _carSub = FirebaseService.streamUserCars(user.id).listen(
        (cars) {
          _cars = cars;
          notifyListeners();
        },
        onError: (e) => debugPrint('Car stream error: $e'),
      );
    } else if (user.isGarageOwner) {
      _workSub = FirebaseService.streamMyWorkPosts(user.id).listen(
        (posts) {
          _workPosts = posts;
          notifyListeners();
        },
        onError: (e) => debugPrint('Work post stream error: $e'),
      );
    }
  }

  // ── Cars ─────────────────────────────────────────────────────────────────────
  Future<void> addCarToFirebase(CarModel car) async {
    if (_user == null) return;
    _setLoading(true);
    try {
      final saved = await FirebaseService.addCar(userId: _user!.id, car: car);
      // Stream will update _cars automatically; add optimistically for instant UI
      _cars = [..._cars, saved];
      notifyListeners();
    } catch (e) {
      _error = 'Failed to save car: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteCarFromFirebase(String carId) async {
    _cars = _cars.where((c) => c.id != carId).toList();
    notifyListeners();
    await FirebaseService.deleteCar(carId);
  }

  // Keep for demo mode (no Firebase)
  void addCar(CarModel car) {
    _cars = [..._cars, car];
    notifyListeners();
  }

  // ── Work Posts ───────────────────────────────────────────────────────────────
  Future<WorkPost?> postWorkToFirebase(WorkPost post) async {
    if (_user == null) return null;
    _setLoading(true);
    try {
      final saved = await FirebaseService.addWorkPost(
        garageId: _user!.id,
        garageName: _user!.garageName ?? _user!.name,
        post: post,
      );
      // Optimistic update
      _workPosts = [saved, ..._workPosts];
      notifyListeners();
      return saved;
    } catch (e) {
      _error = 'Failed to post work: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteWorkPostFromFirebase(String postId) async {
    // Optimistic remove from local list
    _workPosts = _workPosts.where((p) => p.id != postId).toList();
    notifyListeners();
    await FirebaseService.deleteWorkPost(postId);
  }

  Future<void> acceptWorkInFirebase(String postId) async {
    if (_user == null) return;
    await FirebaseService.acceptWorkPost(
      postId: postId,
      acceptedByGarageId: _user!.id,
      acceptedByName: _user!.garageName ?? _user!.name,
    );
    // Local optimistic update
    _workPosts = _workPosts.map((w) {
      if (w.id == postId) {
        return w.copyWith(
          isAccepted: true,
          acceptedBy: _user!.id,
          acceptedByName: _user!.garageName ?? _user!.name,
        );
      }
      return w;
    }).toList();
    notifyListeners();
  }

  // Keep for demo mode
  void acceptWork(String id) {
    _workPosts = _workPosts.map((w) {
      if (w.id == id) return w.copyWith(isAccepted: true);
      return w;
    }).toList();
    notifyListeners();
  }

  // ── Logout ───────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    _cancelStreams();
    await FirebaseService.signOut();
    _user = null;
    _cars = [];
    _workPosts = [];
    _error = null;
    notifyListeners();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────
  void _cancelStreams() {
    _carSub?.cancel();
    _workSub?.cancel();
    _carSub = null;
    _workSub = null;
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void toggleLang() {
    _isGujarati = !_isGujarati;
    notifyListeners();
  }

  String t(String en, String gu) => _isGujarati ? gu : en;
  String getUserName() => _user?.name ?? 'User';
  String getGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
  String getWelcomeName() =>
      '${getGreeting()}, ${getUserName().split(' ').first}! 🙏';
  int getCarCount() => _cars.length;
  int getServiceDueCount() => _cars.where((c) => c.isServiceDue).length;
  bool hasServiceAlert() => _cars.any((c) => c.isServiceDue);
  double getAverageRating() => 4.8;

  Map<String, dynamic> getGarageStats() {
    if (!isGarageOwner) return {};
    final accepted = _workPosts.where((p) => p.isAccepted && !p.isDeleted).length;
    final pending = _workPosts.where((p) => !p.isAccepted && !p.isDeleted).length;
    return {
      'totalJobs': _workPosts.where((p) => !p.isDeleted).length,
      'acceptedJobs': accepted,
      'pendingJobs': pending,
      'revenue': accepted * 1500,
    };
  }

  @override
  void dispose() {
    _cancelStreams();
    super.dispose();
  }
}