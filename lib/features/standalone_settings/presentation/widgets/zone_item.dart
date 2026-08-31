import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_switch.dart';
import '../../domain/entities/standalone_entity.dart';
import '../bloc/standalone_bloc.dart';

class ZoneItem extends StatelessWidget {
  final int index;
  final ZoneEntity zone;

  const ZoneItem({
    super.key,
    required this.index,
    required this.zone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "BLOCK ${zone.zoneNumber.padLeft(3, '0')}",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                "Irrigation Block",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
          ),
          CustomSwitch(
            value: zone.status,
            onChanged: (v) {
              context.read<StandaloneBloc>().add(ToggleZone(index, v as bool));
            },
          ),
        ],
      ),
    );
  }
}
