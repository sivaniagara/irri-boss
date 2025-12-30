import 'package:flutter/material.dart';
import 'package:niagara_smart_drip_irrigation/core/theme/app_themes.dart';

class AppGradients {
  AppGradients._();

  static const LinearGradient commonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppThemes.gradientTopColor,
      AppThemes.gradientMidColor,
      AppThemes.gradientBottomColor,
    ],
  );


}