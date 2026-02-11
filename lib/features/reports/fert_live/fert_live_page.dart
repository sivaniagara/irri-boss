import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glassy_wrapper.dart';
import '../../../../core/services/mqtt/mqtt_manager.dart';
import '../../../../core/services/mqtt/publish_messages.dart';
import '../../../core/di/injection.dart';
import '../../../core/services/mqtt/app_message_dispatcher.dart';
import '../../../core/widgets/no_data.dart';
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

    final appDispatcher = sl<AppMessageDispatcher>();
    appDispatcher.fertilizerLiveDispatcher = _dispatcher;

    _dispatcher.onFertLiveReceived = (deviceId, rawMessage) {
      if (deviceId.trim() == widget.deviceId.trim() ||
          deviceId.contains(widget.deviceId) ||
          widget.deviceId.contains(deviceId)) {
        final newState = fertilizerLiveStateFromRaw(rawMessage);
        if (mounted) {
          setState(() {
            fertilizerState = newState;
          });
        }
      }
    };

    sl<MqttManager>().subscribe(widget.deviceId);

    _startAutoRefresh();
    _requestLiveData();
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
    return GlassyWrapper(
      child: Scaffold(
        backgroundColor: const Color(0xFFE5F1F1),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF37474F), size: 24),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            "Fertilizer Live Data",
            style: TextStyle(
              color: Color(0xFF263238),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
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
                      excelData["F${i+1} Level"] = fertilizerState!.tankLevels[i];
                      excelData["F${i+1} Set Time"] = fertilizerState!.setTimes[i];
                      excelData["F${i+1} Remain Time"] = fertilizerState!.remainTimes[i];
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
                icon: Image.asset(
                  'assets/images/icons/download-arrow-down.png',
                  width: 24,
                  height: 24,
                  color: const Color(0xFF37474F),
                ),
              ),
            ),
          ],
        ),
        body: fertilizerState == null
            ? Center(child: noDataNew)
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _headerCard(),
                    const SizedBox(height: 24),
                    _sectionLabel("Fertilizer Status"),
                    const SizedBox(height: 8),
                    _fertilizerRow(),
                    const SizedBox(height: 24),
                    _sectionLabel("Tank Levels"),
                    const SizedBox(height: 8),
                    _tankLevelSection(),
                    const SizedBox(height: 24),
                    _sectionLabel("Live Sensors"),
                    const SizedBox(height: 8),
                    _sensorSection(),
                    const SizedBox(height: 24),
                    _sectionLabel("Time Mode Schedules"),
                    const SizedBox(height: 8),
                    _timeModeSection(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black54,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _headerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.access_time, size: 14, color: Colors.blueAccent),
              const SizedBox(width: 6),
              Text(
                "Last sync: ${fertilizerState!.lastSyncDate} | ${fertilizerState!.lastSyncTime}",
                style: const TextStyle(fontSize: 13, color: Colors.blueAccent, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "${fertilizerState!.modeType} (Program ${fertilizerState!.program})",
            style: const TextStyle(
              color: Color(0xFF2E7D32),
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _valveStatus("Pre-Water", fertilizerState!.preWater),
              _motorStatusBox(),
              _valveStatus("Post-Water", fertilizerState!.postWater),
            ],
          ),
        ],
      ),
    );
  }

  Widget _motorStatusBox() {
    final bool motorOn = fertilizerState?.motorOn ?? false;
    final Color boxColor = motorOn ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
    final Color textColor = motorOn ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    final Color shadowColor = motorOn ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            motorOn ? "MOTOR ON" : "MOTOR OFF",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 17,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            fertilizerState!.motorStatus.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: textColor.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _valveStatus(String label, String time) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.blueGrey),
        ),
        const SizedBox(height: 10),
        Image.asset('assets/images/common/valve.png', width: 44, height: 44),
        const SizedBox(height: 10),
        Text(
          time,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _fertilizerRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(6, (index) {
          final active = fertilizerState?.fertilizerActive[index] ?? false;
          return Container(
            width: 44,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF44336),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Text(
              "F${index + 1}",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          );
        }),
      ),
    );
  }

  Widget _tankLevelSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(6, (index) {
          return _tankWidget(fertilizerState!.tankLevels[index]);
        }),
      ),
    );
  }

  Widget _tankWidget(int level) {
    final displayLevel = level.clamp(0, 1000);
    
    // Liquid color changes based on level for "water filling game" effect
    Color liquidColor;
    if (displayLevel < 200) {
      liquidColor = Colors.red[700]!;
    } else if (displayLevel < 500) {
      liquidColor = Colors.orange[700]!;
    } else if (displayLevel < 800) {
      liquidColor = Colors.blue[600]!;
    } else {
      liquidColor = Colors.blue[800]!;
    }

    return Column(
      children: [
        SizedBox(
          height: 220,
          width: 50,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                width: 32,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.blueGrey[50]!.withOpacity(0.3),
                  border: Border.all(color: Colors.black87, width: 1.5),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(11, (i) {
                      int val = (10 - i) * 100;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(width: 6, height: 1.2, color: Colors.black38),
                          const SizedBox(width: 2),
                          Text("$val", style: const TextStyle(fontSize: 6.5, fontWeight: FontWeight.bold, color: Colors.black54)),
                        ],
                      );
                    }),
                  ),
                ),
              ),
              Positioned(
                bottom: 2,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOut,
                  width: 28.5,
                  height: (displayLevel / 1000) * 196,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [liquidColor.withOpacity(0.8), liquidColor],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: const Radius.circular(14),
                      bottomRight: const Radius.circular(14),
                      topLeft: displayLevel > 950 ? const Radius.circular(14) : Radius.zero,
                      topRight: displayLevel > 950 ? const Radius.circular(14) : Radius.zero,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sensorSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _sensorItem(Icons.water_drop_outlined, "EC", fertilizerState!.ec.toString().split('.').first, Colors.blue),
          _sensorItem(Icons.science_outlined, "pH", fertilizerState!.ph.toString().split('.').first, Colors.teal),
          _sensorItem(Icons.speed_outlined, "Pressure", fertilizerState!.pressure.toStringAsFixed(1), Colors.indigo, unit: "Bar"),
        ],
      ),
    );
  }

  Widget _sensorItem(IconData icon, String label, String value, Color color, {String? unit}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            if (unit != null) ...[
              const SizedBox(width: 2),
              Text(unit, style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
            ]
          ],
        ),
      ],
    );
  }

  Widget _timeModeSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              color: Colors.blueGrey[50],
              child: Row(
                children: const [
                  Expanded(flex: 3, child: SizedBox()),
                  Expanded(flex: 2, child: Text("SET TIME", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Colors.blueGrey, letterSpacing: 0.5))),
                  Expanded(flex: 2, child: Text("REMAIN", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Colors.blueGrey, letterSpacing: 0.5))),
                ],
              ),
            ),
            ...List.generate(6, (index) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            "Fertilizer ${index + 1}",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF263238)),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: _timeBox(fertilizerState!.setTimes[index]),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: _timeBox(fertilizerState!.remainTimes[index], isRemain: true),
                        ),
                      ],
                    ),
                  ),
                  if (index < 5) Divider(height: 1, color: Colors.grey[100]),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _timeBox(String time, {bool isRemain = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: isRemain ? Colors.red[50] : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isRemain ? Colors.red[100]! : Colors.grey[200]!),
      ),
      child: Center(
        child: Text(
          time,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: isRemain ? Colors.red[700] : const Color(0xFF263238),
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}
