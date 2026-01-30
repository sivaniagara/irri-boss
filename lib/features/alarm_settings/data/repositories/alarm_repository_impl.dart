import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/api_urls.dart';
import '../../domain/entities/alarm_entity.dart';
import '../../domain/repositories/alarm_repository.dart';
import '../data_sources/alarm_remote_source.dart';
import '../../utils/alarm_urls.dart';

class AlarmRepositoryImpl implements AlarmRepository {
  final AlarmRemoteSource remoteSource;

  AlarmRepositoryImpl({required this.remoteSource});

  @override
  Future<Either<Failure, AlarmEntity>> getAlarmSetting({
    required String userId,
    required String controllerId,
    required String subUserId,
  }) async {
    try {
      final urlData = {
        'userId': userId,
        'controllerId': controllerId,
        'subUserId': subUserId,
      };
      final model = await remoteSource.getAlarmSetting(urlData: urlData);
      return Right(model);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveAlarmSettings({
    required String userId,
    required String controllerId,
    required String subUserId,
    required AlarmEntity entity,
    required String sentSms,
  }) async {
    try {
      // 1. Publish command to hardware using the 15-digit deviceId
      if (entity.deviceId.isNotEmpty) {
        if (kDebugMode) {
          print("📤 ALARM MQTT ATTEMPT: Topic ID: ${entity.deviceId}, Payload: {\"sentSms\":\"$sentSms\"}");
        }
        await remoteSource.publishMqttCommand(
          controllerId: entity.deviceId,
          command: jsonEncode({"sentSms": sentSms}),
        );
      }

      // 2. Save to Database (REST API Persistence)
      final urlData = {
        'userId': userId,
        'controllerId': controllerId,
        'subUserId': subUserId,
      };
      String endPoint = buildUrl(AlarmUrls.saveAlarmSetting, urlData);

      final body = {
        "menuSettingId": entity.menuSettingId,
        "subMenuCount": 0,
        "sendData": jsonEncode({
          "type": entity.alarmData.type,
          "alarmType": entity.alarmData.alarmType,
          "alarmActive": entity.alarmData.alarmActive,
          "irrigationStop": entity.alarmData.irrigationStop,
          "dosingStop": entity.alarmData.dosingStop,
          "reset": entity.alarmData.reset,
          "hour": entity.alarmData.hour,
          "minutes": entity.alarmData.minutes,
          "seconds": entity.alarmData.seconds,
          "threshold": entity.alarmData.threshold,
        }),
        "sentSms": sentSms,
      };

      await remoteSource.saveAlarmSettings(endpoint: endPoint, body: body);

      return const Right(null);
    } catch (e) {
      if (kDebugMode) print("❌ ALARM SAVE ERROR: $e");
      return Left(ServerFailure(e.toString()));
    }
  }
}
