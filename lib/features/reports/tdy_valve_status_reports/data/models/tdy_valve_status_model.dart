// To parse this JSON data, do
//
//     final tdyValveStatusModel = tdyValveStatusModelFromJson(jsonString);

import 'dart:convert';

TdyValveStatusModel tdyValveStatusModelFromJson(String str) => TdyValveStatusModel.fromJson(json.decode(str));

String tdyValveStatusModelToJson(TdyValveStatusModel data) => json.encode(data.toJson());

class TdyValveStatusModel {
  int code;
  String message;
  int totalFlow;
  List<Datum> data;

  TdyValveStatusModel({
    required this.code,
    required this.message,
    required this.totalFlow,
    required this.data,
  });

  factory TdyValveStatusModel.fromJson(Map<String, dynamic> json) => TdyValveStatusModel(
    code: json["code"],
    message: json["message"],
    totalFlow: json["totalFlow"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
    "totalFlow": totalFlow,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  String zone;
  String duration;
  String litres;
  String zonePlace;
  int? totalFlow;

  Datum({
    required this.zone,
    required this.duration,
    required this.litres,
    required this.zonePlace,
    this.totalFlow,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    zone: json["zone"],
    duration: json["duration"],
    litres: json["litres"].toString(),
    zonePlace: json["zonePlace"],
    totalFlow: json["totalFlow"],
  );

  Map<String, dynamic> toJson() => {
    "zone": zone,
    "duration": duration,
    "litres": litres,
    "zonePlace": zonePlace,
    "totalFlow": totalFlow,
  };
}
