import 'package:flutter/material.dart';
import 'package:niagara_smart_drip_irrigation/core/theme/app_themes.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glass_effect.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/data/models/program_view_model.dart';
import '../../../../core/widgets/glassy_wrapper.dart';

class ProgramPreview extends StatelessWidget {
  const ProgramPreview({super.key});

  @override
  Widget build(BuildContext context) {
    const rawBasic = "PROGRAM 1,0,Standalone Mode,TIMER FERT MODE,010,010,01:00,01:00,0,00:00:00,0,1:1,0,0,00:00:00,1,0,00:00;00:00,00:00;00:00,00:00;00:00,00:00;00:00,0,100:100:100:100,11:21:30:40:50:60,0:0:0:0:0:0,0.0:0.0:0.0:0.0:0.0:0.0, 0.00, 0.00, 0.00:0, 0.00";

    const zoneDetailsBasic = "009;00:00;0;V0:V0:V0:V0;00:00-00:00-00:00-00:00-00:00-00:00;0:0:0:0:0:0;0:50;0:50;0:50;0:50,010;00:00;0;V0:V0:V0:V0;00:00-00:00-00:00-00:00-00:00-00:00;0:0:0:0:0:0;0:50;0:50;0:50;0:50,";
    final programDetails = ProgramViewModel.fromRawString(rawBasic);
    final zoneDetails = ZoneViewModel.fromRawString(zoneDetailsBasic);

    return GlassyWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(programDetails.programName),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Last Sync:", style: TextStyle(fontSize: 12)),
                  Text(DateTime.now().toLocal().toString().split('.').first),
                ],
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20, top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConfigSection(
                title: "Basic Program Settings",
                children: [
                  const SizedBox(height: 8),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    childAspectRatio: 2.6,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: [
                      _buildInfoCard(label: "Program Name", value: programDetails.programName),
                      _buildInfoCard(label: "Irrigation Mode", value: programDetails.irrigationMode),
                      _buildInfoCard(label: "Valve Status", value: programDetails.valveStatus, isBoolean: true),
                      _buildInfoCard(label: "Dosing Mode", value: programDetails.dosingMode),
                      _buildInfoCard(label: "Decide Last", value: programDetails.decideLast),
                      _buildInfoCard(label: "Feedback Last", value: programDetails.decideFeedbackLast),
                      _buildInfoCard(label: "Delay Valve", value: programDetails.delayValve),
                      _buildInfoCard(label: "Feedback Time", value: programDetails.feedbackTime),
                      _buildInfoCard(label: "Drip Cyclic Restart", value: programDetails.dripCycRst, isBoolean: true),
                      _buildInfoCard(label: "Drip Restart Timer", value: programDetails.dripCycRstTime),
                      _buildInfoCard(label: "Zone Cyclic Restart", value: programDetails.zoneCycRst, isBoolean: true),
                      _buildInfoCard(
                          label: "Start from",
                          value: "Program:- ${programDetails.programStartNumber.split(":")[0]} , Zone:- ${programDetails.programStartNumber.split(":")[1]}"
                      ),
                      _buildInfoCard(label: "Sump", value: programDetails.sumpStatus, isBoolean: true),
                      _buildInfoCard(label: "Drip Sump Restart", value: programDetails.dripSumpStatus, isBoolean: true),
                      _buildInfoCard(label: "Day count RTC", value: programDetails.dayCountRtcTimer),
                      _buildInfoCard(label: "Skip Days", value: programDetails.skipDays, booleanValue: programDetails.skipDaysStatus == "1"),
                    ],
                  ),
                ],
              ),
              ConfigSection(
                title: "RTC Timers",
                children: [
                  ConfigRow(label: "RTC Timer", value: programDetails.rtcOnOff, isBoolean: true,),
                  Row(
                    children: const [
                      SizedBox(width: 120),
                      Expanded(child: Center(child: Text("On Time", style: TextStyle(fontWeight: FontWeight.bold)))),
                      Expanded(child: Center(child: Text("Off Time", style: TextStyle(fontWeight: FontWeight.bold)))),
                    ],
                  ),
                  ...List.generate(programDetails.rtcTimers.length, (i) =>
                      ConfigRow(
                        label: "Timer ${i + 1}",
                        value: programDetails.rtcTimers[i],
                        splitBy: ";",
                      ),
                  ),
                ],
              ),
              ConfigSection(
                title: "",
                children: [
                  ConfigGridRow(
                    label: "Adjust Percent",
                    values: programDetails.adjustPercent,
                    columnLabels: ["Time", "Flow", "Moisture", "Fert"],
                  ),
                ],
              ),
              ConfigSection(
                title: "Fertilizer Settings",
                children: [
                  Row(
                    spacing: 10,
                    children: [
                      SizedBox(width: 120),
                      for(int i = 0; i < programDetails.fertilizerRates[0].split(",")[0].split(":").length; i++)
                        Expanded(child: Center(child: Text("F${i+1}", style: TextStyle(fontWeight: FontWeight.bold)))),
                    ],
                  ),
                  ...List.generate(3, (i) =>
                      ConfigRow(
                        label: ["Fertilizer", "Fert Rate", "Vent Flow"][i],
                        value: programDetails.fertilizerRates[i],
                        splitBy: ":",
                      ),
                  ),
                  SizedBox(height: 10,),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    childAspectRatio: 2.6,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: [
                      _buildInfoCard(label: "Pre Quantity", value: programDetails.preQty),
                      _buildInfoCard(label: "Post Quantity", value: programDetails.postQty),
                      _buildInfoCard(label: "Pre Time", value: programDetails.preTime),
                      _buildInfoCard(label: "Post Time(%)", value: programDetails.postTimePercent),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  "Zone details",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                ),
              ),
              ConfigSection(
                title: "",
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildContainer(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("Zone : "),
                                Text(zoneDetails.zoneNumber, style: TextStyle(fontWeight: FontWeight.bold),),
                              ],
                            ),
                          )
                      ),
                      _buildContainer(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("Irrigation Time : "),
                                Text(zoneDetails.irrigationTime, style: TextStyle(fontWeight: FontWeight.bold),),
                              ],
                            ),
                          )
                      ),
                      _buildContainer(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("Irrigation Flow : "),
                                Text(zoneDetails.irrigationFlow, style: TextStyle(fontWeight: FontWeight.bold),),
                              ],
                            ),
                          )
                      ),
                      _buildContainer(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("Valves : "),
                                Text(zoneDetails.activeValves.split(':').join(','), style: TextStyle(fontWeight: FontWeight.bold),),
                              ],
                            ),
                          )
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text("Fertilizer Timer", style: const TextStyle(fontWeight: FontWeight.w500)),
                  ),
                  Row(
                    spacing: 10,
                    children: [
                      for(int i = 0; i < zoneDetails.fertigationTimes.split("-").length; i++)
                        Expanded(child: Center(child: Text("F${i+1}", style: TextStyle(fontWeight: FontWeight.bold)))),
                    ],
                  ),
                  ConfigRow(
                    value: zoneDetails.fertigationTimes,
                    splitBy: "-",
                  ),
                  Divider(color: Theme.of(context).primaryColor,),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text("Fertilizer Flow", style: const TextStyle(fontWeight: FontWeight.w500)),
                  ),
                  Row(
                    spacing: 10,
                    children: [
                      for(int i = 0; i < zoneDetails.fertigationTimes.split("-").length; i++)
                        Expanded(child: Center(child: Text("F${i+1}", style: TextStyle(fontWeight: FontWeight.bold)))),
                    ],
                  ),
                  ConfigRow(
                    value: zoneDetails.fertigationFlows,
                    splitBy: ":",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String label, required String value, bool isBoolean = false, bool? booleanValue}) {
    return _buildContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: isBoolean ? 0: 5,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if(isBoolean || booleanValue != null)
                Align(
                    alignment: AlignmentGeometry.bottomRight,
                    child: Switch(value: booleanValue ?? value == "1", onChanged: (newValue){})
                )
            ],
          ),
          if(!isBoolean)
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppThemes.primaryColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}

class ConfigSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool expanded;

  const ConfigSection({
    super.key,
    required this.title,
    required this.children,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: EdgeInsetsGeometry.symmetric(horizontal: 10, vertical: 5),
      opacity: 0.5,
      blur: 0,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ...children,
        ],
      ),
    );
  }
}

class ConfigRow extends StatelessWidget {
  final String? label;
  final String value;
  final bool highlight;
  final Pattern? splitBy;
  final bool? isBoolean;

  const ConfigRow({
    super.key,
    this.label,
    required this.value,
    this.highlight = false,
    this.splitBy,
    this.isBoolean = false
  });

  @override
  Widget build(BuildContext context) {
    // print(value);
    final TextStyle textStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: highlight ? Theme.of(context).primaryColor : Colors.black87,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        spacing: 10,
        children: [
          if(label != null && label!.isNotEmpty)
            SizedBox(width: 120, child: Text(label!, style: const TextStyle(fontWeight: FontWeight.w500))),
          if(!(isBoolean ?? false))
            if(splitBy != null)
              for(int i = 0; i < value.split(splitBy!).length; i++)
                Expanded(
                  child: _buildContainer(
                    child: label == "Fertilizer"
                        ? Checkbox(value: value.split(splitBy!)[i][1] == "1", onChanged: (value){})
                        : Text(
                      label == "Fertilizer" ? value.split(splitBy!)[i][1] : value.split(splitBy!)[i],
                      style: textStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
            else
              Expanded(
                child: _buildContainer(
                  child: Text(
                    value,
                    style: textStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
          else
            Expanded(
            child: Switch(value: value == "1", onChanged: (newValue){}))
        ],
      ),
    );
  }

  Widget _buildContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}

class ConfigGridRow extends StatelessWidget {
  final String? label;
  final List<String> values;
  final List<String> columnLabels;

  const ConfigGridRow({
    super.key,
    this.label,
    required this.values,
    required this.columnLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 110,
                child: Text(label!, style: const TextStyle(fontWeight: FontWeight.w500))
            ),
            ...List.generate(values.length, (i) =>
                Expanded(
                  child: Column(
                    children: [
                      if(columnLabels.isNotEmpty)
                        ...[
                          Text(columnLabels[i], style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4)
                        ],
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          values[i],
                          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
            ),
          ],
        ),
      ],
    );
  }
}