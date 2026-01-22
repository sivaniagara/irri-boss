
import '../../domain/entities/fertilizer_entities.dart';
import '../../domain/repositories/fertilizer_repo.dart';
import '../datasources/fertilizer_datasource.dart';



class FertilizerRepositoryImpl implements FertilizerRepository {
  final FertilizerRemoteDataSource dataSource;

  FertilizerRepositoryImpl({required this.dataSource});

  @override
  Future<FertilizerEntity> getFertilizerData({
    required int userId,
    required int subuserId,
    required int controllerId,
    required String fromDate,
    required String toDate,
  }) async {
    final model = await dataSource.FertilizerData(
      userId: userId,
      subuserId: subuserId,
      controllerId: controllerId,
      fromDate: fromDate,
      toDate: toDate,
    );

    return FertilizerEntity(
      code: model.code,
      message: model.message,

      /// 🔹 MAP LIST PROPERLY
      data: model.data.map((z) {
        return FertilizerDatumEntity(
          date: z.date,
          fertPump: z.fertPump,
          onTime: z.onTime,
          offDate: z.offDate,
          offTime: z.offTime,
          duration: z.duration,
          flow: z.flow,
          zoneNumber: z.zoneNumber,
        );
      }).toList(),
      totDuration: model.totDuration,
      totFlow: model.totFlow,
      powerDuration: model.powerDuration,
      ctrlDuration: model.ctrlDuration,
      ctrlDuration1: model.ctrlDuration1,
    );
  }
}
