import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/core/theme/app_themes.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_app_bar.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/domain/entities/livemessage_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/data/models/program_view_model.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/mqtt/mqtt_manager.dart';
import '../../../../core/services/mqtt/publish_messages.dart';
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
      final ts = "${cachedProg["cT"] ?? ''} ${cachedProg["cD"] ?? ''}";
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
      final String currentTimestamp = "${message["cT"] ?? ''} ${message["cD"] ?? ''}";

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
      final String currentTimestamp = "${message["cT"] ?? ''} ${message["cD"] ?? ''}";

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
    return BlocBuilder<DashboardPageCubit, DashboardState>(
      builder: (context, state) {
        LiveMessageEntity? liveMessage;

        if (state is DashboardGroupsLoaded) {
          for (var groupControllers in state.groupControllers.values) {
            for (var controller in groupControllers) {
              if (controller.deviceId == widget.deviceId) {
                liveMessage = controller.liveMessage;
                break;
              }
            }
          }
        }

        if (_program == null && liveMessage != null && liveMessage.programName.isNotEmpty) {
          _program = ProgramViewModel.fromLiveMessage(liveMessage);
          _isLoading = false;
        }

        final bool isOnline = liveMessage?.motorOnOff == "1";
        final String lastSyncToDisplay = _lastSync ?? liveMessage?.lastsync ?? "--";

        return Scaffold(
          backgroundColor: AppThemes.scaffoldBackGround,
          appBar: CustomAppBar(
            title: "Program Preview",
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
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isOnline ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: isOnline ? Colors.green.shade400 : Colors.red.shade400, width: 1.5),
                ),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 10, color: isOnline ? Colors.green : Colors.red),
                    const SizedBox(width: 6),
                    Text(
                      isOnline ? "ONLINE" : "OFFLINE",
                      style: TextStyle(
                        color: isOnline ? Colors.green.shade700 : Colors.red.shade700,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: (_isLoading && _program == null && zoneList.isEmpty)
              ? const Center(child: CircularProgressIndicator())
              : _error != null && _program == null && zoneList.isEmpty
              ? _buildErrorState()
              : RefreshIndicator(
            onRefresh: () => _requestMessage(),
            child: _buildContent(liveMessage, isOnline, lastSyncToDisplay),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 80, color: Colors.red),
          const SizedBox(height: 16),
          Text(_error ?? "Unknown Error", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          const SizedBox(height: 24),
          ElevatedButton(
              onPressed: () => _requestMessage(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("RETRY")
          ),
        ],
      ),
    );
  }

  Widget _buildContent(LiveMessageEntity? liveMessage, bool isOnline, String lastSync) {
    if (_program == null) return const SizedBox.shrink();

    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildHeaderCard(liveMessage?.programName ?? _program?.programName ?? "1", lastSync),
        const SizedBox(height: 20),
        _buildSectionHeader("GENERAL STATUS", Icons.dashboard_outlined),
        const SizedBox(height: 10),
        _buildGeneralInfoSection(liveMessage),
        const SizedBox(height: 20),
        if (liveMessage != null) ...[
          _buildSectionHeader("SENSORS & LIVE DATA", Icons.sensors_rounded),
          const SizedBox(height: 10),
          _buildLiveSensorsSection(liveMessage),
          const SizedBox(height: 20),
        ],
        _buildRTCTimerSection(),
        const SizedBox(height: 20),
        _buildSectionHeader("ADJUSTMENTS", Icons.tune_rounded),
        const SizedBox(height: 10),
        _buildAdjustPercentSection(),
        const SizedBox(height: 20),
        _buildSectionHeader("FERTILIZER CONFIG", Icons.opacity_rounded),
        const SizedBox(height: 10),
        _buildFertilizerSection(liveMessage),
        const SizedBox(height: 20),
        _buildSectionHeader("TIMING PARAMETERS", Icons.timer_outlined),
        const SizedBox(height: 10),
        _buildPrePostSection(),
        const SizedBox(height: 20),
        if (zoneList.isNotEmpty) ...[
          _buildSectionHeader("ZONES DETAILS", Icons.layers_outlined),
          const SizedBox(height: 10),
          ...zoneList.map((z) => _buildZoneSection(z, liveMessage, isOnline)),
        ],
        const SizedBox(height: 60),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppThemes.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: Colors.grey.shade300)),
      ],
    );
  }

  Widget _buildHeaderCard(String programName, String lastSync) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(15), topRight: Radius.circular(15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "PROGRAM $programName".toUpperCase(),
                style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: 1),
              ),
              const SizedBox(height: 4),
              const Text("CONTROLLER PREVIEW", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppThemes.scaffoldBackGround,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text("LAST SYNC", style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(lastSync, style: const TextStyle(color: AppThemes.primaryColor, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGeneralInfoSection(LiveMessageEntity? liveMessage) {
    final String currentProg = liveMessage?.programName ?? _program?.programName ?? "";
    final String valveStatus = liveMessage?.valveOnOff ?? _program?.valveStatus ?? "0";
    final String irrigationMode = liveMessage?.modeOfOperation ?? _program?.irrigationMode ?? "";

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildDataCard("Current Program", currentProg, Icons.settings_applications_outlined)),
            const SizedBox(width: 10),
            Expanded(child: _buildDataCard("Valve", valveStatus == "1" ? "ON" : "OFF", Icons.settings_input_component_outlined, isBadge: true)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildDataCard("Irrigation", irrigationMode, Icons.water_drop_outlined)),
            const SizedBox(width: 10),
            Expanded(child: _buildDataCard("Dosing", _program?.dosingMode ?? "", Icons.science_outlined)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildDataCard("Decide Last", _program?.decideLast ?? "", Icons.history_rounded)),
            const SizedBox(width: 10),
            Expanded(child: _buildDataCard("FB Last", _program?.decideFeedbackLast ?? "", Icons.feedback_outlined)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildDataCard("Delay Valve", _program?.delayValve ?? "", Icons.hourglass_bottom_rounded)),
            const SizedBox(width: 10),
            Expanded(child: _buildDataCard("FB Valve", _program?.feedbackTime ?? "", Icons.timer_outlined)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildDataCard("Drip Cyc Rst", _program?.dripCycRst == "1" ? "ON" : "OFF", Icons.loop_rounded, isBadge: true)),
            const SizedBox(width: 10),
            Expanded(child: _buildDataCard("Timer", _program?.dripCycRstTime ?? "00:00:00", Icons.access_time_rounded)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildDataCard("Zone Cyc Rst", _program?.zoneCycRst == "1" ? "ON" : "OFF", Icons.refresh_rounded, isBadge: true)),
            const SizedBox(width: 10),
            Expanded(child: _buildDataCard("Start frm", "prg: ${_program?.programStartNumber}, zone: 1", Icons.play_circle_outline_rounded, isSmallValue: true)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildDataCard("Sump", _program?.sumpStatus == "1" ? "ON" : "OFF", Icons.waves_rounded, isBadge: true, isNegative: true)),
            const SizedBox(width: 10),
            Expanded(child: _buildDataCard("Drip Sump Rst", _program?.dripSumpStatus == "1" ? "ON" : "OFF", Icons.restart_alt_rounded, isBadge: true, isNegative: true)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildDataCard("Day Count RTC", _program?.dayCountRtcTimer ?? "00:00:00", Icons.calendar_today_outlined)),
            const SizedBox(width: 10),
            Expanded(child: _buildDataBadgeRow("Skip Days", _program?.skipDays ?? "0", _program?.skipDaysStatus == "1")),
          ],
        ),
      ],
    );
  }

  Widget _buildLiveSensorsSection(LiveMessageEntity live) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildDataCard("R-Y-B Voltage", "${live.rVoltage}v | ${live.yVoltage}v | ${live.bVoltage}v", Icons.electrical_services_rounded, isSmallValue: true)),
            const SizedBox(width: 10),
            Expanded(child: _buildDataCard("R-Y-B Current", "${live.rCurrent}A | ${live.yCurrent}A | ${live.bCurrent}A", Icons.bolt_rounded, isSmallValue: true)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildDataCard("Pressure In/Out", "${live.prsIn} / ${live.prsOut} bar", Icons.compress_rounded)),
            const SizedBox(width: 10),
            Expanded(child: _buildDataCard("Flow Rate", "${live.flowRate} m³/h", Icons.speed_rounded)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildDataCard("EC / PH", "${live.ec} / ${live.ph}", Icons.science_outlined)),
            const SizedBox(width: 10),
            Expanded(child: _buildDataCard("Moisture 1/2", "${live.moisture1}% / ${live.moisture2}%", Icons.water_drop_outlined)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildDataCard("Well Level", "${live.wellPercent}%", Icons.waves_rounded)),
            const SizedBox(width: 10),
            Expanded(child: _buildDataCard("Signal/Bat", "${live.signal}% / ${live.batVolt}v", Icons.signal_cellular_alt_rounded)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildDataCard("Today Flow", "${live.flowToday} m³", Icons.summarize_outlined)),
            const SizedBox(width: 10),
            Expanded(child: _buildDataCard("Today RunTime", live.runTimeToday, Icons.history_toggle_off_rounded)),
          ],
        ),
      ],
    );
  }

  Widget _buildRTCTimerSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(15), topRight: Radius.circular(15)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppThemes.scaffoldBackGround,
              borderRadius: const BorderRadius.only(topRight: Radius.circular(15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.schedule_rounded, color: Colors.black87, size: 20),
                    SizedBox(width: 8),
                    Text("RTC Timer Configuration", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                _buildBadge(_program?.rtcOnOff == "1" ? "ON" : "OFF", isNegative: _program?.rtcOnOff != "1", elevated: false),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const SizedBox(width: 44),
                Expanded(child: Center(child: Text("ON TIME", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey.shade600, letterSpacing: 0.5)))),
                Expanded(child: Center(child: Text("OFF TIME", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey.shade600, letterSpacing: 0.5)))),
              ],
            ),
          ),
          ...List.generate(_program!.rtcTimers.length, (index) {
            final times = _program!.rtcTimers[index].split(';');
            final onTime = times.isNotEmpty ? times[0] : "00:00";
            final offTime = times.length > 1 ? times[1] : "00:00";
            return Padding(
              padding: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppThemes.scaffoldBackGround,
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: Text("${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppThemes.primaryColor))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _buildValueBox(onTime, highlighted: false)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildValueBox(offTime, highlighted: false)),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildAdjustPercentSection() {
    final adjust = _program?.adjustPercent ?? ["100", "100", "100", "100"];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(15), topRight: Radius.circular(15)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          _buildColumnLabelValue("Time (%)", adjust.isNotEmpty ? adjust[0] : "100", Icons.access_time_filled_rounded),
          _buildColumnLabelValue("Flow (%)", adjust.length > 1 ? adjust[1] : "100", Icons.speed_rounded),
          _buildColumnLabelValue("Moist (%)", adjust.length > 2 ? adjust[2] : "100", Icons.water_rounded),
          _buildColumnLabelValue("Fert (%)", adjust.length > 3 ? adjust[3] : "100", Icons.science_rounded),
        ],
      ),
    );
  }

  Widget _buildFertilizerSection(LiveMessageEntity? liveMessage) {
    // Corrected: Always use _program data for configuration view.
    // LiveMessage data (fertStatus/fertValues) represents real-time activity, not saved config.
    final List<String> currentFertStatus = _program?.fertilizerStatus ?? List.filled(6, "0");
    final List<String> currentFertRates = _program?.fertilizerRates ?? List.filled(6, "00:00");

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(15), topRight: Radius.circular(15)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Row(
            children: List.generate(6, (i) => Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppThemes.scaffoldBackGround,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(child: Text("F${i + 1}", style: const TextStyle(color: AppThemes.primaryColor, fontSize: 10, fontWeight: FontWeight.bold))),
              ),
            )),
          ),
          const SizedBox(height: 12),
          _buildFertRow("STATUS", (i) {
            final val = i < currentFertStatus.length ? currentFertStatus[i] : "0";
            return _buildBadge(val == "1" ? "ON" : "OFF", isNegative: val != "1", small: true);
          }),
          const SizedBox(height: 10),
          _buildFertRow("RATE", (i) {
            final val = i < currentFertRates.length ? currentFertRates[i] : "00:00";
            return _buildValueBox(val, small: true);
          }),
          const SizedBox(height: 10),
          _buildFertRow("FLOW", (i) {
            final val = (_program != null && i < _program!.ventFlows.length) ? _program!.ventFlows[i] : "0.0";
            return _buildValueBox(val, small: true);
          }),
        ],
      ),
    );
  }

  Widget _buildFertRow(String label, Widget Function(int) builder) {
    return Row(
      children: [
        SizedBox(width: 60, child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey.shade600))),
        ...List.generate(6, (i) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: builder(i),
          ),
        )),
      ],
    );
  }

  Widget _buildPrePostSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildDataCard("Pre Quantity", _program?.preQty ?? "0.00", Icons.keyboard_double_arrow_right_rounded)),
            const SizedBox(width: 10),
            Expanded(child: _buildDataCard("Post Quantity", _program?.postQty ?? "0.00", Icons.keyboard_double_arrow_left_rounded)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildDataCard("Pre Time", _program?.preTime ?? "0.00:0", Icons.first_page_rounded)),
            const SizedBox(width: 10),
            Expanded(child: _buildDataCard("Post Time (%)", _program?.postTimePercent ?? "0.00:0", Icons.last_page_rounded)),
          ],
        ),
      ],
    );
  }

  Widget _buildZoneSection(ZoneViewModel z, LiveMessageEntity? liveMessage, bool isOnline) {
    final bool isRunning = isOnline && liveMessage != null &&
        _normalize(liveMessage.zoneNo) == _normalize(z.zoneNumber);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isRunning ? Colors.green.shade50 : Colors.white,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(15), topRight: Radius.circular(15)),
        border: isRunning ? Border.all(color: Colors.green.shade200, width: 1.5) : Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isRunning ? Colors.green.shade100 : AppThemes.scaffoldBackGround,
              borderRadius: const BorderRadius.only(topRight: Radius.circular(15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: AppThemes.primaryColor, shape: BoxShape.circle),
                      child: const Icon(Icons.grid_view_rounded, color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 10),
                    Text("Zone ${z.zoneNumber}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.5)),
                  ],
                ),
                if (isRunning)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)),
                    child: const Text("RUNNING", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10)),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildZoneInfoChip(Icons.timer_outlined, "TIME", isRunning ? liveMessage!.zoneRemainingTime : z.irrigationTime),
                    const SizedBox(width: 8),
                    _buildZoneInfoChip(Icons.water_drop_outlined, "FLOW", z.irrigationFlow),
                    const SizedBox(width: 8),
                    Expanded(child: _buildZoneInfoChip(Icons.settings_input_hdmi_rounded, "VALVES", z.activeValves.split(':').where((v) => v != "V0").join(','))),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSmallLabel("FERTILIZER TIMERS"),
                const SizedBox(height: 6),
                Row(
                  children: List.generate(6, (i) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: _buildValueBox(z.fertTimers.length > i ? z.fertTimers[i] : "00:00", small: true, highlighted: isRunning),
                    ),
                  )),
                ),
                const SizedBox(height: 16),
                _buildSmallLabel("FERTILIZER FLOWS"),
                const SizedBox(height: 6),
                Row(
                  children: List.generate(6, (i) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: _buildValueBox(z.fertFlows.length > i ? z.fertFlows[i] : "0", small: true, highlighted: isRunning),
                    ),
                  )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallLabel(String text) {
    return Text(text, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey.shade600, letterSpacing: 0.5));
  }

  Widget _buildZoneInfoChip(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 10, color: AppThemes.primaryColor),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.grey.shade600)),
            ],
          ),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.black87)),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildDataCard(String label, String value, IconData icon, {bool isBadge = false, bool isNegative = false, bool isSmallValue = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(15), topRight: Radius.circular(15)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))
        ],
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppThemes.primaryColor),
              const SizedBox(width: 6),
              Expanded(child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey.shade600, letterSpacing: 0.2))),
            ],
          ),
          const SizedBox(height: 8),
          isBadge
              ? _buildBadge(value, isNegative: (value == "OFF" || isNegative))
              : _buildValueBox(value, small: isSmallValue),
        ],
      ),
    );
  }

  Widget _buildDataBadgeRow(String label, String value, bool status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(15), topRight: Radius.circular(15)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))
        ],
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.skip_next_rounded, size: 14, color: AppThemes.primaryColor),
              const SizedBox(width: 6),
              Expanded(child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey.shade600))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
              _buildBadge(status ? "ON" : "OFF", isNegative: !status, small: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildValueBox(String value, {bool small = false, bool highlighted = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: small ? 4 : 8),
      decoration: BoxDecoration(
        color: highlighted ? Colors.green.shade50 : AppThemes.scaffoldBackGround.withOpacity(0.5),
        borderRadius: BorderRadius.circular(small ? 8 : 10),
        border: Border.all(color: highlighted ? Colors.green.shade200 : Theme.of(context).colorScheme.outline.withOpacity(0.2), width: 1),
      ),
      child: Center(
        child: Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: small ? 10 : 13,
            color: highlighted ? Colors.green.shade900 : Colors.black87,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, {bool isNegative = false, bool small = false, bool elevated = false}) {
    final color = isNegative ? Colors.red.shade600 : Colors.green.shade600;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: small ? 8 : 12, vertical: small ? 3 : 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(small ? 6 : 10),
        boxShadow: elevated ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))] : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: small ? 9 : 11,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildColumnLabelValue(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 14, color: AppThemes.primaryColor),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.grey.shade600)),
          const SizedBox(height: 6),
          _buildValueBox(value, small: true),
        ],
      ),
    );
  }
}
