import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF5B67F1);
  static const Color secondary = Color(0xFF8A7CFF);
  static const Color background = Color(0xFFF7F8FC);
  static const Color card = Color(0xFFFFFFFF);
  static const Color accent = Color(0xFFE8EBFF);
  static const Color textPrimary = Color(0xFF1B1D28);
  static const Color textSecondary = Color(0xFF6E7385);
  
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
