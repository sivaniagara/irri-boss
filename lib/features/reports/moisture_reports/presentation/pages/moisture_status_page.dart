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
      return noData;
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: data.mostList.length,
      itemBuilder: (context, index) {
        final item = data.mostList[index];
        return MoistureValveCard(
          index: index,
          entity: item,
        );
      },
    );
  }
}

