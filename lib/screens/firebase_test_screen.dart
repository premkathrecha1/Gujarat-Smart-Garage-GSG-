// File: lib/screens/firebase_test_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_garage_gujarat/screens/login_screen.dart';
import 'package:smart_garage_gujarat/services/app_state.dart';
import '../services/firebase_service.dart';
import '../models/user_model.dart';

class FirebaseTestScreen extends StatefulWidget {
  @override
  _FirebaseTestScreenState createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  String _status = "Testing Firebase...";
  bool _isLoading = true;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _testFirebase();
  }

  Future<void> _testFirebase() async {
    String status = "";
    
    // Test 1: Check Firebase Initialization
    try {
      final auth = FirebaseAuth.instance;
      status += "✅ Firebase Auth initialized\n";
    } catch (e) {
      status += "❌ Firebase Auth Error: $e\n";
    }
    
    // Test 2: Check Firestore Connection
    try {
      final testDoc = await FirebaseFirestore.instance
          .collection('users')
          .limit(1)
          .get();
      status += "✅ Firestore Connected: Found ${testDoc.docs.length} users\n";
      _isConnected = true;
    } catch (e) {
      status += "❌ Firestore Error: $e\n";
      _isConnected = false;
    }
    
    // Test 3: Check Current User
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      status += "✅ Current user: ${currentUser.email}\n";
    } else {
      status += "ℹ️ No user logged in\n";
    }
    
    setState(() {
      _status = status;
      _isLoading = false;
    });
  }

  Future<void> _createTestUser() async {
    setState(() => _isLoading = true);
    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: 'test@example.com',
        password: 'test123456',
      );
      
      if (userCredential.user != null) {
        // Save user data to Firestore
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'id': userCredential.user!.uid,
          'name': 'Test User',
          'email': 'test@example.com',
          'phone': '+919876543210',
          'role': 0, // Car owner
          'city': 'Ahmedabad',
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        setState(() {
          _status = "✅ Test user created successfully!\nEmail: test@example.com\nPassword: test123456\n\n$_status";
        });
      }
    } catch (e) {
      setState(() {
        _status = "❌ Failed to create test user: $e\n\n$_status";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Connection Test'),
        backgroundColor: _isConnected ? Colors.green : Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _status,
                    style: TextStyle(fontSize: 14, fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            if (_isLoading)
              CircularProgressIndicator()
            else
              Column(
                children: [
                  if (!_isConnected)
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.warning, color: Colors.orange),
                            SizedBox(height: 8),
                            Text(
                              'Firestore connection failed!\nMake sure you have created the database in Firebase Console.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.orange.shade900),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: _createTestUser,
                    child: Text('Create Test User'),
                  ),
                  SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => LoginScreen(appState: AppState())),
                      );
                    },
                    child: Text('Go to Login Screen'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}