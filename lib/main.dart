// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/app_state.dart';
import 'screens/splash_screen.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase ready');
  } catch (e) {
    debugPrint('⚠️ Firebase init error: $e — running in offline/demo mode');
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(const SmartGarageApp());
}

class SmartGarageApp extends StatefulWidget {
  const SmartGarageApp({super.key});

  @override
  State<SmartGarageApp> createState() => _SmartGarageAppState();
}

class _SmartGarageAppState extends State<SmartGarageApp> {
  // Single AppState instance for the lifetime of the app
  final AppState _appState = AppState();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Garage Gujarat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      // SplashScreen handles session restore + navigation decision
      home: SplashScreen(appState: _appState),
    );
  }
}