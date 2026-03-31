import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  static const primary       = Color(0xFF1565C0); // Deep Blue
  static const primaryLight  = Color(0xFF1976D2); // Medium Blue
  static const primaryDark   = Color(0xFF0D47A1); // Dark Blue
  static const accent        = Color(0xFF2196F3); // Bright Blue
  static const accentLight   = Color(0xFFE3F2FD); // Very Light Blue
  static const surface       = Color(0xFFFFFFFF); // White
  static const background    = Color(0xFFF5F8FF); // Off-white blue tint
  static const cardBg        = Color(0xFFFFFFFF);
  static const borderColor   = Color(0xFFE0EEFF);
  static const textPrimary   = Color(0xFF0A1628);
  static const textSecondary = Color(0xFF5A7BA8);
  static const textHint      = Color(0xFF9CB3CC);
  static const success       = Color(0xFF2E7D32);
  static const successLight  = Color(0xFFE8F5E9);
  static const warning       = Color(0xFFF57C00);
  static const warningLight  = Color(0xFFFFF3E0);
  static const error         = Color(0xFFC62828);
  static const errorLight    = Color(0xFFFFEBEE);
  static const divider       = Color(0xFFEAF1FF);
  static const shimmer1      = Color(0xFFEEF4FF);
  static const shimmer2      = Color(0xFFDDE8FF);
  static const gradient1     = Color(0xFF1565C0);
  static const gradient2     = Color(0xFF42A5F5);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Poppins',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: false,
      //SystemUiOverlayStyle.dark
      systemOverlayStyle: SystemUiOverlayStyle.dark
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.accentLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
      ),
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}

class AppConstants {
  static const List<String> carBrands = [
    'Maruti Suzuki', 'Tata', 'Hyundai', 'Honda', 'Toyota',
    'Mahindra', 'Kia', 'MG Motor', 'Renault', 'Volkswagen',
    'Skoda', 'Ford', 'Nissan', 'Jeep', 'BMW', 'Mercedes-Benz',
  ];

  static const Map<String, List<String>> carModels = {
    'Maruti Suzuki': ['Swift', 'Baleno', 'Dzire', 'Ertiga', 'Brezza', 'Ciaz', 'Alto', 'WagonR', 'Celerio', 'Ignis', 'XL6', 'Grand Vitara'],
    'Tata': ['Nexon', 'Punch', 'Harrier', 'Safari', 'Altroz', 'Tiago', 'Tigor', 'Nexon EV', 'Punch EV', 'Curvv'],
    'Hyundai': ['Creta', 'Venue', 'i20', 'i10', 'Aura', 'Verna', 'Alcazar', 'Tucson', 'Ioniq 5'],
    'Honda': ['City', 'Amaze', 'Jazz', 'WRV', 'Elevate', 'CR-V'],
    'Toyota': ['Fortuner', 'Innova', 'Hyryder', 'Glanza', 'Camry', 'Vellfire'],
    'Mahindra': ['Thar', 'Scorpio', 'XUV700', 'XUV300', 'BE6e', 'XEV9e', 'Bolero'],
    'Kia': ['Seltos', 'Sonet', 'Carens', 'EV6'],
    'MG Motor': ['Hector', 'ZS EV', 'Astor', 'Gloster', 'Comet EV'],
    'Renault': ['Kwid', 'Triber', 'Kiger'],
    'Volkswagen': ['Polo', 'Vento', 'Taigun', 'Virtus'],
    'Skoda': ['Rapid', 'Octavia', 'Kushaq', 'Slavia', 'Kodiaq'],
    'Ford': ['EcoSport', 'Endeavour', 'Figo'],
    'Nissan': ['Magnite', 'Kicks'],
    'Jeep': ['Compass', 'Meridian', 'Wrangler'],
    'BMW': ['3 Series', '5 Series', 'X1', 'X3', 'X5', 'X7'],
    'Mercedes-Benz': ['A-Class', 'C-Class', 'E-Class', 'GLA', 'GLC', 'GLE'],
  };

  static const List<String> fuelTypes = ['Petrol', 'Diesel', 'Electric', 'CNG', 'Hybrid'];
  static const List<String> gujaratCities = [
    'Ahmedabad', 'Surat', 'Vadodara', 'Rajkot', 'Bhavnagar',
    'Gandhinagar', 'Junagadh', 'Jamnagar', 'Anand', 'Nadiad',
    'Mehsana', 'Morbi', 'Surendranagar', 'Bharuch',
  ];

  static List<int> get years {
    final now = DateTime.now().year;
    return List.generate(now - 1999, (i) => now - i);
  }
}