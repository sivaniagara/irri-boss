import '../../domain/entities/faultmsg_entities.dart';
import '../../domain/repositories/faultmsg_repo.dart';
import '../datasources/faultmsg_datasource.dart';


class faultmsgRepositoryImpl implements faultmsgRepository {
  final faultmsgRemoteDataSource dataSource;

  faultmsgRepositoryImpl({required this.dataSource});

   Future<faultmsgEntity> getMessages({
    required int userId,
    required int subuserId,
    required int controllerId,
   }) async {
    // Call remote data source
    final model = await dataSource.getFaultMessages(
      userId: userId,
      subuserId: subuserId,
      controllerId: controllerId,

    );

    // Map model to entity
    return faultmsgEntity(
      code: model.code,
      message: model.message,
      data: model.data
          .map(
            (d) => faultmsgDatumEntity(
                userId: d.userId,
                controllerId: d.controllerId,
                messageCode: d.messageCode,
                controllerMessage: d.controllerMessage,
                readStatus: d.readStatus,
                messageType: d.messageType,
                messageDescription: d.messageDescription,
                ctrlDate: d.ctrlDate,
                ctrlTime: d.ctrlTime),
      )
          .toList(),
    );
  }
}