// To parse this JSON data, do
//
//     final moistureModel = moistureModelFromJson(jsonString);

import 'dart:convert';

MoistureModel moistureModelFromJson(String str) => MoistureModel.fromJson(json.decode(str));

String moistureModelToJson(MoistureModel data) => json.encode(data.toJson());

class MoistureModel {
  int code;
  String message;
  MoistureData data;

  MoistureModel({
    required this.code,
    required this.message,
    required this.data,
  });

  factory MoistureModel.fromJson(Map<String, dynamic> json) => MoistureModel(
    code: json["code"],
    message: json["message"],
    data: MoistureData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
    "data": data.toJson(),
  };
}

class MoistureData {
  List<MostList> mostList;
  String ctrlDate;
  String ctrlTime;

  MoistureData({
    required this.mostList,
    required this.ctrlDate,
    required this.ctrlTime,
  });

  factory MoistureData.fromJson(Map<String, dynamic> json) => MoistureData(
    mostList: List<MostList>.from(json["mostList"].map((x) => MostList.fromJson(x))),
    ctrlDate: json["ctrlDate"],
    ctrlTime: json["ctrlTime"],
  );

  Map<String, dynamic> toJson() => {
    "mostList": List<dynamic>.from(mostList.map((x) => x.toJson())),
    "ctrlDate": ctrlDate,
    "ctrlTime": ctrlTime,
  };
}

class MostList {
  String serialNo;
  String nodeName;
  String message;
  int categoryId;
  int modelId;
  String categoryName;
  String modelName;
  String feedback;
  String adcValue;
  String extra1;
  String extra2;
  String batteryVot;
  String solarVot;
  String pressure;
  String moisture1;
  String moisture2;
  String temperature;

  MostList({
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

  factory MostList.fromJson(Map<String, dynamic> json) => MostList(
    serialNo: json["serialNo"],
    nodeName: json["nodeName"],
    message: json["message"],
    categoryId: json["categoryId"],
    modelId: json["modelId"],
    categoryName: json["categoryName"],
    modelName: json["modelName"],
    feedback: json["feedback"],
    adcValue: json["adcValue"],
    extra1: json["extra1"],
    extra2: json["extra2"],
    batteryVot: json["batteryVot"],
    solarVot: json["solarVot"],
    pressure: json["pressure"],
    moisture1: json["moisture1"],
    moisture2: json["moisture2"],
    temperature: json["temperature"],
  );

  Map<String, dynamic> toJson() => {
    "serialNo": serialNo,
    "nodeName": nodeName,
    "message": message,
    "categoryId": categoryId,
    "modelId": modelId,
    "categoryName": categoryName,
    "modelName": modelName,
    "feedback": feedback,
    "adcValue": adcValue,
    "extra1": extra1,
    "extra2": extra2,
    "batteryVot": batteryVot,
    "solarVot": solarVot,
    "pressure": pressure,
    "moisture1": moisture1,
    "moisture2": moisture2,
    "temperature": temperature,
  };
}
