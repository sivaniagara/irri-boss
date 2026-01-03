import 'package:equatable/equatable.dart';

class MoistureEntity extends Equatable {
  final int code;
  final String message;
  final MoistureDataEntity data;

  const MoistureEntity({
    required this.code,
    required this.message,
    required this.data,
  });

  @override
  List<Object?> get props => [code, message, data];
}

class MoistureDataEntity extends Equatable {
  final List<MostEntity> mostList;
  final String ctrlDate;
  final String ctrlTime;

  const MoistureDataEntity({
    required this.mostList,
    required this.ctrlDate,
    required this.ctrlTime,
  });

  @override
  List<Object?> get props => [mostList, ctrlDate, ctrlTime];
}


class MostEntity extends Equatable {
  final String serialNo;
  final String nodeName;
  final String message;
  final int categoryId;
  final int modelId;
  final String categoryName;
  final String modelName;
  final String feedback;
  final String adcValue;
  final String extra1;
  final String extra2;
  final String batteryVot;
  final String solarVot;
  final String pressure;
  final String moisture1;
  final String moisture2;
  final String temperature;

  const MostEntity({
    required this.serialNo,
    required this.nodeName,
    required this.message,
    required this.categoryId,
    required this.modelId,
    required this.categoryName,
    required this.modelName,
    required this.feedback,
    required this.adcValue,
    required this.extra1,
    required this.extra2,
    required this.batteryVot,
    required this.solarVot,
    required this.pressure,
    required this.moisture1,
    required this.moisture2,
    required this.temperature,
  });

  @override
  List<Object?> get props => [
    serialNo,
    nodeName,
    message,
    categoryId,
    modelId,
    categoryName,
    modelName,
    feedback,
    adcValue,
    extra1,
    extra2,
    batteryVot,
    solarVot,
    pressure,
    moisture1,
    moisture2,
    temperature,
  ];
}
