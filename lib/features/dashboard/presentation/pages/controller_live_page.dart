import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glass_effect.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glassy_wrapper.dart';
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

  @override
  Widget build(BuildContext dialogContext) {
    print("fertStatus:${selectedController!.fertStatus}");
    print("fertValues:${selectedController!.fertValues}");
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (notification) {
        notification.disallowIndicator();
        return true;
      },
      child: GlassyWrapper(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text("Controller Live Page"),
          ),
          body: GlassCard(
            margin: EdgeInsets.all(10),
            child: selectedController == null
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      "Last sync: ",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GlassCard(
                    child: CtrlDisplay(
                      signal: selectedController!.signal,
                      battery: selectedController!.batVolt,
                      l1display: selectedController!.liveDisplay1,
                      l2display: selectedController!.liveDisplay2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
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
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  RYBSection(
                    r: selectedController!.rVoltage,
                    y: selectedController!.yVoltage,
                    b: selectedController!.bVoltage,
                    c1: selectedController!.rCurrent,
                    c2: selectedController!.yCurrent,
                    c3: selectedController!.bCurrent,
                  ),
                  const SizedBox(height: 8),
                     Column(
                      children: [
                        // PressureSection(
                        //   prsIn: selectedController!.prsIn,
                        //   prsOut: selectedController!.prsOut,
                        //   activeZone: selectedController!.zoneNo,
                        //   fertlizer: '',
                        // ),
                        const SizedBox(height: 8),
                        TimerSection(
                          setTime: selectedController!.runTimeToday,
                          remainingTime: selectedController!.zoneRemainingTime,
                        ),
                      ],
                    ),

                  const SizedBox(height: 8),
                  GlassCard(
                    padding: const EdgeInsets.all(0),
                    margin: const EdgeInsets.all(0),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Your LiveDisplayObject is used here
                          LiveDisplayObject(
                            disMsg1: "Phase",
                            disValues1: selectedController!.phase,
                            disMsg2: "Bat.V",
                            disValues2: selectedController!.batVolt,
                          ),
                          const SizedBox(height: 10),
                          LiveDisplayObject(
                            disMsg1: "Program",
                            disValues1: selectedController!.programName,
                            disMsg2: "Mode",
                            disValues2: selectedController!.modeOfOperation,
                          ),
                          const SizedBox(height: 10),
                          LiveDisplayObject(
                            disMsg1: "Zone",
                            disValues1: selectedController!.zoneNo,
                            disMsg2: "Valve",
                            disValues2: selectedController!.valveForZone,
                          ),
                          const SizedBox(height: 10),

                          PressureGaugeSection(prsIn: double.parse(selectedController!.prsIn), prsOut: double.parse(selectedController!.prsOut), fertFlow: double.parse(selectedController!.flowRate)),
                          const SizedBox(height: 10),
                          WellLevelSection(level: double.parse(selectedController!.wellLevel), flow: double.parse(selectedController!.wellPercent))
                        ],
                      ),
                    ),
                  ),
                  FertStatusSection(F1: selectedController!.fertStatus[0], F2: selectedController!.fertStatus[1], F3: selectedController!.fertStatus[2], F4: selectedController!.fertStatus[3], F5: selectedController!.fertStatus[4], F6: selectedController!.fertStatus[5]),
                  const SizedBox(height: 10),
                  GlassCard(
                    child: Center(
                      child: LiveDisplayObject(
                        disMsg1: "Ec",
                        disValues1: selectedController!.ec,
                        disMsg2: "PH",
                        disValues2: selectedController!.ph,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GlassCard(
                    child: Center(
                      child: Column(
                        children: [
                          LiveDisplayObject(
                            disMsg1: "Fert-1",
                            disValues1: selectedController!.fertValues[0],
                            disMsg2: "Fert-2",
                            disValues2: selectedController!.fertValues[1],
                          ),
                          LiveDisplayObject(
                            disMsg1: "Fert-3",
                            disValues1: selectedController!.fertValues[2],
                            disMsg2: "Fert-4",
                            disValues2: selectedController!.fertValues[3],
                          ),
                          LiveDisplayObject(
                            disMsg1: "Fert-5",
                            disValues1: selectedController!.fertValues[4],
                            disMsg2: "Fert-6",
                            disValues2: selectedController!.fertValues[5],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  PreviousDaySection(
                    runTimeToday: selectedController!.runTimeToday,
                    runTimePrevious: selectedController!.runTimePrevious,
                    flowToday: selectedController!.flowToday,
                    flowPrevious: selectedController!.flowPrevDay,
                    cFlowToday: "0",
                    cFlowPrevious: "0",
                  ),
                  const SizedBox(height: 10),
                  GlassCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white30,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "Version:",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: CupertinoColors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "${selectedController!.versionBoard}\t ${selectedController!.versionModule}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}