import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:niagara_smart_drip_irrigation/features/settings/presentation/pages/settings_page.dart';


class SettingsRoutes {
  static const String settings = "/settings";
}

final settingsGoRoutes = [
  GoRoute(
    path: SettingsRoutes.settings,
    builder: (context, state) => SettingsPage(),
  ),
];