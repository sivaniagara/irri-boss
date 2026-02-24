import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../features/dashboard/data/models/live_message_model.dart';
import '../../../features/dashboard/domain/entities/livemessage_entity.dart';

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
  static const setSerialView = MqttMessageType('SETSERIALVIEW');

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

final FlutterLocalNotificationsPlugin notifications = FlutterLocalNotificationsPlugin();

abstract class MessageDispatcher {
  void onLiveUpdate(String deviceId, LiveMessageEntity liveMessage) {}
  void onFertilizerUpdate(String deviceId, String rawMessage) {}
  void onFertilizerLive(String deviceId, Map<String, dynamic> message) {}
  void onScheduleUpdate(String deviceId, String rawMessage) {}
  void onSmsNotification(String deviceId, String message, String description) {}
  void onPumpWaterPumpSettings(String deviceId, String message) {}
  void onScheduleOne(String deviceId, Map<String, dynamic> message) {}
  void onScheduleTwo(String deviceId, Map<String, dynamic> message) {}
  void onViewSettings(String deviceId, Map<String, dynamic> message) {}
}

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
    Map<String, dynamic> jsonObject = {};

    try {
      jsonObject = jsonDecode(mqttMsg);
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

    if (type == MqttMessageType.live || type == MqttMessageType.liveExtended || type == MqttMessageType.pumpLive) {
      late final LiveMessageEntity liveModel;

      if (type == MqttMessageType.live) {
        print('call live');
        liveModel = LiveMessageModel.fromLiveMessage(
          '$trimmedMsg,$cd,$ct,',
        );
      } else {
        print('call pump live');

        // LD06 or LD04 (Pump Live)
        liveModel = LiveMessageModel.fromPumpLiveMessage(
          'LD04,$trimmedMsg,$cd,$ct,$cl,',
          date: cd,
          time: ct,
        );
        print("liveModel => $liveModel");
      }


      if (kDebugMode) {
        print('Live message from MQTT: $liveModel');
      }

      await prefs.setString('LIVEMSG_$qrCode', '$trimmedMsg,$cd,$ct');

      dispatcher.onLiveUpdate(qrCode, liveModel);
    }
    if (type == MqttMessageType.fertilizerLive) {
      await prefs.setString('FERTLIVEMSG_$qrCode', '$trimmedMsg,$cd,$ct');
      dispatcher.onFertilizerLive(qrCode, jsonObject);
    }

    if(type == MqttMessageType.waterPumpSettings) {
      print("waterPumpSettings");
      dispatcher.onPumpWaterPumpSettings(qrCode, trimmedMsg);
    }

    if(type == MqttMessageType.scheduleOne) {
      print("schedule one");
      dispatcher.onScheduleOne(qrCode, jsonObject);
    }

    if(type == MqttMessageType.scheduleTwo) {
      print("schedule Two");
      dispatcher.onScheduleTwo(qrCode, jsonObject);
    }

    if(type == MqttMessageType.sms) {
      print("pump settings view");
      dispatcher.onViewSettings(qrCode, jsonObject);
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