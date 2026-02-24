import 'package:flutter/material.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/no_data.dart';

import '../../../zone_duration_reports/presentation/widgets/summary_card.dart';
import '../../domain/entities/fertilizer_entities.dart';
import '../widgets/fertilizer_card.dart';
import '../widgets/summary_card.dart';


class FertilizerView extends StatelessWidget {
  final FertilizerEntity data;

  const FertilizerView({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final allZones = data.data;
    return Column(
      children: [
        FertilizerSummaryCard(data),
        Expanded(
          child: allZones.isEmpty
              ?  noDataNew
              : GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: allZones.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FertilizerCard(data.data[index]),
              );
            },
          ),
        ),
      ],
    );

  }
}
