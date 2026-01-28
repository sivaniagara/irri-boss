import 'package:flutter/material.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_switch.dart';

class StandaloneHeader extends StatelessWidget {
  final bool isOn;
  final String title;
  final ValueChanged<bool> onChanged;
  final VoidCallback onSend;

  const StandaloneHeader({
    super.key,
    required this.isOn,
    required this.title,
    required this.onChanged,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xffB4E7FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.touch_app, color: Theme.of(context).colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
          CustomSwitch(
            value: isOn,
            onChanged: (v) => onChanged(v as bool),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onSend,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.send_rounded, color: Theme.of(context).colorScheme.primary, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
