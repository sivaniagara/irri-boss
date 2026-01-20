import 'package:flutter/material.dart';
import 'package:niagara_smart_drip_irrigation/core/theme/app_themes.dart';

class ControllerInfoRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;

  const ControllerInfoRow({
    super.key,
    required this.label,
    this.value,
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              valueWidget ??
                  Text(
                    value ?? "-",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppThemes.primaryColor),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}


