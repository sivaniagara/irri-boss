import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/core/theme/app_themes.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/data/models/program_view_model.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/domain/entities/livemessage_entity.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/mqtt/mqtt_manager.dart';
import '../../../../core/services/mqtt/publish_messages.dart';
import '../../../../core/widgets/leaf_box.dart';
import '../cubit/dashboard_page_cubit.dart';
import '../../utils/program_preview_dispatcher.dart';

class ProgramPreviewPage extends StatefulWidget {
  final String deviceId;
  const ProgramPreviewPage({super.key, required this.deviceId});

  @override
  State<ProgramPreviewPage> createState() => _ProgramPreviewPageState();
}

class _ProgramPreviewPageState extends State<ProgramPreviewPage> with SingleTickerProviderStateMixin {
  ProgramViewModel? _program;
  final List<ZoneViewModel> zoneList = <ZoneViewModel>[];

  String? _lastSync;
  bool _isLoading = true;
  String? _error;
  late AnimationController _refreshController;

  static const Color niagaraRed = Color(0xFFD32F2F);
  static const Color niagaraGreen = Color(0xFF2E7D32);

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    sl.get<MqttManager>().subscribe(widget.deviceId);
    _setupDispatcher();
    _loadFromCache();
    _requestMessage();
  }

  Future<void> _loadFromCache() async {
    final dispatcher = sl.get<ProgramPreviewDispatcher>();
    final cachedProg = await dispatcher.getCachedProgram(widget.deviceId);
    final cachedZones = await dispatcher.getCachedZones(widget.deviceId);

    if (!mounted) return;

    bool hasData = false;

    if (cachedProg != null) {
      final raw = (cachedProg["cM"] ?? '').toString();
      final ts = "${cachedProg["cT"] ?? ''}\n${cachedProg["cD"] ?? ''}";
      _program = ProgramViewModel.fromRawString(raw, externalLastSync: ts);
      _lastSync = ts;
      hasData = true;
    }

    if (cachedZones != null && cachedZones.isNotEmpty) {
      for (var zMap in cachedZones) {
        final raw = (zMap["cM"] ?? '').toString();
        final zonesInMsg = raw.split(",").where((s) => s.trim().isNotEmpty).toList();
        for (var zoneStr in zonesInMsg) {
          if (zoneStr.trim() == "V02" || zoneStr.trim() == "V01") continue;
          final zone = ZoneViewModel.fromRawString(zoneStr);
          if (zone.zoneNumber.isEmpty) continue;
          final String normalizedNum = _normalize(zone.zoneNumber);
          int existingIndex = zoneList.indexWhere((z) => _normalize(z.zoneNumber) == normalizedNum);
          if (existingIndex != -1) {
            zoneList[existingIndex] = zone;
          } else {
            zoneList.add(zone);
          }
        }
      }
      zoneList.sort((a, b) => (int.tryParse(a.zoneNumber) ?? 0).compareTo(int.tryParse(b.zoneNumber) ?? 0));
      hasData = true;
    }

    if (hasData && mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _requestMessage({bool isSilent = false}) async {
    if (mounted) {
      setState(() {
        if (!isSilent && _program == null && zoneList.isEmpty) _isLoading = true;
        _error = null;
      });
      _refreshController.repeat();
    }

    if (_program == null && zoneList.isEmpty) {
      _timeoutTimer?.cancel();
      _timeoutTimer = Timer(const Duration(seconds: 15), () {
        if (mounted && _isLoading && _program == null && zoneList.isEmpty) {
          setState(() {
            _isLoading = false;
            _error = "CONTROLLER NOT RESPONDING.";
            _refreshController.stop();
          });
        }
      });
    }

    final mqtt = sl.get<MqttManager>();

    mqtt.publish(widget.deviceId, jsonEncode(PublishMessageHelper.requestProgramPreview));
    mqtt.publish(widget.deviceId, jsonEncode(PublishMessageHelper.requestLive));

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _refreshController.stop();
    });
  }

  Timer? _timeoutTimer;

  String _normalize(String s) {
    final digits = s.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return s.trim().toLowerCase();
    return int.tryParse(digits)?.toString() ?? digits;
  }

  void _setupDispatcher() {
    final dispatcher = sl.get<ProgramPreviewDispatcher>();

    dispatcher.onProgramReceived = (deviceId, message) {
      if (deviceId != widget.deviceId) return;
      final String mC = (message["mC"] ?? '').toString();
      final String rawMessage = (message["cM"] ?? '').toString();
      if (rawMessage.isEmpty) return;
      final String currentTimestamp = "${message["cT"] ?? ''}\n${message["cD"] ?? ''}";

      if (mC == "V01") {
        try {
          final program = ProgramViewModel.fromRawString(rawMessage, externalLastSync: currentTimestamp);
          if (mounted) {
            setState(() {
              _program = program;
              if (currentTimestamp.trim().isNotEmpty) _lastSync = currentTimestamp;
              _isLoading = false;
              _error = null;
              _refreshController.stop();
            });
            _timeoutTimer?.cancel();
          }
        } catch (e) {
          debugPrint("Program parse error: $e");
        }
      }
    };

    dispatcher.onZoneReceived = (deviceId, message) {
      if (deviceId != widget.deviceId) return;
      final String mC = (message["mC"] ?? '').toString();
      final String rawMessage = (message["cM"] ?? '').toString();
      if (rawMessage.isEmpty) return;
      final String currentTimestamp = "${message["cT"] ?? ''}\n${message["cD"] ?? ''}";

      if (mC == "V02") {
        try {
          final zonesInMsg = rawMessage.split(",").where((s) => s.trim().isNotEmpty).toList();
          if (mounted) {
            setState(() {
              for (var zoneStr in zonesInMsg) {
                if (zoneStr.trim() == "V02" || zoneStr.trim() == "V01") continue;

                final zone = ZoneViewModel.fromRawString(zoneStr);
                if (zone.zoneNumber.isEmpty) continue;

                final String normalizedNum = _normalize(zone.zoneNumber);
                int existingIndex = zoneList.indexWhere((z) => _normalize(z.zoneNumber) == normalizedNum);

                if (existingIndex != -1) {
                  zoneList[existingIndex] = zone;
                } else {
                  zoneList.add(zone);
                }
              }
              zoneList.sort((a, b) => (int.tryParse(a.zoneNumber) ?? 0).compareTo(int.tryParse(b.zoneNumber) ?? 0));
              if (currentTimestamp.trim().isNotEmpty) _lastSync = currentTimestamp;
              _isLoading = false;
              _error = null;
              _refreshController.stop();
            });
            _timeoutTimer?.cancel();
          }
        } catch (e) {
          debugPrint("Zone parse error: $e");
        }
      }
    };
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _refreshController.dispose();
    final dispatcher = sl.get<ProgramPreviewDispatcher>();
    dispatcher.onProgramReceived = null;
    dispatcher.onZoneReceived = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return BlocBuilder<DashboardPageCubit, DashboardState>(
      builder: (context, state) {
        LiveMessageEntity? liveMessage;

        if (state is DashboardGroupsLoaded) {
          for (var groupControllers in state.groupControllers.values) {
            for (var controller in groupControllers) {
              if (controller.deviceId == widget.deviceId) {
                liveMessage = controller.liveMessage;
                if (_refreshController.isAnimating && liveMessage.lastsync.isNotEmpty) {
                  _refreshController.stop();
                }
                break;
              }
            }
          }
        }

        if (_program == null && liveMessage != null && liveMessage.programName.isNotEmpty) {
          _program = ProgramViewModel.fromLiveMessage(liveMessage);
          _isLoading = false;
        }

        final String currentProgName = liveMessage?.programName ?? _program?.programName ?? "1";
        final String lastSyncToDisplay = _lastSync ?? liveMessage?.lastsync ?? "--";

        final bool isOnline = liveMessage?.motorOnOff == "1";

        return Scaffold(
          backgroundColor: AppThemes.scaffoldBackGround,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: const Text("Program Preview", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
            actions: [
              AnimatedBuilder(
                animation: _refreshController,
                builder: (context, child) {
                  return RotationTransition(
                    turns: _refreshController,
                    child: IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.black),
                      onPressed: () => _requestMessage(),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Center(child: _buildConnectionBadge(isOnline)),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.9),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Image.asset("assets/images/icons/program_icon.png", width: 30, height: 30, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(currentProgName.toUpperCase().contains("PROGRAM") ? currentProgName.toUpperCase() : "PROGRAM $currentProgName",
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text("Last Sync", style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold)),
                        Text(lastSyncToDisplay.replaceAll('\n', ' '), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: (_isLoading && _program == null && zoneList.isEmpty)
              ? const Center(child: CircularProgressIndicator(color: Colors.black45))
              : _error != null && _program == null && zoneList.isEmpty
              ? _buildErrorState()
              : RefreshIndicator(
            onRefresh: () => _requestMessage(),
            color: primaryColor,
            child: _buildContent(liveMessage, isOnline),
          ),
        );
      },
    );
  }

  Widget _buildConnectionBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isActive ? Colors.green.shade700 : Colors.red.shade700, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: isActive ? Colors.green.shade700 : Colors.red.shade700, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(isActive ? "ONLINE" : "OFFLINE", style: TextStyle(color: isActive ? Colors.green.shade900 : Colors.red.shade900, fontSize: 9, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sync_problem, size: 64, color: Colors.white70),
          const SizedBox(height: 16),
          Text(_error ?? "Unknown Error", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ElevatedButton(
              onPressed: () => _requestMessage(),
              child: const Text("RETRY")
          ),
        ],
      ),
    );
  }

  Widget _buildContent(LiveMessageEntity? liveMessage, bool isOnline) {
    final bool isValveOn = liveMessage != null ? liveMessage.valveOnOff == "1" : (_program?.valveStatus == "1");
    final String currentProgName = liveMessage?.programName ?? _program?.programName ?? "1";

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 40),
      children: [
        Row(
          children: [
            Expanded(child: _buildRowBox("Current Program", currentProgName, isBadge: false, iconPath: "assets/images/icons/program_icon.png")),
            const SizedBox(width: 10),
            Expanded(child: _buildRowBox("Valve", isValveOn ? "ON" : "OFF", isBadge: true, badgeOn: isValveOn, iconPath: "assets/images/icons/valve_icon.png")),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildRowBox("Irrigation", _program?.irrigationMode.toUpperCase() ?? "NA", isBadge: true, badgeMode: true, iconPath: "assets/images/icons/irrigation_setting_icon.png")),
            const SizedBox(width: 10),
            Expanded(child: _buildRowBox("Dosing", _program?.dosingMode.toUpperCase() ?? "NA", isBadge: true, badgeMode: true, iconPath: "assets/images/icons/fertilizer_pump_icon.png")),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildRowBox("Decide Last", _program?.decideLast ?? "0", isBadge: false, blueVal: true)),
            const SizedBox(width: 10),
            Expanded(child: _buildRowBox("FB Last", _program?.decideFeedbackLast ?? "0", isBadge: false, blueVal: true)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildRowBox("Delay Valve", _program?.delayValve ?? "0", isBadge: false, blueVal: true)),
            const SizedBox(width: 10),
            Expanded(child: _buildRowBox("FB Valve", _program?.feedbackTime ?? "0", isBadge: false, blueVal: true)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildRowBox("Drip Cyc Rst", (_program?.dripCycRst == "1") ? "ON" : "OFF", isBadge: true, badgeOn: _program?.dripCycRst == "1")),
            const SizedBox(width: 10),
            Expanded(child: _buildRowBox("Timer", _program?.dripCycRstTime ?? "00:00", isBadge: false, blueVal: true, iconPath: "assets/images/icons/timer_icon.png")),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildRowBox("Zone Cyc Rst", (_program?.zoneCycRst == "1") ? "ON" : "OFF", isBadge: true, badgeOn: _program?.zoneCycRst == "1")),
            const SizedBox(width: 6),
            Expanded(child: _buildStartFromBox()),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildRowBox("Sump", (_program?.sumpStatus == "1") ? "ON" : "OFF", isBadge: true, badgeOn: _program?.sumpStatus == "1", iconPath: "assets/images/icons/over_head_tank_icon.png")),
            const SizedBox(width: 10),
            Expanded(child: _buildRowBox("Drip Sump Rst", (_program?.dripSumpStatus == "1") ? "ON" : "OFF", isBadge: true, badgeOn: _program?.dripSumpStatus == "1")),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildRowBox("Day Count RTC", _program?.dayCountRtcTimer ?? "0", isBadge: false, blueVal: true, iconPath: "assets/images/icons/timer_icon.png")),
            const SizedBox(width: 10),
            Expanded(child: _buildSkipDaysBox()),
          ],
        ),
        const SizedBox(height: 16),
        _buildRTCGridSection(),
        const SizedBox(height: 16),

        ConfigSection(
          title: "Adjust Settings",
          icon: Icons.tune,
          children: [
            ConfigGridRow(
              label: "Adjust Percent(%)",
              values: (liveMessage != null && liveMessage.fertValues.length >= 12)
                  ? liveMessage.fertValues.sublist(8, 12)
                  : (_program?.adjustPercent ?? ["100", "100", "100", "100"]),
              columnLabels: ["Time", "Flow", "Moisture", "Fert"],
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildFertilizerGridSection(liveMessage),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildRowBox("Pre Quantity", _program?.preQty ?? "0", isBadge: false, blueVal: true, iconPath: "assets/images/icons/flow_icon.png")),
            const SizedBox(width: 10),
            Expanded(child: _buildRowBox("Post Quantity", _program?.postQty ?? "0", isBadge: false, blueVal: true, iconPath: "assets/images/icons/flow_icon.png")),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildRowBox("Pre Time", _program?.preTime ?? "00:00", isBadge: false, blueVal: true, iconPath: "assets/images/icons/timer_icon.png")),
            const SizedBox(width: 10),
            Expanded(child: _buildRowBox("Post Time(%)", _program?.postTimePercent ?? "0", isBadge: false, blueVal: true, iconPath: "assets/images/icons/timer_icon.png")),
          ],
        ),
        const SizedBox(height: 16),


        if (zoneList.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: LeafBox(
              height: 45,
              margin: EdgeInsets.zero,
              child: Center(child: Text("ZONE DETAILS", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor, fontSize: 16))),
            ),
          ),
          ...zoneList.map((z) {
            final bool isRunning = isOnline && liveMessage != null &&
                _normalize(liveMessage.zoneNo) == _normalize(z.zoneNumber) &&
                _normalize(liveMessage.zoneNo) != "0" &&
                _normalize(liveMessage.programName) == _normalize(_program?.programName ?? "");

            return ConfigSection(
              title: "Zone ${z.zoneNumber}",
              trailing: isRunning ? _buildBadge("RUNNING", isOn: true) : null,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildIconValue("assets/images/icons/timer_icon.png", "Irrigation Time", isRunning ? liveMessage.zoneRemainingTime : z.irrigationTime),
                    _buildIconValue("assets/images/icons/flow_icon.png", "Flow", z.irrigationFlow),
                    _buildIconValue("assets/images/icons/valve_icon.png", "Valves", z.activeValves.split(':').where((v) => v != "V0").join(', ')),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                Row(
                  children: [
                    Image.asset("assets/images/icons/fertilizer_icon.png", width: 20, height: 20, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    const Text("Fertilizer Timer", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                ConfigRow(value: z.fertigationTimes, splitBy: "-"),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Image.asset("assets/images/icons/flow_meter_icon.png", width: 20, height: 20, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    const Text("Fertilizer Flow", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                ConfigRow(value: z.fertigationFlows, splitBy: ":"),
              ],
            );
          }),
        ],
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildIconValue(String iconPath, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(iconPath, width: 18, height: 18, color: Theme.of(context).primaryColor),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRowBox(String label, String value, {required bool isBadge, bool? badgeOn, bool badgeMode = false, bool blueVal = false, String? iconPath}) {
    final primaryColor = Theme.of(context).primaryColor;
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(
        children: [
          if (iconPath != null) ...[
            Image.asset(iconPath, width: 24, height: 24, color: primaryColor),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.black54)),
                const SizedBox(height: 2),
                if (isBadge)
                  _buildBadge(value, isOn: badgeOn, isMode: badgeMode)
                else
                  Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: blueVal ? primaryColor : Colors.black87, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, {bool? isOn, bool isMode = false}) {
    Color bg = const Color(0xFFE3F2FD);
    Color textCol = Colors.black87;
    BoxBorder? border;

    if (isMode) {
      bg = Colors.white;
      textCol = niagaraGreen;
      border = Border.all(color: niagaraGreen.withValues(alpha: 0.3));
    } else if (isOn != null) {
      bg = isOn ? niagaraGreen : niagaraRed;
      textCol = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: border,
      ),
      child: Text(text, style: TextStyle(color: textCol, fontWeight: FontWeight.bold, fontSize: 10)),
    );
  }

  Widget _buildStartFromBox() {
    final String raw = _program?.programStartNumber ?? "1:1";
    final parts = raw.split(':');
    final prgm = parts.isNotEmpty ? parts[0] : raw;
    final zone = parts.length > 1 ? parts[1] : "1";
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(
        children: [
          const Expanded(child: Text("Start from", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.black54))),
          _miniValueCol("PRGM", prgm, primaryColor),
          const SizedBox(width: 8),
          _miniValueCol("ZONE", zone, primaryColor),
        ],
      ),
    );
  }

  Widget _buildSkipDaysBox() {
    final primaryColor = Theme.of(context).primaryColor;
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Skip Days", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.black54)),
          Row(
            children: [
              Text(_program?.skipDays ?? "0", style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 16)),
              const SizedBox(width: 10),
              _buildBadge((_program?.skipDaysStatus == "1") ? "ON" : "OFF", isOn: _program?.skipDaysStatus == "1"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniValueCol(String label, String val, Color primaryColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
          child: Text(val, style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildRTCGridSection() {
    final List<String> rtc = _program?.rtcTimers ?? List.filled(4, "00:00;00:00");
    final primaryColor = Theme.of(context).primaryColor;

    return ConfigSection(
      title: "RTC Timers",
      icon: Icons.timer_outlined,
      trailing: _buildBadge((_program?.rtcOnOff == "1") ? "ON" : "OFF", isOn: _program?.rtcOnOff == "1"),
      children: [
        Row(
          children: [
            const SizedBox(width: 40),
            Expanded(child: Center(child: Text("ON TIME", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: primaryColor.withValues(alpha: 0.6))))),
            const SizedBox(width: 10),
            Expanded(child: Center(child: Text("OFF TIME", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: primaryColor.withValues(alpha: 0.6))))),
          ],
        ),
        const SizedBox(height: 8),
        ...List.generate(rtc.length, (i) {
          final times = rtc[i].split(";");
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Center(child: Text("${i + 1}", style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 12))),
                ),
                const SizedBox(width: 10),
                Expanded(child: _dataValueBox(times[0])),
                const SizedBox(width: 10),
                Expanded(child: _dataValueBox(times.length > 1 ? times[1] : "00:00")),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFertilizerGridSection(LiveMessageEntity? live) {
    final fertStatus = live != null ? live.fertStatus : (_program?.fertilizerStatus ?? List.filled(6, "0"));
    final fertRates = live != null ? live.fertValues : (_program?.fertilizerRates ?? List.filled(6, "0"));
    final primaryColor = Theme.of(context).primaryColor;

    return ConfigSection(
      title: "Fertilizer Channels",
      icon: Icons.opacity,
      children: [
        Row(
          children: [
            const SizedBox(width: 85),
            ...List.generate(6, (i) => Expanded(child: Center(child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(6)),
              child: Text("F${i + 1}", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            )))),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const SizedBox(width: 85, child: Text("Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black54))),
            ...List.generate(6, (i) {
              final String status = fertStatus.length > i ? fertStatus[i] : "0";
              final bool isOn = status == "1" || status.endsWith("1");
              return Expanded(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _buildBadge(isOn ? "ON" : "OFF", isOn: isOn),
              ));
            }),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const SizedBox(width: 85, child: Text("Rate", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black54))),
            ...List.generate(6, (i) => Expanded(child: _dataValueBox(fertRates.length > i ? fertRates[i] : "0", small: true))),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const SizedBox(width: 85, child: Text("Vent Flow", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black54))),
            ...List.generate(6, (i) => Expanded(child: _dataValueBox((_program?.ventFlows.length ?? 0) > i ? _program!.ventFlows[i] : "0.0", small: true))),
          ],
        ),
      ],
    );
  }

  Widget _dataValueBox(String val, {bool small = false}) {
    final primaryColor = Theme.of(context).primaryColor;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: EdgeInsets.symmetric(vertical: small ? 8 : 10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200)),
      child: Center(child: Text(val, style: TextStyle(color: primaryColor, fontSize: small ? 11 : 14, fontWeight: FontWeight.bold))),
    );
  }
}

class ConfigSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? trailing;
  final IconData? icon;
  const ConfigSection({super.key, required this.title, required this.children, this.trailing, this.icon});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primaryColor.withValues(alpha: 0.1))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 20, color: primaryColor),
                        const SizedBox(width: 10),
                      ],
                      Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: primaryColor)),
                    ],
                  ),
                  if (trailing != null) trailing!,
                ],
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
  final String splitBy;
  const ConfigRow({super.key, this.label, required this.value, required this.splitBy});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final values = value.split(splitBy).where((e) => e.trim().isNotEmpty).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          if (label != null)
            SizedBox(width: 85, child: Text(label!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black54))),
          ...values.map((v) => Expanded(child: Center(child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
              child: Center(child: Text(v, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor))))))),
        ],
      ),
    );
  }
}

class ConfigGridRow extends StatelessWidget {
  final String label;
  final List<String> values;
  final List<String> columnLabels;
  const ConfigGridRow({super.key, required this.label, required this.values, required this.columnLabels});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Row(
      children: [
        SizedBox(width: 110, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black54))),
        Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  for (var colLabel in columnLabels)
                    Expanded(child: Center(child: Text(colLabel, style: TextStyle(fontSize: 10, color: primaryColor.withValues(alpha: 0.7), fontWeight: FontWeight.bold)))),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  for (var val in values)
                    Expanded(child: Center(child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
                        child: Center(child: Text(val, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: primaryColor)))))),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
