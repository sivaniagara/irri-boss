import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/theme/app_themes.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_app_bar.dart';
import 'package:niagara_smart_drip_irrigation/features/edit_program/presentation/widgets/custom_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/mqtt/mqtt_manager.dart';
import '../../../../core/services/mqtt/publish_messages.dart';
import '../../../core/di/injection.dart';
import '../../../core/services/mqtt/app_message_dispatcher.dart';
import '../../report_downloader/utils/report_downloaderRoute.dart';
import 'fert_live_dispatcher.dart';
import 'fertstate.dart';

class FertilizerLivePage extends StatefulWidget {
  final String deviceId;

  const FertilizerLivePage({super.key, required this.deviceId});

  @override
  State<FertilizerLivePage> createState() => _FertilizerLiveScreenState();
}

class _FertilizerLiveScreenState extends State<FertilizerLivePage> {
  late final FertilizerLiveDispatcher _dispatcher;
  Timer? _refreshTimer;

  FertilizerLiveState? fertilizerState;

  @override
  void initState() {
    super.initState();
    _dispatcher = FertilizerLiveDispatcher();

    fertilizerState = FertilizerLiveDispatcher.getLastState(widget.deviceId);

    if (fertilizerState == null) {
      _loadFromPrefs();
    }

    final appDispatcher = sl<AppMessageDispatcher>();
    appDispatcher.fertilizerLiveDispatcher = _dispatcher;

    _dispatcher.onFertLiveReceived = (deviceId, rawMessage) {
      if (deviceId.trim() == widget.deviceId.trim() ||
          deviceId.contains(widget.deviceId) ||
          widget.deviceId.contains(deviceId)) {
        final newState = fertilizerLiveStateFromRaw(rawMessage);
        if (newState.lastSyncTime != "NA") {
          if (mounted) {
            setState(() {
              fertilizerState = newState;
            });
          }
        }
      }
    };

    sl<MqttManager>().subscribe(widget.deviceId);

    _startAutoRefresh();
    _requestLiveData();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString('FERTLIVEMSG_${widget.deviceId}');
      if (savedData != null && savedData.isNotEmpty) {
        final parts = savedData.split(',');
        if (parts.length >= 3) {
          final ct = parts.last;
          final cd = parts[parts.length - 2];
          final cm = parts.sublist(0, parts.length - 2).join(',');

          final reconstructed = {
            'cM': cm,
            'cD': cd,
            'cT': ct,
          };

          final state = fertilizerLiveStateFromRaw(reconstructed);
          if (mounted && fertilizerState == null) {
            setState(() {
              fertilizerState = state;
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error loading fert live from prefs: $e");
    }
  }

  void _requestLiveData() {
    final publishMessage = jsonEncode(PublishMessageHelper.requestFertilizerLive);
    sl.get<MqttManager>().publish(widget.deviceId, publishMessage);
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 40), (_) {
      _requestLiveData();
    });
  }

  @override
  void dispose() {
    final appDispatcher = sl<AppMessageDispatcher>();
    if (appDispatcher.fertilizerLiveDispatcher == _dispatcher) {
      appDispatcher.fertilizerLiveDispatcher = null;
    }
    _dispatcher.onFertLiveReceived = null;
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemes.scaffoldBackGround,
      appBar: CustomAppBar(
        title: "FERTILIZER LIVE",
        actions: [
          IconButton(
            onPressed: _requestLiveData,
            icon: const Icon(Icons.refresh, color: Colors.black),
          ),
          IconButton(
            onPressed: () {
              if (fertilizerState != null) {
                final Map<String, dynamic> excelData = {
                  "Date": fertilizerState!.lastSyncDate,
                  "Time": fertilizerState!.lastSyncTime,
                  "Program": fertilizerState!.program,
                  "Mode": fertilizerState!.modeType,
                  "Pre-Water": fertilizerState!.preWater,
                  "Post-Water": fertilizerState!.postWater,
                  "Motor Status": fertilizerState!.motorStatus,
                  "EC": fertilizerState!.ec,
                  "pH": fertilizerState!.ph,
                  "Pressure": fertilizerState!.pressure,
                };

                for (int i = 0; i < 6; i++) {
                  excelData["F${i + 1} Level"] = fertilizerState!.tankLevels[i];
                  excelData["F${i + 1} Set Time"] = fertilizerState!.setTimes[i];
                  excelData["F${i + 1} Remain Time"] = fertilizerState!.remainTimes[i];
                }

                context.push(
                  ReportDownloadPageRoutes.ReportDownloadPage,
                  extra: {
                    "title": "Fertilizer Live Report",
                    "data": [excelData],
                  },
                );
              }
            },
            icon: const Icon(Icons.download_rounded, color: Colors.black),
          ),
        ],
      ),
      body: fertilizerState == null
          ? const Center(child: CircularProgressIndicator(color: AppThemes.primaryColor))
          : RefreshIndicator(
        color: AppThemes.primaryColor,
        onRefresh: () async => _requestLiveData(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _headerCard(),
              const SizedBox(height: 20),
              _sectionLabel("ACTIVE INJECTION POINTS"),
              _fertilizerRow(),
              const SizedBox(height: 20),
              _sectionLabel("TANK LEVELS (%)"),
              _tankLevelSection(),
              const SizedBox(height: 20),
              _sectionLabel("LIVE SENSORS"),
              _sensorSection(),
              const SizedBox(height: 20),
              _sectionLabel("SCHEDULES"),
              _timeModeSection(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w400,
          color: Colors.black,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _headerCard() {
    final String cleanProgram = fertilizerState!.program
        .replaceAll(RegExp(r'[pP]rogram\s*'), '')
        .replaceAll(RegExp(r'^[pP]'), '')
        .trim();

    return CustomCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.sync, size: 14, color: AppThemes.primaryColor),
              const SizedBox(width: 6),
              Text(
                "LAST SYNC: ${fertilizerState!.lastSyncDate}, ${fertilizerState!.lastSyncTime}",
                style: const TextStyle(fontSize: 11, color: AppThemes.primaryColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 32),
          Text(
            "${fertilizerState!.modeType.toUpperCase()} | PROGRAM $cleanProgram",
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _valveStatus("PRE-WATER", fertilizerState!.preWater ),
              _motorStatusBox(),
              _valveStatus("POST-WATER", fertilizerState!.postWater),
            ],
          ),
        ],
      ),
    );
  }

  Widget _motorStatusBox() {
    final bool motorOn = fertilizerState?.motorOn ?? false;
    final Color statusColor = motorOn ? Colors.green : Colors.red;

    return Column(
      children: [
        Container(
          width: 70, height: 70,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.05),
            shape: BoxShape.circle,
            border: Border.all(color: statusColor.withOpacity(0.2), width: 2),
          ),
          child: Center(
            child: Image.asset(
              motorOn ? 'assets/images/common/ui_motor.gif' : 'assets/images/common/live_motor_off.png',
              width: 40,
              height: 40,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          motorOn ? "RUNNING" : "STOPPED",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 10,
            color: statusColor,
          ),
        ),
      ],
    );
  }

  Widget _valveStatus(String label, String time) {
    final bool isRunning = time != "00:00" && (fertilizerState?.motorOn ?? false);
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 8),
        Image.asset(
          isRunning ? 'assets/images/common/valve_running.gif' : 'assets/images/common/valve_off.png',
          width: 40,
          height: 40,
        ),
        const SizedBox(height: 8),
        Text(
          time,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: isRunning ? Colors.green : Colors.black87),
        ),
      ],
    );
  }

  Widget _fertilizerRow() {
    return CustomCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(6, (index) {
          final bool active = fertilizerState?.fertilizerActive[index] ?? false;
          return Column(
            children: [
              Container(
                width: 45,
                height: 45,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (active ? Colors.green : Colors.red).withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Text(
                  "F${index + 1}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _tankLevelSection() {
    return CustomCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(6, (index) {
          return _tankWidget(index, fertilizerState!.tankLevels[index]);
        }),
      ),
    );
  }

  Widget _tankWidget(int index, int level) {
    final displayLevel = level.clamp(0, 1000);
    final bool active = fertilizerState?.fertilizerActive[index] ?? false;

    Color liquidColor = active ? Colors.green : Colors.red;

    return Column(
      children: [
        SizedBox(
          height: 140,
          width: 35,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                width: 24,
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(11, (i) {
                      return Container(width: i % 5 == 0 ? 8 : 4, height: 1, color: Colors.grey.shade300);
                    }),
                  ),
                ),
              ),
              Positioned(
                bottom: 2,
                child: AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeOutCubic,
                  width: 20,
                  height: (displayLevel / 1000) * 126,
                  decoration: BoxDecoration(
                    color: liquidColor.withOpacity(0.8),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(2)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "${(displayLevel / 10).round()}%",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: active ? Colors.green : Colors.red,
          ),
        ),
        Text(
          "F${index + 1}",
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _sensorSection() {
    return CustomCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _sensorItem(Icons.water_drop_outlined, "EC LEVEL", fertilizerState!.ec.toStringAsFixed(1), Colors.blue),
          _sensorItem(Icons.science_outlined, "PH LEVEL", fertilizerState!.ph.toStringAsFixed(1), Colors.teal),
          _sensorItem(Icons.speed_outlined, "PRESSURE", fertilizerState!.pressure.toStringAsFixed(1), Colors.indigo, unit: "BAR"),
        ],
      ),
    );
  }

  Widget _sensorItem(IconData icon, String label, String value, Color color, {String? unit}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.05), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppThemes.primaryColor)),
            if (unit != null) ...[
              const SizedBox(width: 2),
              Text(unit, style: const TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold)),
            ]
          ],
        ),
      ],
    );
  }

  Widget _timeModeSection() {
    return CustomCard(
      child: Column(
        children: [
          Row(
            children: const [
              Expanded(flex: 3, child: SizedBox()),
              Expanded(flex: 2, child: Text("SET TIME", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey))),
              Expanded(flex: 2, child: Text("REMAIN", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey))),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(6, (index) {
            final bool isActive = fertilizerState?.fertilizerActive[index] ?? false;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            Icon(Icons.opacity_rounded, size: 14, color: isActive ? Colors.green : Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              "Fertilizer ${index + 1}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isActive ? Colors.black87 : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(flex: 2, child: _timeBox(fertilizerState!.setTimes[index], isActive: isActive)),
                      const SizedBox(width: 12),
                      Expanded(flex: 2, child: _timeBox(fertilizerState!.remainTimes[index], isRemain: true, isActive: isActive)),
                    ],
                  ),
                ),
                if (index < 5) const Divider(height: 1, thickness: 0.5),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _timeBox(String time, {bool isRemain = false, bool isActive = false}) {
    return Text(
      time,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w900,
        color: isActive ? (isRemain ? Colors.green : Colors.black87) : Colors.grey,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
