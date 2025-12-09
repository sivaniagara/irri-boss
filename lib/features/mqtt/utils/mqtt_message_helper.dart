import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../dashboard/data/models/live_message_model.dart';
import '../../dashboard/domain/entities/livemessage_entity.dart';

class MqttMessageType {
  final String code;
  const MqttMessageType(this.code);

  static const live = MqttMessageType('LD01');
  static const liveExtended = MqttMessageType('LD06');
  static const fertilizerLive = MqttMessageType('LD02');
  static const pumpLive = MqttMessageType('LD04');
  static const scheduleOne = MqttMessageType('V01');
  static const scheduleTwo = MqttMessageType('V02');
  static const waterPumpSettings = MqttMessageType('V03');
  static const sms = MqttMessageType('SMS');
  static const normal = MqttMessageType('NLM');

  // Factory to get instance from string code
  static MqttMessageType? fromCode(String code) {
    return {
      'LD01': live,
      'LD06': liveExtended,
      'LD02': fertilizerLive,
      'LD04': pumpLive,
      'V01': scheduleOne,
      'V02': scheduleTwo,
      'V03': waterPumpSettings,
      'SMS': sms,
      'NLM': normal,
    }[code];
  }
}

class FaultSms {
  static String smsMessage(String msgCode) {
    final Map<String, String> faultMap = {
      '001': 'Low Battery Warning',
      '002': 'Pump Failure Detected',
      // Add all relevant fault codes and descriptions
    };
    return faultMap[msgCode] ?? 'Unknown Fault';
  }
}

// Notification plugin instance (initialize in main.dart)
final FlutterLocalNotificationsPlugin notifications = FlutterLocalNotificationsPlugin();

abstract class MessageDispatcher {
  void onLiveUpdate(String deviceId, LiveMessageEntity liveMessage);
  void onFertilizerUpdate(String deviceId, String rawMessage);
  void onScheduleUpdate(String deviceId, String rawMessage);
  void onSmsNotification(String deviceId, String message, String description);
}

class NoOpDispatcher implements MessageDispatcher {
  @override
  void onLiveUpdate(String deviceId, LiveMessageEntity liveMessage) {}

  @override
  void onFertilizerUpdate(String deviceId, String rawMessage) {}

  @override
  void onScheduleUpdate(String deviceId, String rawMessage) {}

  @override
  void onSmsNotification(String deviceId, String message, String description) {}
}

// MqttMessageHelper class (now pure: no DI, no context for UI)
class MqttMessageHelper {
  static Future<void> processMessage(
    String mqttMsg, {
    required MessageDispatcher dispatcher,
    BuildContext? context,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String msg = '';
    String typeStr = '';
    String cd = '';
    String ct = '';
    String qrCode = '';
    String cl = '';

    try {
      final Map<String, dynamic> jsonObject = jsonDecode(mqttMsg);
      msg = jsonObject['cM'] ?? '';
      typeStr = jsonObject['mC'] ?? '';
      if (!['NLM', 'V01', 'V02', 'V03', 'LD01', 'LD02', 'LD06'].contains(typeStr)) {
        cl = jsonObject['cL'] ?? '';
      }
      cd = jsonObject['cD'] ?? '';
      ct = jsonObject['cT'] ?? '';
      qrCode = jsonObject['cC'] ?? '';
    } catch (e) {
      if (kDebugMode) debugPrint('JSON Parse Error: $e');
      return;
    }

    String trimmedMsg = msg.trim();
    String repeat = prefs.getString('repeat') ?? '';
    String msgCode = trimmedMsg.length > 2 ? trimmedMsg.substring(2) : '';
    msgCode = msgCode.trim();

    LiveMessageEntity? liveModel;
    final type = MqttMessageType.fromCode(typeStr);

    if (type == MqttMessageType.live || type == MqttMessageType.liveExtended) {
      liveModel = LiveMessageModel.fromLiveMessage(trimmedMsg);
      if (kDebugMode) print('Live message from MQTT: $liveModel');
      await prefs.setString('LIVEMSG_$qrCode', '$trimmedMsg$cd,$ct');
      dispatcher.onLiveUpdate(qrCode, liveModel);
    }
    if (type == MqttMessageType.fertilizerLive) {
      await prefs.setString('FERTLIVEMSG_$qrCode', '$trimmedMsg,$cd,$ct');
      dispatcher.onFertilizerUpdate(qrCode, trimmedMsg);
    }

    // Switch for type-specific storage (use type?.code)
    if (type != null) {
      switch (type.code) {
        case 'LD04':
          await prefs.setString('PUMPLIVEMSG_$qrCode', '$cl,$trimmedMsg$cd,$ct,');
          break;
        case 'NLM':
          // Handle delayed action if needed
          break;
        case 'V01':
          await prefs.setString('SCHEDULE_MSG_ONE_$qrCode', '$trimmedMsg,$cd,$ct');
          dispatcher.onScheduleUpdate(qrCode, trimmedMsg);
          break;
        case 'V02':
          // Handle sub-cases for V02 as before
          if (trimmedMsg.contains('001;')) {
            await prefs.setString('SCHEDULE_MSG_TWO1_$qrCode', trimmedMsg);
          } else if (trimmedMsg.contains('005;')) {
            await prefs.setString('SCHEDULE_MSG_TWO2_$qrCode', trimmedMsg);
          } else if (trimmedMsg.contains('009;')) {
            await prefs.setString('SCHEDULE_MSG_TWO3_$qrCode', trimmedMsg);
          } else if (trimmedMsg.contains('013;')) {
            await prefs.setString('SCHEDULE_MSG_TWO4_$qrCode', trimmedMsg);
          } else if (trimmedMsg.contains('017;')) {
            await prefs.setString('SCHEDULE_MSG_TWO5_$qrCode', trimmedMsg);
          } else if (trimmedMsg.contains('021;')) {
            await prefs.setString('SCHEDULE_MSG_TWO6_$qrCode', trimmedMsg);
          } else if (trimmedMsg.contains('025;')) {
            await prefs.setString('SCHEDULE_MSG_TWO7_$qrCode', trimmedMsg);
          } else if (trimmedMsg.contains('029;')) {
            await prefs.setString('SCHEDULE_MSG_TWO8_$qrCode', trimmedMsg);
          } else if (trimmedMsg.contains('033;')) {
            await prefs.setString('SCHEDULE_MSG_TWO9_$qrCode', trimmedMsg);
          } else if (trimmedMsg.contains('037;')) {
            await prefs.setString('SCHEDULE_MSG_TWO10_$qrCode', trimmedMsg);
          }
          dispatcher.onScheduleUpdate(qrCode, trimmedMsg);
          break;
        case 'V03':
          await prefs.setString('WATER_PUMP_SETTINGS_VIEW_MSG_$qrCode', '$trimmedMsg,$cd,$ct');
          dispatcher.onScheduleUpdate(qrCode, trimmedMsg);
          break;
        default:
          break;
      }
    }

    // Process msgCode for description
    msgCode = msgCode.length >= 3 ? msgCode.substring(0, 3) : msgCode;
    String msgDesc = FaultSms.smsMessage(msgCode);

    if (msgDesc.isNotEmpty) {
      msg = trimmedMsg.length > 6 ? trimmedMsg.substring(6) : trimmedMsg;
    }

    await prefs.setBool('SEND_FLAG', true);

    // Handle SMS type
    if (type == MqttMessageType.sms && repeat != trimmedMsg) {
      String devicename = prefs.getString('DNAME_NOTIFICATION_$qrCode') ?? qrCode;
      await prefs.setString('repeat', trimmedMsg);
      await prefs.setString('SMS_BODY', trimmedMsg);
      await prefs.setBool('SMS_RECEIVED', true);

      dispatcher.onSmsNotification(qrCode, trimmedMsg, msgDesc);

      // Show toast if context provided
      if (context != null) {
        Fluttertoast.showToast(
          msg: msg,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }

      // Send notification
      String notificationTitle = msgDesc.isNotEmpty ? '$msgDesc $trimmedMsg' : trimmedMsg;
      await _sendNotification(notificationTitle, devicename, 'body');
    }

    // Delayed UI refresh (now configurable; pass to dispatcher if needed)
    Timer(const Duration(milliseconds: 300), () {
      // Dispatcher handles UI triggers now (e.g., via callbacks)
    });

    // Set IOT status
    await prefs.setBool('IOT_STATUS', true);
  }

  static Future<void> _sendNotification(String title, String body, String? payload) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'iot_channel_id',
      'IoT Notifications',
      channelDescription: 'Notifications for IoT device updates',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await notifications.show(0, title, body, platformDetails, payload: payload);
  }
}

class PublishMessageHelper {
  static const String key = "sentSms";
  static const Map<String, dynamic> requestLive = {key: "#live"};
  static Map<String, dynamic> settingsPayload(String value) => {key: value};
}