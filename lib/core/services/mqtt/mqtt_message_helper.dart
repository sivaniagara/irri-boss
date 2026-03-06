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
    }[code.trim().toUpperCase()];
  }
}

class FaultSms {
  static String smsMessage(String smsCode) {
    switch (smsCode) {
      case "000":
        return "";

      case "001":
        return "MOTOR ON  3 PHASE";

      case "002":
        return "MOTOR ON  2 PHASE";

      case "003":
        return "MOTOR OFF";

      case "004":
      case "005":
        return "MOTOR ON BECAUSE OF CYCLIC ON TIME";

      case "006":
      case "007":
        return "MOTOR ON BECAUSE OF AUTO MOBILE SWITCH";

      case "008":
      case "009":
        return "MOTOR ON BECAUSE OF GREEN RTC";

      case "010":
      case "011":
        return "MOTOR ON BECAUSE OF RTC ON TIME";

      case "012":
      case "013":
        return "MOTOR ON BECAUSE OF UPPER TANK EMPTY";

      case "014":
      case "015":
        return "MOTOR ON BECAUSE OF SUMP TANK FULL";

      case "016":
      case "017":
        return "MOTOR ON BECAUSE OF RESTART TIMER";

      case "018":
      case "019":
        return "MOTOR ON BECAUSE OF TARGET";

      case "020":
        return "MOTOR OFF  3 PHASE";

      case "021":
        return "MOTOR OFF  2 PHASE";

      case "022":
        return "MOTOR OFF BECAUSE OF UPPER TANK FULL";

      case "023":
        return "MOTOR OFF BECAUSE OF LOWER TANK EMPTY";

      case "024":
        return "MOTOR OF BECAUSE OF MOBILE AUTO SWITCH";

      case "025":
      case "026":
        return "MOTOR OFF BECAUSE OF DRY RUN";

      case "027":
        return "MOTOR OFF BECAUSE OF CYCLIC TRIP";

      case "028":
        return "MOTOR OFF BECAUSE OF ZONE CYCLLE COMPLETED";

      case "029":
        return "MOTOR OFF BECAUSE OF GRTC PROGRAM TIME REACHED";

      case "030":
        return "MOTOR OFF BECAUSE OF RTC PROGRAM";

      case "031":
        return "POWER ON WITH 3 PHASE, AUTO RESTART ON";

      case "032":
        return "AUTO RESTART OFF";

      case "033":
        return "POWER ON WITH 3 PHASE";

      case "034":
        return "POWER ON WITH 2 PHASE, AUTO RESTART ON";

      case "035":
        return "POWER ON WITH 2 PHASE, AUTO RESTART OFF";

      case "036":
        return "POWER ON WITH 2 PHASE";

      case "037":
      case "038":
      case "039":
        return "POWER OFF";

      case "040":
        return "MOTOR OFF 3 PHASE";

      case "041":
        return "MOTOR OFF 2 PHASE";

      case "042":
        return "MOTOR OFF POWER ON";

      case "043":
        return "MOTOR OFF POWER OF";

      case "044":
      case "045":
        return "ZONE OPEN";

      case "046":
        return "FERTILIZER PUMP";

      case "047":
        return "NIGHT LIGHT ON";

      case "048":
      case "049":
        return "NIGHT LIGHT OFF";

      case "050":
        return "GREEN LIGHT OFF";

      case "051":
        return "GREEN LIGHT ON BECAUSE OF CYCLIC TIMER";

      case "052":
        return "GREEN LIGHT OFF BECAUSE OF CYCLIC TIMER";

      case "053":
        return "GREEN FAN ON BECAUSE OF RTC";

      case "054":
        return "GREEN FAN OFF BECAUSE OF RTC";

      case "055":
        return "GREEN FAN ON BECAUSE OF CYCLIC TIMER";

      case "056":
        return "GREEN FAN OFF BECAUSE OF CYCLIC TIMER";

      case "057":
        return "GREEN FOG ON BECAUSE OF RTC,DT";

      case "058":
        return "GREEN FOG OFF BECAUSE OF RTC,DT";

      case "059":
      case "060":
        return "GREEN FOG VALVE";

      case "061":
        return "GREEN FOG CYCLE COMPLETED";

      case "062":
        return "GREEN FOG CYCLE RESET BACAUSE OF CYCLIC TIMER";

      case "063":
      case "064":
        return "STANDALONE ZONE :";

      case "065":
        return "MOTOR OFF BECAUSE OF STARTER TRIP MOTOR STARTED WITH 3 PHASE";

      case "066":
        return "MOTOR CAN'T START";

      case "067":
        return "MOTOR OFF BECAUSE OF PRESSURE SWITCH OPEN";

      case "068":
        return "MOTOR OFF BECAUSE OF MAXIMUM RUN TIME REACHED";

      case "070":
        return "MOTOR 2 ON";

      case "071":
        return "MOTOR 2 OFF";

    // -----------------------
    // Fault Messages 101–141
    // -----------------------

      case "101":
      case "102":
        return "MOTOR OFF BECAUSE OF STARTER TRIP";

      case "105":
      case "106":
        return "MOTOR OFF BECAUSE OF OVER LOAD";

      case "107":
        return "MOTOR OFF BECAUSE OF SINGLE PHASEING";

      case "108":
        return "MOTOR OFF BECAUSE OF REVERSE PHASEING";

      case "110":
      case "111":
        return "MOTOR OFF BECAUSE OF LOW VOLTAGE";

      case "112":
      case "113":
        return "MOTOR OFF BECAUSE OF HIGH VOLTAGE";

      case "114":
        return "ZONE SKIPPED BECAUSE OF NO FEEDBACK";

      case "116":
      case "117":
        return "MOTOR OFF BECAUSE OF DRY RUN";

      case "119":
      case "120":
        return "MOTOR OFF BECAUSE OF HIPRESSURE";

      case "139":
        return "ZONE NOT OPEN PROPERLY";

      case "140":
        return "ZONE NOT CLOSED PROPERLY";

      default:
        return "SETTINGS MSG";
    }
  }
}

final FlutterLocalNotificationsPlugin notifications = FlutterLocalNotificationsPlugin();

abstract class MessageDispatcher {
  void onLiveUpdate(String deviceId, LiveMessageEntity liveMessage, {String? date, String? time, String? msgDesc, String? fullMsg}) {}
  void onFertilizerUpdate(String deviceId, String rawMessage) {}
  void onFertilizerLive(String deviceId, Map<String, dynamic> message) {}
  void onScheduleUpdate(String deviceId, String rawMessage) {}
  void onSmsNotification(String deviceId, String message, String description) {}
  void onPumpWaterPumpSettings(String deviceId, String message) {}
  void onScheduleOne(String deviceId, Map<String, dynamic> message) {}
  void onScheduleTwo(String deviceId, Map<String, dynamic> message) {}
  void onViewSettings(String deviceId, Map<String, dynamic> message) {}
  void onServerTimeUpdate(String deviceId, {String? date, String? time}) {}
}


class MqttMessageHelper {
  static Future<void> processMessage(
      String mqttMsg, {
        required MessageDispatcher dispatcher,
        BuildContext? context,
      }) async {
    Map<String, dynamic> jsonObject = {};
    String qrCode = '';
    String typeStr = '';

    try {
      jsonObject = jsonDecode(mqttMsg);
      typeStr = (jsonObject['mC'] ?? '').toString().trim();
      qrCode = (jsonObject['cC'] ?? '').toString().trim();

      if (kDebugMode) {
        print('MQTT Message Received: Type=$typeStr Device=$qrCode');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('MQTT JSON Parse Error: $e | Raw: $mqttMsg');
      return;
    }

    final String msg = (jsonObject['cM'] ?? '').toString();
    final String cd = (jsonObject['cD'] ?? '').toString();
    final String ct = (jsonObject['cT'] ?? '').toString();
    String cl = (jsonObject['cL'] ?? '').toString();

    String trimmedMsg = msg.trim();
    String msgCode = trimmedMsg.length > 2 ? trimmedMsg.substring(2) : '';
    msgCode = msgCode.trim();
    msgCode = msgCode.length >= 3 ? msgCode.substring(0, 3) : msgCode;
    String msgDesc = FaultSms.smsMessage(msgCode);

    final type = MqttMessageType.fromCode(typeStr);

    // ✅ UPDATE SERVER TIME FOR EVERY PACKET
    if (cd.isNotEmpty && ct.isNotEmpty) {
      dispatcher.onServerTimeUpdate(qrCode, date: cd, time: ct);
    }

    if (type == MqttMessageType.live || type == MqttMessageType.liveExtended || type == MqttMessageType.pumpLive) {
      LiveMessageEntity? liveModel;
      String formattedSync = '$ct\n$cd';
      if (type == MqttMessageType.live) {
        liveModel = LiveMessageModel.fromLiveMessage(trimmedMsg, externalLastSync: formattedSync);
      } else {
        // LD04
        liveModel = LiveMessageModel.fromLiveMessage(trimmedMsg, typeCode: 'LD04', externalLastSync: formattedSync);
      }
      // Fire-and-forget storage write to avoid blocking the message stream
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('LIVEMSG_$qrCode', '$trimmedMsg,$cd,$ct');
      });

      // Update Dashboard with ALL fields from MQTT
      dispatcher.onLiveUpdate(
          qrCode,
          liveModel,
          date: cd,
          time: ct,
          msgDesc: msgDesc,
          fullMsg: trimmedMsg
      );
    }

    if (type == MqttMessageType.fertilizerLive) {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('FERTLIVEMSG_$qrCode', '$trimmedMsg,$cd,$ct');
      });
      dispatcher.onFertilizerUpdate(qrCode, trimmedMsg);
      dispatcher.onFertilizerLive(qrCode, jsonObject);
    }

    if(type == MqttMessageType.waterPumpSettings) {
      dispatcher.onPumpWaterPumpSettings(qrCode, trimmedMsg);
    }

    if(type == MqttMessageType.scheduleOne) {
      dispatcher.onScheduleOne(qrCode, jsonObject);
    }

    if(type == MqttMessageType.scheduleTwo) {
      dispatcher.onScheduleTwo(qrCode, jsonObject);
    }

    if(type == MqttMessageType.sms) {
      dispatcher.onViewSettings(qrCode, jsonObject);
    }

    String displayMsg = trimmedMsg.length > 6 ? trimmedMsg.substring(6) : trimmedMsg;

    SharedPreferences.getInstance().then((prefs) async {
      await prefs.setBool('SEND_FLAG', true);
      String repeat = prefs.getString('repeat') ?? '';

      if (type == MqttMessageType.sms && repeat != trimmedMsg) {
        String devicename = prefs.getString('DNAME_NOTIFICATION_$qrCode') ?? qrCode;
        await prefs.setString('repeat', trimmedMsg);
        await prefs.setString('SMS_BODY', trimmedMsg);
        await prefs.setBool('SMS_RECEIVED', true);

        dispatcher.onSmsNotification(qrCode, trimmedMsg, msgDesc);

        if (context != null) {
          Fluttertoast.showToast(msg: displayMsg, backgroundColor: Colors.black87, textColor: Colors.white);
        }

        String notificationTitle = msgDesc.isNotEmpty ? '$msgDesc $trimmedMsg' : trimmedMsg;
        await _sendNotification(notificationTitle, devicename, 'body');
      }
      await prefs.setBool('IOT_STATUS', true);
    });
  }

  static Future<void> _sendNotification(String title, String body, String? payload) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'iot_channel_id', 'IoT Notifications',
        importance: Importance.high, priority: Priority.high, icon: '@mipmap/ic_launcher'
    );
    await notifications.show(0, title, body, const NotificationDetails(android: androidDetails), payload: payload);
  }
}
