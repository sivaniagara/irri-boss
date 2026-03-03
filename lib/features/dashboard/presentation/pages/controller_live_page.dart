import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:niagara_smart_drip_irrigation/core/theme/app_themes.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/domain/entities/livemessage_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/presentation/widgets/fertstatus_section.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/presentation/widgets/previousday_section.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/presentation/widgets/prs_gauge_section.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/presentation/widgets/well_level_section.dart';
import '../widgets/ctrl_display.dart';
import '../widgets/latestmsg_section.dart';
import '../widgets/ryb_section.dart';
import '../widgets/timer_section.dart';
import '../widgets/livepage_display_values.dart';

class CtrlLivePage extends StatelessWidget {
  final LiveMessageEntity? selectedController;

  const CtrlLivePage({super.key, this.selectedController});

  double _safeParse(String? value) {
    if (value == null || value.isEmpty) return 0.0;
    return double.tryParse(value) ?? 0.0;
  }

  String _getFertStatus(int index) {
    if (selectedController != null && selectedController!.fertStatus.length > index) {
      return selectedController!.fertStatus[index];
    }
    return "0";
  }

  String _getFertValue(int index) {
    if (selectedController != null && selectedController!.fertValues.length > index) {
      return selectedController!.fertValues[index];
    }
    return "0";
  }

  @override
  Widget build(BuildContext context) {
    if (selectedController == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Controller Live Page"),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Controller Live Page"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Last sync: ${selectedController!.cd} ${selectedController!.ct}",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 16),
              CtrlDisplay(
                signal: selectedController!.signal,
                battery: selectedController!.batVolt,
                l1display: selectedController!.liveDisplay1,
                l2display: selectedController!.liveDisplay2,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Image.asset(
                      selectedController!.motorOnOff == "1"
                          ? 'assets/images/common/ui_motor.gif' // motor ON
                          : selectedController!.motorOnOff == "0"
                          ? 'assets/images/common/live_motor_off.png' // motor OFF
                          : 'assets/images/common/ui_motor_yellow.png', // no status
                      width: 60,
                      height: 60,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.settings_input_component, size: 40, color: AppThemes.primaryColor),
                    ),
                    LatestMsgSection(
                      msg: selectedController!.modeOfOperation,
                    ),
                    Image.asset(
                      selectedController!.valveOnOff == "1"
                          ? 'assets/images/common/valve_open.gif' // valve open
                          : selectedController!.valveOnOff == "0"
                          ? 'assets/images/common/valve_stop.png' // valve stop
                          : 'assets/images/common/valve_no_communication.png', // no communication
                      width: 60,
                      height: 60,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.vibration, size: 40, color: AppThemes.primaryColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              RYBSection(
                r: selectedController!.rVoltage,
                y: selectedController!.yVoltage,
                b: selectedController!.bVoltage,
                c1: selectedController!.rCurrent,
                c2: selectedController!.yCurrent,
                c3: selectedController!.bCurrent,
              ),
              const SizedBox(height: 16),
              TimerSection(
                setTime: selectedController!.runTimeToday,
                remainingTime: selectedController!.zoneRemainingTime,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildThemeInfoRow("Phase", selectedController!.phase, "Bat.V", selectedController!.batVolt),
                    const Divider(height: 20),
                    _buildThemeInfoRow("Program", selectedController!.programName, "Mode", selectedController!.modeOfOperation),
                    const Divider(height: 20),
                    _buildThemeInfoRow("Zone", selectedController!.zoneNo, "Valve", selectedController!.valveForZone),
                    const SizedBox(height: 16),
                    PressureGaugeSection(
                      prsIn: _safeParse(selectedController!.prsIn),
                      prsOut: _safeParse(selectedController!.prsOut),
                      fertFlow: _safeParse(selectedController!.flowRate),
                    ),
                    const SizedBox(height: 16),
                    WellLevelSection(
                      level: _safeParse(selectedController!.wellLevel),
                      flow: _safeParse(selectedController!.wellPercent),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FertStatusSection(
                F1: _getFertStatus(0),
                F2: _getFertStatus(1),
                F3: _getFertStatus(2),
                F4: _getFertStatus(3),
                F5: _getFertStatus(4),
                F6: _getFertStatus(5),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: _buildThemeInfoRow("Ec", selectedController!.ec, "PH", selectedController!.ph),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    _buildThemeInfoRow("Fert-1", _getFertValue(0), "Fert-2", _getFertValue(1)),
                    const Divider(height: 20),
                    _buildThemeInfoRow("Fert-3", _getFertValue(2), "Fert-4", _getFertValue(3)),
                    const Divider(height: 20),
                    _buildThemeInfoRow("Fert-5", _getFertValue(4), "Fert-6", _getFertValue(5)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              PreviousDaySection(
                runTimeToday: selectedController!.runTimeToday,
                runTimePrevious: selectedController!.runTimePrevious,
                flowToday: selectedController!.flowToday,
                flowPrevious: selectedController!.flowPrevDay,
                cFlowToday: "0",
                cFlowPrevious: "0",
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Version: ",
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Text(
                      "${selectedController!.versionBoard}  ${selectedController!.versionModule}",
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppThemes.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeInfoRow(String label1, String val1, String label2, String val2) {
    return Row(
      children: [
        Expanded(child: _buildInfoItem(label1, val1)),
        const SizedBox(width: 8),
        Expanded(child: _buildInfoItem(label2, val2)),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
