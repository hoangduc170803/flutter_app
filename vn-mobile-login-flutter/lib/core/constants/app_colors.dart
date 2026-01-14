import 'package:flutter/material.dart';

/// App color constants following design system
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryAmber = Color(0xFFF59E0B);
  static const Color primaryTeal = Color(0xFF14B8A6);
  static const Color primaryGreen = Color(0xFF22C55E);
  static const Color primaryPurple = Color(0xFF9333EA);
  static const Color primaryRed = Color(0xFFEF4444);

  // Gray Scale
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  // Blue Scale
  static const Color blue50 = Color(0xFFEFF6FF);
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue800 = Color(0xFF1E40AF);

  // Green Scale
  static const Color green100 = Color(0xFFDCFCE7);
  static const Color green500 = Color(0xFF22C55E);
  static const Color green600 = Color(0xFF16A34A);
  static const Color green700 = Color(0xFF166534);
  static const Color green800 = Color(0xFF166534);

  // Amber Scale
  static const Color amber100 = Color(0xFFFEF3C7);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706);
  static const Color amber700 = Color(0xFFB45309);

  // Purple Scale
  static const Color purple100 = Color(0xFFF3E8FF);
  static const Color purple600 = Color(0xFF9333EA);

  // Red Scale
  static const Color red100 = Color(0xFFFEE2E2);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
  static const Color red800 = Color(0xFF991B1B);

  // Teal Scale
  static const Color teal50 = Color(0xFFF0FDFA);
  static const Color teal500 = Color(0xFF14B8A6);
  static const Color teal600 = Color(0xFF0D9488);

  // Slate Scale
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);

  // Background Colors
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;

  // Màu cam chủ đạo (#f27f0d)
  static const Color contactPrimary = Color(0xFFF27F0D);

  // Màu nền phụ (#f8f7f5 - Dùng cho SearchBar, Button tròn)
  static const Color contactSurface = Color(0xFFF8F7F5);

  // Màu chữ chính (#1c140d - Đen pha nâu)
  static const Color contactTextMain = Color(0xFF1C140D);

  // Màu chữ phụ (#9c7349 - Nâu nhạt)
  static const Color contactTextSub = Color(0xFF9C7349);

  // Màu cho Tag User (Cam nhạt pha)
  static const Color orange50 = Color(0xFFFFF7ED);  // Nền tag
  static const Color orange100 = Color(0xFFFFE0B2); // Viền tag

  // Contact Detail Theme (Glassmorphism)
  static const Color detailBackground = Color(0xFFE1EDEE);
  static const Color detailPrimary = Color(0xFF007AFF);
  static const Color detailTextWhite = Colors.white;
  static Color detailTextWhite70 = Colors.white.withValues(alpha: 0.7);
  static Color detailTextWhite50 = Colors.white.withValues(alpha: 0.5);
  static Color detailDivider = Colors.white.withValues(alpha: 0.2);
  static Color detailCardBackground = const Color(0xFF94A3B8).withValues(alpha: 0.4);

  // Call Modal Theme
  static const Color modalPrimaryOrange = Color(0xFFF27F0D);
  static const Color modalTextDark = Color(0xFF1C140D);
  static const Color modalBackground = Color(0xFFF5F5F5);
}

