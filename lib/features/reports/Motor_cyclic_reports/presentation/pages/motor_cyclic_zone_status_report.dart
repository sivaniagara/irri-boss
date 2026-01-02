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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 PROGRAM HEADER
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: const BoxDecoration(
                    color: AppThemes.primaryColor,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Program ${program.program}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        data.data[index].zoneList[0].date,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // 🔹 CYCLIC SUMMARY
                infoRow(
                    "Total Cyclic Duration",
                    programDuration,
                    Icons.timer_outlined
                ),
                infoRow(
                    "Cyclic Flow",
                    "$programFlow",
                    Icons.water_outlined
                ),
                infoRow(
                    "Cyclic Time",
                    "${program.zoneList.first.onTime} To ${program.zoneList.last.offTime}",
                    Icons.punch_clock
                ),

                const SizedBox(height: 12),

                // 🔹 STATUS MESSAGE
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      program.ctrlMsg,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

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
