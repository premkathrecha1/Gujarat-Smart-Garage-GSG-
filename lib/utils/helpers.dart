import 'package:flutter/material.dart';
import 'constants.dart';

void showSnackBar(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? AppColors.error : AppColors.success,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ),
  );
}

String formatNumber(int number) {
  return number.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]},'
  );
}

String getBrandEmoji(String brand) {
  switch (brand.toLowerCase()) {
    case 'maruti suzuki': return '🚗';
    case 'tata': return '🚙';
    case 'hyundai': return '🚘';
    case 'honda': return '🏎';
    case 'toyota': return '🚐';
    case 'mahindra': return '🚕';
    case 'kia': return '🛻';
    case 'bmw': return '🏎';
    case 'mercedes-benz': return '🏎';
    default: return '🚗';
  }
}