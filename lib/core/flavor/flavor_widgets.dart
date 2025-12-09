import 'package:flutter/material.dart';
import 'flavor_config.dart';

/// Small helper: shows a banner for the active flavor (useful for QA/dev)
class FlavorBanner extends StatelessWidget {
  final Widget child;
  final TextStyle? textStyle;

  const FlavorBanner({
    super.key,
    required this.child,
    this.textStyle,
  });

  Color _bannerColor() {
    final f = FlavorConfig.instance.flavor;
    switch (f) {
      case Flavor.niagara:
        return Colors.indigo;
      case Flavor.agritel:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext dialogContext) {
    final cfg = FlavorConfig.instance;
    if (!cfg.values.showFlavorBanner) return child;

    return Banner(
      message: cfg.values.displayName,
      location: BannerLocation.topEnd,
      color: _bannerColor(),
      textStyle: textStyle ??
          const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
      child: child,
    );
  }
}

/// Builder that exposes FlavorConfig to builder callbacks.
class FlavorAwareBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, FlavorConfig flavorConfig) builder;
  const FlavorAwareBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext dialogContext) => builder(dialogContext, FlavorConfig.instance);
}