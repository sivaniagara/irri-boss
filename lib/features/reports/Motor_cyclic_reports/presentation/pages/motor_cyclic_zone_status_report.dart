import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_themes.dart';
import '../../domain/entities/motor_cyclic_entities.dart';
import '../../utils/motor_cyclic_program_calculator.dart';
import '../widgets/row_widgets.dart';

class MotorCyclicPageReport extends StatelessWidget {
  final MotoCyclicEntity data;

  const MotorCyclicPageReport({
    super.key,
    required this.data,
   });

  @override
  Widget build(BuildContext context) {
       return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: data.data.length,
        itemBuilder: (context, index) {
          final program = data.data[index];
          final programDuration =
          MotorCyclicProgramCalculator.programTotalDuration(program);

          final programFlow =
          MotorCyclicProgramCalculator.programTotalFlow(program);

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                 programSummaryCard(totalRuntime: programDuration, cyclicTime: "${program.zoneList.first.onTime} To ${program.zoneList.last.offTime}", totalFlow: programFlow.toString(),program: program.program),
                const SizedBox(height: 12),
                // 🔹 ZONE LIST
                ...program.zoneList.asMap().entries.map(
                      (entry) {
                    final i = entry.key + 1;
                    final zone = entry.value;

                    return zoneCard(i, zone);
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      );
    }
 }

Widget programSummaryCard({
  required String totalRuntime,
  required String cyclicTime,
  required String totalFlow,
  required String program,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 10,
        )
      ],
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _summaryItem(Icons.timer, "Total Runtime", totalRuntime),
            _summaryItem(Icons.refresh, "Cyclic Time", cyclicTime),
            _summaryItem(Icons.water, "Total Flow", totalFlow),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children:  [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 28,
            ),
            SizedBox(width: 8),
            Text(
              "Program $program Cycle is completed",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _summaryItem(IconData icon, String title, String value) {
  return Column(
    children: [
      CircleAvatar(
        radius: 22,
        backgroundColor: Colors.blue.shade50,
        child: Icon(icon, color: Colors.blue),
      ),
      const SizedBox(height: 6),
      Text(title, style: const TextStyle(fontSize: 12)),
      const SizedBox(height: 4),
      Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}

