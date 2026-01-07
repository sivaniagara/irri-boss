import 'package:flutter/foundation.dart';

enum Flavor { irriBossDevelopment, irriBossProduction }

class FlavorValues {
  final String displayName;
  final String apiBaseUrl;
  final String broker;
  final String userName;
  final String password;
  final String themeKey;
  final bool showFlavorBanner;

  const FlavorValues({
    required this.displayName,
    required this.apiBaseUrl,
    required this.broker,
    required this.userName,
    required this.password,
    required this.themeKey,
    this.showFlavorBanner = false,
  });
}

class FlavorConfig {
  final Flavor flavor;
  final FlavorValues values;
  static late FlavorConfig _instance;

  FlavorConfig._internal({required this.flavor, required this.values}) {
    _instance = this;
  }

  /// Returns the active instance. Throws a helpful StateError if not initialized.
  static FlavorConfig get instance {
    try {
      return _instance;
    } catch (e) {
      throw StateError(
          'FlavorConfig is not initialized. Call FlavorConfig.setup(...) before accessing FlavorConfig.instance.');
    }
  }

  /// Call from per-flavor entrypoint (recommended).
  static void setup(Flavor flavor, {FlavorValues? overrideValues}) {
    final values = overrideValues ?? _defaultValuesFor(flavor);
    FlavorConfig._internal(flavor: flavor, values: values);
    if (kDebugMode) {
      debugPrint('FlavorConfig.setup -> ${values.displayName}, theme=${values.themeKey}');
    }
  }

  /// Optional: single-entrypoint alternative to read --dart-define=FLAVOR=niagara|agritel
  /// Useful for CI or single-entry setups where native differences are not required.
  static void setupFromDartDefine() {
    const raw = String.fromEnvironment('FLAVOR', defaultValue: '');
    final f = _fromString(raw) ?? Flavor.irriBossDevelopment;
    setup(f);
  }

  static FlavorValues _defaultValuesFor(Flavor flavor) {
    switch (flavor) {
      case Flavor.irriBossDevelopment:
        return const FlavorValues(
          displayName: 'Niagara',
          apiBaseUrl: "http://3.1.62.165:8080/api/v1/",
          broker: "3.0.229.165",
          userName: "niagara",
          password: "niagara@123",
          themeKey: 'niagara',
          showFlavorBanner: true,
        );
      case Flavor.irriBossProduction:
        return const FlavorValues(
          displayName: 'AgriTel',
          apiBaseUrl: 'https://api.example.com',
          broker: 'https://api.example.com',
          userName: 'https://api.example.com',
          password: 'https://api.example.com',
          themeKey: 'agritel',
          showFlavorBanner: true,
        );
    }
  }

  static Flavor? _fromString(String raw) {
    final s = raw.trim().toLowerCase();
    if (s.isEmpty) return null;
    if (s == 'Development') return Flavor.irriBossDevelopment;
    if (s == 'Production') return Flavor.irriBossProduction;
    return null;
  }

  // bool get isNiagara => flavor == Flavor.irriBossDevelopment;
  // bool get isAgritel => flavor == Flavor.irriBossProduction;

  @override
  String toString() => 'FlavorConfig(flavor: $flavor, theme: ${values.themeKey})';
}