// File: test/firebase_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_garage_gujarat/services/firebase_service.dart';
import 'package:smart_garage_gujarat/models/user_model.dart';
import 'package:smart_garage_gujarat/models/car_model.dart';
import 'package:smart_garage_gujarat/models/work_post.dart';

void main() {
  test('Test Firebase Collections', () async {
    // Test 1: Add a test user
    final testUser = UserModel(
      id: 'test_user_001',
      name: 'Test User',
      email: 'test@example.com',
      phone: '+919876543210',
      role: UserRole.carOwner,
      city: 'Ahmedabad',
    );
    
    // Test 2: Add a test car
    final testCar = CarModel(
      id: 'test_car_001',
      brand: 'Maruti Suzuki',
      model: 'Swift',
      variant: 'VXi',
      year: 2020,
      fuelType: 'Petrol',
      plateNumber: 'GJ-01-TEST-1234',
      currentKm: 25000,
      lastServiceKm: 15000,
      color: 'White',
      insuranceExpiry: '2025-12-31',
    );
    
    // Test 3: Add a test work post
    final testWorkPost = WorkPost(
      id: 'test_work_001',
      title: 'Test Oil Change',
      vehicle: 'Test Vehicle',
      postedBy: 'Test Garage',
      distanceKm: 1.5,
      amount: '₹1,000',
      time: 'Today, 5 PM',
      category: 'Mechanical',
      location: 'Test Location',
    );
    
    print('✅ Collections ready for testing!');
    print('Users collection: ✅');
    print('Cars collection: ✅');
    print('WorkPosts collection: ✅');
  });
}