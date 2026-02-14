import 'package:equatable/equatable.dart';

class GetMoistureStatusModel extends Equatable {
  final int? code;
  final String? message;
  final List<GetMoistureNodeData>? data;

  const GetMoistureStatusModel({this.code, this.message, this.data});

  factory GetMoistureStatusModel.fromJson(Map<String, dynamic> json) {
    return GetMoistureStatusModel(
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? (json['data'] as List).map((i) => GetMoistureNodeData.fromJson(i)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [code, message, data];
}

class GetMoistureNodeData extends Equatable {
  final String? serialNumber;
  final String? category;
  final String? deviceName;
  final String? status;
  final String? moisture1;
  final String? moisture2;
  final String? batteryVolt;
  final String? solarVolt;
  final String? pressure;
  final String? value;
  final String? latlong;
  final String? message;

  const GetMoistureNodeData({
    this.serialNumber,
    this.category,
    this.deviceName,
    this.status,
    this.moisture1,
    this.moisture2,
    this.batteryVolt,
    this.solarVolt,
    this.pressure,
    this.value,
    this.latlong,
    this.message,
  });

  factory GetMoistureNodeData.fromJson(Map<String, dynamic> json) {
    return GetMoistureNodeData(
      serialNumber: json['serialNumber'],
      category: json['category'],
      deviceName: json['deviceName'],
      status: json['status'],
      moisture1: json['moisture1'],
      moisture2: json['moisture2'],
      batteryVolt: json['batteryVolt'],
      solarVolt: json['solarVolt'],
      pressure: json['pressure'],
      value: json['value'],
      latlong: json['latlong'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serialNumber': serialNumber,
      'category': category,
      'deviceName': deviceName,
      'status': status,
      'moisture1': moisture1,
      'moisture2': moisture2,
      'batteryVolt': batteryVolt,
      'solarVolt': solarVolt,
      'pressure': pressure,
      'value': value,
      'latlong': latlong,
      'message': message,
    };
  }

  @override
  List<Object?> get props => [
        serialNumber,
        category,
        deviceName,
        status,
        moisture1,
        moisture2,
        batteryVolt,
        solarVolt,
        pressure,
        value,
        latlong,
        message,
      ];
}
