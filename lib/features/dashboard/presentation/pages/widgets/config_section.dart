import 'package:flutter/material.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glass_effect.dart';

/// A configurable section widget with a title and child widgets
/// Used to group related configuration options together with a consistent look and feel

class ConfigSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool expanded;

  const ConfigSection({
    super.key,
    required this.title,
    required this.children,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      opacity: 0.5,
      blur: 0,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.only(bottom: 8, top: 8, left: 12, right: 12),
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ...children,
        ],
      ),
    );
  }
}
