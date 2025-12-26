import 'package:flutter/material.dart';
 import 'package:niagara_smart_drip_irrigation/features/reports/zonecyclic_reports/domain/entities/zone_cyclic_entities.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/zonecyclic_reports/presentation/widgets/zone_row_widgets.dart';
 import 'package:niagara_smart_drip_irrigation/features/reports/zonecyclic_reports/utils/zone_cyclic_program_calc.dart';



class ZoneCyclicPageReport extends StatelessWidget {
  final ZoneCyclicEntity data;

  const ZoneCyclicPageReport({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: data.data.length,
        itemBuilder: (context, index) {
          final program = data.data[index];
          final programDuration =
          ZoneCyclicProgramCalculator.programTotalDuration(program);

          final programFlow =
          ZoneCyclicProgramCalculator.programTotalFlow(program);

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.blue,width: 0.5)
            ),
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 8),

                // 🔹 CYCLIC SUMMARY
                zoneinfoRow(
                    "Date",
                    program.zoneList[index].date,
                    Icons.date_range
                ),
                zoneinfoRow(
                    "Total Cyclic Duration",
                    programDuration,
                    Icons.timer_outlined
                ),
                zoneinfoRow(
                    "Cyclic Flow",
                    "$programFlow",
                    Icons.water_outlined
                ),
                zoneinfoRow(
                    "Cyclic Time",
                    "${program.zoneList.first.onTime} To ${program.zoneList.last.offTime}",
                    Icons.punch_clock
                ),

                const SizedBox(height: 12),



                // 🔹 ZONE LIST
                ...program.zoneList.asMap().entries.map(
                      (entry) {
                    final i = entry.key + 1;
                    final zone = entry.value;

                    return zonecyclicCard(i, zone,data.data);
                  },
                ),

                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }
}
