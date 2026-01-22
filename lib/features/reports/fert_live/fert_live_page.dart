import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glassy_wrapper.dart';
import '../../../../core/services/mqtt/mqtt_manager.dart';
import '../../../../core/services/mqtt/publish_messages.dart';
import '../../../core/di/injection.dart';
import '../../../core/widgets/no_data.dart';
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

  // This will hold the current parsed state
  FertilizerLiveState? fertilizerState;

  @override
  void initState() {
    super.initState();
    _dispatcher = FertilizerLiveDispatcher();

    _dispatcher.onFertLiveReceived = (deviceId, rawMessage) {
      final newState = fertilizerLiveStateFromRaw(rawMessage);

      // Update UI safely
      if (mounted) {
        setState(() {
          fertilizerState = newState;
        });
      }
    };

     _startAutoRefresh();

     _requestLiveData();
  }

  void _requestLiveData() {
    print('_requestLiveData:${widget.deviceId}');
    final publishMessage = jsonEncode(PublishMessageHelper.requestFertilizerLive);
    sl.get<MqttManager>().publish(widget.deviceId, publishMessage); // or FertilizerLiveState.deviceId
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 40), (_) {
      _requestLiveData();
    });
  }

  @override
  void dispose() {
    _dispatcher.onFertLiveReceived = null;
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If no data yet, show loading or placeholder
    if (fertilizerState == null) {
      return  GlassyWrapper(
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Fertilizer Live"),
            leading: const BackButton(color: Colors.black),
          ),
          body: Center(child: noData),
        ),
      );
    }

    return GlassyWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Fertilizer Live"),
          leading: const BackButton(color: Colors.black),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                _lastSync(),
                _rtcStatus(),
                _fertilizerButtons(),
                _tankLevels(),
                _phEcPressure(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _lastSync() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        "Last Sync: ${fertilizerState?.lastSyncTime ?? '-'} || ${fertilizerState?.lastSyncDate ?? '-'}",
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _rtcStatus() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          fertilizerState?.motorOn == true
              ? 'assets/images/common/ui_motor.gif'
              : fertilizerState?.motorOn == false
              ? 'assets/images/common/live_motor_off.png'
              : 'assets/images/common/ui_motor_yellow.png',
          width: 60,
          height: 60,
        ),
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.lightGreen,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                "VRB:${fertilizerState?.vrb}  AMP:${fertilizerState?.amp}",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                fertilizerState?.motorOn == true ? "Motor ON" : "Motor OFF",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Image.asset(
          fertilizerState?.motorOn == true
              ? 'assets/images/common/ui_motor.gif'
              : fertilizerState?.motorOn == false
              ? 'assets/images/common/live_motor_off.png'
              : 'assets/images/common/ui_motor_yellow.png',
          width: 60,
          height: 60,
        ),
      ],
    );
  }

  Widget _fertilizerButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: List.generate(6, (index) {
          final active = fertilizerState?.fertilizerActive[index] ?? false;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.all(4),
              height: 45,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "F${index + 1}",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _tankLevels() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(6, (index) {
          return _tankMeter(fertilizerState!.tankLevels[index]);
        }),
      ),
    );
  }

  Widget _tankMeter(int value) {
    return Column(
      children: [
        Container(
          height: 200,
          width: 25,
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: value / 5,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text("$value"),
      ],
    );
  }

  Widget _phEcPressure() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _valueBox("PH", fertilizerState!.ph.toString()),
          _valueBox("EC", fertilizerState!.ec.toString()),
          _valueBox("Pressure", fertilizerState!.pressure.toString()),
        ],
      ),
    );
  }

  Widget _valueBox(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontSize: 18, color: Colors.blue)),
      ],
    );
  }

}