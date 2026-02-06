import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';
import 'package:niagara_smart_drip_irrigation/core/utils/api_urls.dart';
import '../../domain/entities/serial_set_entity.dart';
import '../../domain/repositories/serial_set_repository.dart';
import '../../presentation/utils/serial_set_urls.dart';
import '../data_source/serial_set_remote_source.dart';
import '../model/serial_set_model.dart';

class SerialSetRepositoryImpl implements SerialSetRepository {
  final SerialSetRemoteSource remoteSource;

  SerialSetRepositoryImpl({required this.remoteSource});

  @override
  Future<Either<Failure, SerialSetEntity>> getSerialSet({
    required String userId,
    required String controllerId,
    required String subUserId,
  }) async {
    try {
      final urlData = {
        'userId': userId,
        'controllerId': controllerId,
        'subuserId': subUserId,
      };
      final model = await remoteSource.getSerialSet(urlData: urlData);
      return Right(model);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveSerialSet({
    required String userId,
    required String controllerId,
    required String subUserId,
    required SerialSetEntity entity,
    required String sentSms,
  }) async {
    try {
      final urlData = {
        'userId': userId,
        'controllerId': controllerId,
        'subuserId': subUserId,
      };
      String endpoint = buildUrl(SerialSetUrls.saveSetSerial, urlData);

      final body = {
        "menuSettingId": entity.menuSettingId,
        "sendData": jsonEncode(entity.nodes.map((n) => SerialSetNodeModel(
          qrCode: n.qrCode,
          serialNo: n.serialNo,
          nodeId: n.nodeId,
        ).toJson()).toList()),
        "receivedData": "",
        "sentSms": sentSms,
      };

      // 1. Save to Database
      await remoteSource.saveSerialSet(endpoint: endpoint, body: body);

      // 2. Log History (Crucial for "Send and Receive" page)
      // Niagara requires an explicit POST to view/messages/ to show in history
      if (sentSms.isNotEmpty) {
        await remoteSource.logHistory(
          userId: userId,
          subuserId: subUserId,
          controllerId: controllerId,
          sentSms: sentSms,
        );
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendMqttCommand({
    required String deviceId,
    required String command,
    required String userId,
    required String controllerId,
    required String subUserId,
    required String sentSms,
  }) async {
    try {
      // 1. Publish command to MQTT (Hardware level)
      final mqttPayload = jsonEncode({"sentSms": command});
      await remoteSource.publishMqtt(topic: deviceId, command: mqttPayload);

      // 2. Log message to history (UI/History level)
      // Matches Standalone and Valve Flow history logging pattern
      if (sentSms.isNotEmpty) {
        await remoteSource.logHistory(
          userId: userId,
          subuserId: subUserId,
          controllerId: controllerId,
          sentSms: sentSms,
        );
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
