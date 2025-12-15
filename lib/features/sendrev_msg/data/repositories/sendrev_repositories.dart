import 'package:niagara_smart_drip_irrigation/features/sendrev_msg/domain/entities/sendrev_entities.dart';
import '../../domain/repositories/sendrev_repo.dart';
import '../datasources/sendrev_datasource.dart';


class SendrevRepositoryImpl implements SendrevRepository {
  final SendRevRemoteDataSource dataSource;

  SendrevRepositoryImpl({required this.dataSource});

   Future<SendrevEntity> getMessages({
    required int userId,
    required int subuserId,
    required int controllerId,
    required String fromDate,
    required String toDate,
  }) async {
    // Call remote data source
    final model = await dataSource.getSendReceiveMessages(
      userId: userId,
      subuserId: subuserId,
      controllerId: controllerId,
      fromDate: fromDate,
      toDate: toDate,
    );

    // Map model to entity
    return SendrevEntity(
      code: model.code,
      message: model.message,
      data: model.data
          .map(
            (d) => SendrevDatumEntity(
          date: d.date,
          time: d.time,
          msgType: d.msgType,
          ctrlMsg: d.ctrlMsg,
          ctrlDesc: d.ctrlDesc,
          status: d.status,
          msgCode: d.msgCode,
        ),
      )
          .toList(),
    );
  }
}