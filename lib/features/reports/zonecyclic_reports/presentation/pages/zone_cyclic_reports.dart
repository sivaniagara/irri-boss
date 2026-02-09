import 'package:flutter/material.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/zonecyclic_reports/domain/entities/zone_cyclic_entities.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/zonecyclic_reports/presentation/widgets/zone_row_widgets.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/zonecyclic_reports/utils/zone_cyclic_program_calc.dart';

class ZoneCyclicPageReport extends StatefulWidget {
  final ZoneCyclicEntity data;

  const ZoneCyclicPageReport({
    super.key,
    required this.data,
  });

  @override
  State<ZoneCyclicPageReport> createState() => _ZoneCyclicPageReportState();
}

class _ZoneCyclicPageReportState extends State<ZoneCyclicPageReport> {
  // To keep track of which programs are expanded
  final Set<int> _expandedIndices = {};

  String _formatDuration(String duration) {
    if (duration.contains(':')) {
      final parts = duration.split(':');
      if (parts.length >= 2) {
        return "${parts[0]}:${parts[1]}";
      }
    }
    return duration;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.data.data.length,
      itemBuilder: (context, index) {
        final program = widget.data.data[index];
        final rawDuration = ZoneCyclicProgramCalculator.programTotalDuration(program);
        final programDuration = _formatDuration(rawDuration);
        final programFlow = ZoneCyclicProgramCalculator.programTotalFlow(program);
        final isExpanded = _expandedIndices.contains(index);

        return Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            summaryItem(
                              "Total Runtime",
                              "$programDuration Hrs",
                              Icons.access_time_rounded,
                              const Color(0xFF2196F3),
                            ),
                            summaryItem(
                              "Cyclic Time",
                              program.zoneList.isNotEmpty 
                                  ? "${_formatDuration(program.zoneList.first.onTime)} - ${_formatDuration(program.zoneList.last.offTime)}"
                                  : "00:00 - 00:00",
                              Icons.cached_rounded,
                              const Color(0xFF2196F3),
                            ),
                            summaryItem(
                              "Total Flow",
                              "${programFlow.toInt()} L",
                              Icons.waves_rounded,
                              const Color(0xFF2196F3),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Color(0xFF4CAF50),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Program ${program.program} Cycle is completed",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    "Motor stopped after zone cycle",
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (isExpanded) {
                          _expandedIndices.remove(index);
                        } else {
                          _expandedIndices.add(index);
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isExpanded ? "Hide Details" : "View Details",
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: Colors.black54,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  children: program.zoneList.asMap().entries.map((entry) {
                    return zonecyclicCard(entry.key + 1, entry.value);
                  }).toList(),
                ),
              ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}
