import 'package:flutter/material.dart';
import 'package:niagara_smart_drip_irrigation/core/theme/app_themes.dart';

class AppStyles {
  AppStyles._();

  /// Common card style with bottom shadow only
  static BoxDecoration cardDecoration = BoxDecoration(
    color: AppThemes.appWhiteColor,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color:AppThemes.shadowBlackColor,
        blurRadius: 8,
        offset: const Offset(0, 6),
      ),
    ],
  );

  /// Common padding
  static const EdgeInsets screenPadding =
  EdgeInsets.symmetric(horizontal: 16, vertical: 12);
}
