

import '../datasources/setserial_datasource.dart';
import '../models/setserial_details_model.dart';


class SetSerialRepository {
  final SetSerialDataSource dataSource;

  SetSerialRepository(this.dataSource);

  Future<String> sendSerial({
    required int userId,
    required int controllerId,
    required List<Map<String, dynamic>> sendList,
    required String sentSms,
  }) {
    return dataSource.sendSerial(
      userId: userId,
      controllerId: controllerId,
      sendList: sendList,
      sentSms: sentSms,
    );
  }

  Future<String> resetSerial({
    required int userId,
    required int controllerId,
    required List<int> nodeIds,
    required String sentSms,
  }) {
    return dataSource.resetSerial(
      userId: userId,
      controllerId: controllerId,
      nodeIds: nodeIds,
      sentSms: sentSms,
    );
  }

  Future<String> viewSerial({
    required int userId,
    required int controllerId,
    required String sentSms,
  }) {
    return dataSource.viewSerial(
      userId: userId,
      controllerId: controllerId,
      sentSms: sentSms,
    );
  }

  Future<List<SetSerialNodeList>> loadSerial({
    required int userId,
    required int controllerId,
  }) {
    return dataSource.loadSerial(
      userId: userId,
      controllerId: controllerId,
    );
  }
}
