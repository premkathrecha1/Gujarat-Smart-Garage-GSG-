// lib/services/firebase_service.dart
// Complete Firebase backend — Auth + Firestore for all collections
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/car_model.dart';
import '../models/work_post.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ═══════════════════════════════════════════════════════
  //  AUTH
  // ═══════════════════════════════════════════════════════

  static User? get currentUser => _auth.currentUser;
  static String? get currentUid => _auth.currentUser?.uid;

  /// Register a new user → saves profile to Firestore users collection
  static Future<UserModel> registerUser({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
    String? garageName,
    String? city,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cred.user!.updateDisplayName(name);

      final user = UserModel(
        id: cred.user!.uid,
        name: name,
        email: email,
        phone: phone,
        role: role,
        garageName: garageName,
        city: city,
      );

      await _db.collection('users').doc(cred.user!.uid).set({
        ...user.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      return user;
    } on FirebaseAuthException catch (e) {
      throw _authError(e);
    }
  }

  /// Sign in → fetch user profile from Firestore
  static Future<UserModel> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final doc = await _db.collection('users').doc(cred.user!.uid).get();
      if (!doc.exists) throw 'User profile not found. Please re-register.';

      // Update last login timestamp
      await doc.reference.update({'lastLogin': FieldValue.serverTimestamp()});

      return UserModel.fromMap(doc.data()!, doc.id);
    } on FirebaseAuthException catch (e) {
      throw _authError(e);
    }
  }

  static Future<void> signOut() => _auth.signOut();

  /// Restore session on app restart — returns null if not logged in
  static Future<UserModel?> restoreSession() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    try {
      final doc =
          await _db.collection('users').doc(firebaseUser.uid).get();
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!, doc.id);
    } catch (_) {
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════
  //  USERS
  // ═══════════════════════════════════════════════════════

  static Future<UserModel?> getUserById(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, doc.id);
  }

  static Stream<List<UserModel>> streamAllUsers() {
    return _db
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map((d) => UserModel.fromMap(d.data(), d.id))
            .toList());
  }

  static Future<void> deleteUser(String uid) async {
    // Cascade: delete user's cars and work posts
    final carSnap =
        await _db.collection('cars').where('userId', isEqualTo: uid).get();
    for (final d in carSnap.docs) {
      await d.reference.delete();
    }
    final postSnap = await _db
        .collection('workPosts')
        .where('garageId', isEqualTo: uid)
        .get();
    for (final d in postSnap.docs) {
      await d.reference.delete();
    }
    await _db.collection('users').doc(uid).delete();
  }

  static Future<void> toggleUserActive(String uid, bool isActive) async {
    await _db.collection('users').doc(uid).update({'isActive': isActive});
  }

  // ═══════════════════════════════════════════════════════
  //  CARS
  // ═══════════════════════════════════════════════════════

  /// Add a new car — writes to Firestore, returns the car with Firestore doc id
  static Future<CarModel> addCar({
    required String userId,
    required CarModel car,
  }) async {
    final ref = _db.collection('cars').doc();
    final carWithId = CarModel(
      id: ref.id,
      brand: car.brand,
      model: car.model,
      variant: car.variant,
      year: car.year,
      fuelType: car.fuelType,
      plateNumber: car.plateNumber,
      currentKm: car.currentKm,
      lastServiceKm: car.lastServiceKm,
      color: car.color,
      insuranceExpiry: car.insuranceExpiry,
    );
    await ref.set({
      ...carWithId.toMap(),
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return carWithId;
  }

  /// Real-time stream of a user's cars — persists across restarts
  static Stream<List<CarModel>> streamUserCars(String userId) {
    return _db
        .collection('cars')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => CarModel.fromMap(d.data(), d.id)).toList());
  }

  static Future<void> updateCar(String carId, Map<String, dynamic> data) async {
    await _db.collection('cars').doc(carId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> deleteCar(String carId) async {
    await _db.collection('cars').doc(carId).delete();
  }

  /// All cars — for admin panel
  static Stream<List<CarModel>> streamAllCars() {
    return _db
        .collection('cars')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => CarModel.fromMap(d.data(), d.id)).toList());
  }

  // ═══════════════════════════════════════════════════════
  //  WORK POSTS
  // ═══════════════════════════════════════════════════════

  /// Post a new work job from garage owner
  static Future<WorkPost> addWorkPost({
    required String garageId,
    required String garageName,
    required WorkPost post,
  }) async {
    final ref = _db.collection('workPosts').doc();
    final postWithId = WorkPost(
      id: ref.id,
      title: post.title,
      vehicle: post.vehicle,
      postedBy: garageName,
      garageId: garageId,
      distanceKm: post.distanceKm,
      amount: post.amount,
      time: post.time,
      category: post.category,
      location: post.location,
      notes: post.notes,
    );
    await ref.set({
      ...postWithId.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return postWithId;
  }

  /// Stream ALL open (not accepted) work posts — for the public Work Board
  static Stream<List<WorkPost>> streamOpenWorkPosts() {
    return _db
        .collection('workPosts')
        .where('isAccepted', isEqualTo: false)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => WorkPost.fromMap(d.data(), d.id)).toList());
  }

  /// Stream a specific garage's own posts
  static Stream<List<WorkPost>> streamMyWorkPosts(String garageId) {
    return _db
        .collection('workPosts')
        .where('garageId', isEqualTo: garageId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => WorkPost.fromMap(d.data(), d.id)).toList());
  }

  /// Accept a work post (another garage takes the job)
  static Future<void> acceptWorkPost({
    required String postId,
    required String acceptedByGarageId,
    required String acceptedByName,
  }) async {
    await _db.collection('workPosts').doc(postId).update({
      'isAccepted': true,
      'acceptedBy': acceptedByGarageId,
      'acceptedByName': acceptedByName,
      'acceptedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Soft-delete a work post (garage owner deletes their own post)
  static Future<void> deleteWorkPost(String postId) async {
    await _db.collection('workPosts').doc(postId).update({
      'isDeleted': true,
      'deletedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Admin hard-delete
  static Future<void> hardDeleteWorkPost(String postId) async {
    await _db.collection('workPosts').doc(postId).delete();
  }

  /// All work posts — for admin panel (including deleted)
  static Stream<List<WorkPost>> streamAllWorkPosts() {
    return _db
        .collection('workPosts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => WorkPost.fromMap(d.data(), d.id)).toList());
  }

  // ═══════════════════════════════════════════════════════
  //  ADMIN STATS
  // ═══════════════════════════════════════════════════════

  static Future<Map<String, int>> getAdminStats() async {
    final results = await Future.wait([
      _db.collection('users').count().get(),
      _db
          .collection('users')
          .where('role', isEqualTo: 0)
          .count()
          .get(),
      _db
          .collection('users')
          .where('role', isEqualTo: 1)
          .count()
          .get(),
      _db.collection('cars').count().get(),
      _db.collection('workPosts').count().get(),
      _db
          .collection('workPosts')
          .where('isAccepted', isEqualTo: true)
          .count()
          .get(),
    ]);
    return {
      'totalUsers': results[0].count ?? 0,
      'carOwners': results[1].count ?? 0,
      'garageOwners': results[2].count ?? 0,
      'totalCars': results[3].count ?? 0,
      'totalWorkPosts': results[4].count ?? 0,
      'acceptedPosts': results[5].count ?? 0,
    };
  }

  // ═══════════════════════════════════════════════════════
  //  HELPERS
  // ═══════════════════════════════════════════════════════

  static String _authError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      default:
        return e.message ?? 'Authentication failed. Try again.';
    }
  }
}