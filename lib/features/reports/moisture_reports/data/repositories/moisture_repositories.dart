
 import '../../domain/entities/moisture_entities.dart';
 import '../../domain/repositories/moisture_repo.dart';
 import '../datasources/moisture_datasource.dart';

 
class MoistureRepositoryImpl implements MoistureRepository {
  final MoistureRemoteDataSource dataSource;

  MoistureRepositoryImpl({required this.dataSource});

  @override
Future<MoistureEntity> getMoistureData({
     required int userId,
    required int subuserId,
    required int controllerId,
   }) async {
    final model = await dataSource.MoistureData(
      userId: userId,
      subuserId: subuserId,
      controllerId: controllerId,
     );
    return MoistureEntity(
      code: model.code,
      message: model.message,
      data: MoistureDataEntity(
        ctrlDate: model.data.ctrlDate,
        ctrlTime: model.data.ctrlTime,
        mostList: model.data.mostList
            .map(
              (m) => MostEntity(
            serialNo: m.serialNo,
            nodeName: m.nodeName,
            message: m.message,
            categoryId: m.categoryId,
            modelId: m.modelId,
            categoryName: m.categoryName,
            modelName: m.modelName,
            feedback: m.feedback,
            adcValue: m.adcValue,
            extra1: m.extra1,
            extra2: m.extra2,
            batteryVot: m.batteryVot,
            solarVot: m.solarVot,
            pressure: m.pressure,
            moisture1: m.moisture1,
            moisture2: m.moisture2,
            temperature: m.temperature,
          ),
        ).toList(),
      ),
    );
  }



}
