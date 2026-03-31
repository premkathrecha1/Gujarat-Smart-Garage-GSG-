// File: lib/admin/services/admin_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_model.dart';
import '../../models/car_model.dart';
import '../../models/work_post.dart';
import '../models/admin_model.dart';

class AdminService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Admin Authentication
  static Future<bool> adminLogin(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        // Check if user is admin
        final adminDoc = await _firestore
            .collection('admins')
            .doc(userCredential.user!.uid)
            .get();
        
        if (adminDoc.exists) {
          // Update last login
          await _firestore.collection('admins').doc(userCredential.user!.uid).update({
            'lastLogin': FieldValue.serverTimestamp(),
          });
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Admin login error: $e');
      return false;
    }
  }

  // Get all users
  static Stream<List<UserModel>> getAllUsers() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Get all cars
  static Stream<List<CarModel>> getAllCars() {
    return _firestore
        .collection('cars')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CarModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Get all work posts
  static Stream<List<WorkPost>> getAllWorkPosts() {
    return _firestore
        .collection('workPosts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return WorkPost.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Get all garages
  static Stream<List<Map<String, dynamic>>> getAllGarages() {
    return _firestore
        .collection('garages')
        .orderBy('rating', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();
    });
  }

  // Get all bookings
  static Stream<List<Map<String, dynamic>>> getAllBookings() {
    return _firestore
        .collection('bookings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();
    });
  }

  // Delete user
  static Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      // Also delete user's cars
      final cars = await _firestore
          .collection('cars')
          .where('userId', isEqualTo: userId)
          .get();
      for (var car in cars.docs) {
        await car.reference.delete();
      }
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }

  // Delete car
  static Future<void> deleteCar(String carId) async {
    try {
      await _firestore.collection('cars').doc(carId).delete();
    } catch (e) {
      print('Error deleting car: $e');
      rethrow;
    }
  }

  // Delete work post
  static Future<void> deleteWorkPost(String postId) async {
    try {
      await _firestore.collection('workPosts').doc(postId).delete();
    } catch (e) {
      print('Error deleting work post: $e');
      rethrow;
    }
  }

  // Update user status (block/unblock)
  static Future<void> updateUserStatus(String userId, bool isActive) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating user status: $e');
      rethrow;
    }
  }

  // Get statistics
  static Future<Map<String, dynamic>> getStats() async {
    try {
      final usersCount = await _firestore.collection('users').count().get();
      final carsCount = await _firestore.collection('cars').count().get();
      final workPostsCount = await _firestore.collection('workPosts').count().get();
      final bookingsCount = await _firestore.collection('bookings').count().get();
      final garagesCount = await _firestore.collection('garages').count().get();

      // Get recent activity (last 7 days)
      final sevenDaysAgo = DateTime.now().subtract(Duration(days: 7));
      final recentUsers = await _firestore
          .collection('users')
          .where('createdAt', isGreaterThan: sevenDaysAgo)
          .count()
          .get();
      
      final recentBookings = await _firestore
          .collection('bookings')
          .where('createdAt', isGreaterThan: sevenDaysAgo)
          .count()
          .get();

      return {
        'totalUsers': usersCount.count,
        'totalCars': carsCount.count,
        'totalWorkPosts': workPostsCount.count,
        'totalBookings': bookingsCount.count,
        'totalGarages': garagesCount.count,
        'newUsersThisWeek': recentUsers.count,
        'newBookingsThisWeek': recentBookings.count,
      };
    } catch (e) {
      print('Error getting stats: $e');
      return {
        'totalUsers': 0,
        'totalCars': 0,
        'totalWorkPosts': 0,
        'totalBookings': 0,
        'totalGarages': 0,
        'newUsersThisWeek': 0,
        'newBookingsThisWeek': 0,
      };
    }
  }

  // Create admin user (only for setup)
  static Future<void> createAdminUser({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      // Create auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        // Save admin data
        await _firestore.collection('admins').doc(userCredential.user!.uid).set({
          'id': userCredential.user!.uid,
          'email': email,
          'name': name,
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
          'isActive': true,
        });
      }
    } catch (e) {
      print('Error creating admin: $e');
      rethrow;
    }
  }
}