import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:niagara_smart_drip_irrigation/core/theme/app_themes.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glass_effect.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/data/models/program_view_model.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/mqtt/mqtt_manager.dart';
import '../../../../core/services/mqtt/publish_messages.dart';
import '../../../../core/widgets/glassy_wrapper.dart';
import '../../utils/program_preview_dispatcher.dart';

class ProgramPreviewPage extends StatefulWidget {
  final String deviceId;
  const ProgramPreviewPage({super.key, required this.deviceId});

  @override
  State<ProgramPreviewPage> createState() => _ProgramPreviewPageState();
}

class _ProgramPreviewPageState extends State<ProgramPreviewPage> {
  ProgramViewModel? _program;

  List<ZoneViewModel> zoneList = <ZoneViewModel>[];

  String? _lastSync;
  bool _isLoading = true;
  String? _error;

  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _setupDispatcher();
    _requestMessage(widget.deviceId);
  }

  void _requestMessage(String deviceId) {
    if (mounted) {
      setState(() {
        // _program = null;
        // zoneList.clear();
        _isLoading = true;
        _error = null;
        _lastSync = null;
      });
    }
    _timeoutTimer?.cancel();

    _timeoutTimer = Timer(const Duration(seconds: 10), () {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
          _error = "Timeout: No response from device";
        });
      }
    });

    final publishMessage = jsonEncode(PublishMessageHelper.requestProgramPreview);
    sl.get<MqttManager>().publish(deviceId, publishMessage);
  }

  void _setupDispatcher() {
    final dispatcher = sl.get<ProgramPreviewDispatcher>();

    String lastProgramRaw = '';
    String lastZoneRaw = '';

    dispatcher.onProgramReceived = null;
    dispatcher.onZoneReceived = null;

    dispatcher.onProgramReceived = (deviceId, message) {
      if (deviceId != widget.deviceId) return;

      final String? mC = message["mC"] as String?;
      final String rawMessage = (message["cM"] ?? '') as String;
      if (rawMessage.isEmpty) return;

      final String currentTimestamp = "${message["cD"] ?? ''} ${message["cT"] ?? ''}";

      if (mC == "V01") {
        zoneList.clear();
        if (rawMessage == lastProgramRaw) return;
        try {
          final program = ProgramViewModel.fromRawString(rawMessage);
          lastProgramRaw = rawMessage;
          if (mounted) {
            setState(() {
              _program = program;
              if (currentTimestamp.isNotEmpty) _lastSync = currentTimestamp;
              _isLoading = false;
              _error = null;
            });
            _timeoutTimer?.cancel();
          }
        } catch (e) {
          print("Program parse error: $e");
          if (mounted) setState(() => _error = "Failed to parse program");
          _timeoutTimer?.cancel();
        }
      }
      else if (mC == "V02") {
        if (rawMessage == lastZoneRaw) return;

        try {
          zoneList.add(ZoneViewModel.fromRawString(rawMessage.replaceAll(",", "")));
          if (mounted) {
            setState(() {
              if (currentTimestamp.isNotEmpty) _lastSync = currentTimestamp;
              _isLoading = false;
              _error = null;
            });
          }
        } catch (e) {
          print("Zone parse error: $e | Raw: $rawMessage");
        }
      }
    };

    dispatcher.onZoneReceived = dispatcher.onProgramReceived;
  }

  @override
  void dispose() {
    final dispatcher = sl.get<ProgramPreviewDispatcher>();
    dispatcher.onProgramReceived = null;
    dispatcher.onZoneReceived = null;
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return GlassyWrapper(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(title: const Text("Program Preview")),
          body: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_error != null) {
      return GlassyWrapper(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(title: const Text("Program Preview")),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(_error!, style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _error = null;
                    });
                    _requestMessage(widget.deviceId);
                  },
                  child: const Text("Retry"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_program == null) {
      return GlassyWrapper(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(title: const Text("Program Preview")),
          body: const Center(
            child: Text("No program data received yet", style: TextStyle(color: Colors.white70)),
          ),
        ),
      );
    }

    return GlassyWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(_program!.programName),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Last Sync:", style: TextStyle(fontSize: 12)),
                  Text(_lastSync ?? "-"),
                ],
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async => _requestMessage(widget.deviceId),
          child: SingleChildScrollView(
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
                        _buildInfoCard(label: "Program Name", value: _program!.programName),
                        _buildInfoCard(label: "Irrigation Mode", value: _program!.irrigationMode),
                        _buildInfoCard(label: "Valve Status", value: _program!.valveStatus, isBoolean: true),
                        _buildInfoCard(label: "Dosing Mode", value: _program!.dosingMode),
                        _buildInfoCard(label: "Decide Last", value: _program!.decideLast),
                        _buildInfoCard(label: "Feedback Last", value: _program!.decideFeedbackLast),
                        _buildInfoCard(label: "Delay Valve", value: _program!.delayValve),
                        _buildInfoCard(label: "Feedback Time", value: _program!.feedbackTime),
                        _buildInfoCard(label: "Drip Cyclic Restart", value: _program!.dripCycRst, isBoolean: true),
                        _buildInfoCard(label: "Drip Restart Timer", value: _program!.dripCycRstTime),
                        _buildInfoCard(label: "Zone Cyclic Restart", value: _program!.zoneCycRst, isBoolean: true),
                        _buildInfoCard(
                            label: "Start from",
                            value: "Program:- ${_program!.programStartNumber.split(":")[0]} , Zone:- ${_program!.programStartNumber.split(":")[1]}"
                        ),
                        _buildInfoCard(label: "Sump", value: _program!.sumpStatus, isBoolean: true),
                        _buildInfoCard(label: "Drip Sump Restart", value: _program!.dripSumpStatus, isBoolean: true),
                        _buildInfoCard(label: "Day count RTC", value: _program!.dayCountRtcTimer),
                        _buildInfoCard(label: "Skip Days", value: _program!.skipDays, booleanValue: _program!.skipDaysStatus == "1"),
                      ],
                    ),
                  ],
                ),
                ConfigSection(
                  title: "RTC Timers",
                  children: [
                    ConfigRow(label: "RTC Timer", value: _program!.rtcOnOff, isBoolean: true,),
                    Row(
                      children: const [
                        SizedBox(width: 120),
                        Expanded(child: Center(child: Text("On Time", style: TextStyle(fontWeight: FontWeight.bold)))),
                        Expanded(child: Center(child: Text("Off Time", style: TextStyle(fontWeight: FontWeight.bold)))),
                      ],
                    ),
                    ...List.generate(_program!.rtcTimers.length, (i) =>
                        ConfigRow(
                          label: "Timer ${i + 1}",
                          value: _program!.rtcTimers[i],
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
                      values: _program!.adjustPercent,
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
                        for(int i = 0; i < _program!.fertilizerRates[0].split(",")[0].split(":").length; i++)
                          Expanded(child: Center(child: Text("F${i+1}", style: TextStyle(fontWeight: FontWeight.bold)))),
                      ],
                    ),
                    ...List.generate(3, (i) =>
                        ConfigRow(
                          label: ["Fertilizer", "Fert Rate", "Vent Flow"][i],
                          value: _program!.fertilizerRates[i],
                          splitBy: ":",
                        ),
                    ),
                    SizedBox(height: 10,),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildContainer(child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Pre Quantity: ${_program!.preQty}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        )),
                        _buildContainer(child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Post Quantity: ${_program!.postQty}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        )),
                        _buildContainer(child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Pre Time: ${_program!.preTime}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        )),
                        _buildContainer(child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Post Time(%): ${_program!.postTimePercent}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        )),
                       /* _buildInfoCard(label: "Pre Quantity", value: _program!.preQty),
                        _buildInfoCard(label: "Post Quantity", value: _program!.postQty),
                        _buildInfoCard(label: "Pre Time", value: _program!.preTime),
                        _buildInfoCard(label: "Post Time(%)", value: _program!.postTimePercent),*/
                      ],
                    ),
                  ],
                ),
                ...zoneList.map((zone) => ConfigSection(
                  title: "Zone ${zone.zoneNumber}",
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildContainer(child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Irrigation Time: ${zone.irrigationTime}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        )),
                        _buildContainer(child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Flow: ${zone.irrigationFlow}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        )),
                        _buildContainer(child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Valves: ${zone.activeValves.split(':').join(', ')}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        )),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text("Fertilizer Timer", style: const TextStyle(fontWeight: FontWeight.w500)),
                    ),
                    ConfigRow(value: zone.fertigationTimes, splitBy: "-"),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text("Fertilizer Flow", style: const TextStyle(fontWeight: FontWeight.w500)),
                    ),
                    ConfigRow(value: zone.fertigationFlows, splitBy: ":"),
                  ],
                )),
              ],
            ),
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