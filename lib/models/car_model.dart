import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class CarModel {
  final String id;
  final String brand;
  final String model;
  final String variant;
  final int year;
  final String fuelType;
  final String plateNumber;
  final int currentKm;
  final int lastServiceKm;
  final String color;
  final String insuranceExpiry;

  const CarModel({
    required this.id,
    required this.brand,
    required this.model,
    required this.variant,
    required this.year,
    required this.fuelType,
    required this.plateNumber,
    required this.currentKm,
    required this.lastServiceKm,
    required this.color,
    required this.insuranceExpiry,
  });

  int get odometerGap => currentKm - lastServiceKm;
  double get healthPercent => (1 - (odometerGap / 10000)).clamp(0.0, 1.0);
  bool get isServiceDue => odometerGap >= 10000;

  String get healthStatus {
    if (healthPercent > 0.6) return 'Good';
    if (healthPercent > 0.3) return 'Fair';
    return 'Service Due';
  }

  Color get healthColor {
    if (healthPercent > 0.6) return AppColors.success;
    if (healthPercent > 0.3) return AppColors.warning;
    return AppColors.error;
  }

  String get brandEmoji => getBrandEmoji(brand);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'variant': variant,
      'year': year,
      'fuelType': fuelType,
      'plateNumber': plateNumber,
      'currentKm': currentKm,
      'lastServiceKm': lastServiceKm,
      'color': color,
      'insuranceExpiry': insuranceExpiry,
    };
  }

  factory CarModel.fromMap(Map<String, dynamic> map, String id) {
    return CarModel(
      id: id,
      brand: map['brand'] ?? '',
      model: map['model'] ?? '',
      variant: map['variant'] ?? '',
      year: map['year'] ?? 2020,
      fuelType: map['fuelType'] ?? 'Petrol',
      plateNumber: map['plateNumber'] ?? '',
      currentKm: map['currentKm'] ?? 0,
      lastServiceKm: map['lastServiceKm'] ?? 0,
      color: map['color'] ?? 'White',
      insuranceExpiry: map['insuranceExpiry'] ?? '2026-12-31',
    );
  }
}