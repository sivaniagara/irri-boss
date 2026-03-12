import 'package:flutter/material.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/no_data.dart';

import '../../domain/entities/moisture_entities.dart';
import '../widgets/moisture_status_card.dart';

class MoistureZoneStatusView extends StatelessWidget {
  final MoistureDataEntity data;

  const MoistureZoneStatusView({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    if (data.mostList.isEmpty) {
      return noDataNew;
    }

    return Column(
      children: [
        if (data.ctrlDate.isNotEmpty && data.ctrlTime.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.sync, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  "Last Sync: ${data.ctrlDate} ${data.ctrlTime}",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            itemCount: data.mostList.length,
            itemBuilder: (context, index) {
              final item = data.mostList[index];
              return MoistureValveCard(
                index: index,
                entity: item,
              );
            },
          ),
        ),
      ],
    );
  }
}
