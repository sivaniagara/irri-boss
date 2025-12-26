import 'package:flutter/material.dart';
import 'package:niagara_smart_drip_irrigation/core/theme/app_themes.dart';

/// A card widget that displays a configuration setting with a label and value
///
/// This widget supports both regular text display and toggle switches
/// for boolean values, with consistent styling throughout the app

class InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final bool isBoolean;
  final bool? booleanValue;

  const InfoCard({
    super.key,
    required this.label,
    required this.value,
    this.isBoolean = false,
    this.booleanValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (isBoolean || booleanValue != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: Switch(
                    value: booleanValue ?? value == "1",
                    onChanged: (newValue) {},
                  ),
                ),
            ],
          ),
          if (!isBoolean)
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppThemes.primaryColor,
              ),
            ),
        ],
      ),
    );
  }
}
