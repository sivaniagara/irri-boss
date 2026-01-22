// To parse this JSON data, do
//
//     final fertilizerModel = fertilizerModelFromJson(jsonString);

import 'dart:convert';

FertilizerModel fertilizerModelFromJson(String str) => FertilizerModel.fromJson(json.decode(str));

String fertilizerModelToJson(FertilizerModel data) => json.encode(data.toJson());

class FertilizerModel {
  int code;
  String message;
  List<FertilizerDatum> data;
  String totDuration;
  String totFlow;
  String powerDuration;
  String ctrlDuration;
  String ctrlDuration1;

  FertilizerModel({
    required this.code,
    required this.message,
    required this.data,
    required this.totDuration,
    required this.totFlow,
    required this.powerDuration,
    required this.ctrlDuration,
    required this.ctrlDuration1,
  });

  factory FertilizerModel.fromJson(Map<String, dynamic> json) => FertilizerModel(
    code: json["code"],
    message: json["message"],
    data: List<FertilizerDatum>.from(json["data"].map((x) => FertilizerDatum.fromJson(x))),
    totDuration: json["totDuration"],
    totFlow: json["totFlow"],
    powerDuration: json["powerDuration"],
    ctrlDuration: json["ctrlDuration"],
    ctrlDuration1: json["ctrlDuration1"],
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "totDuration": totDuration,
    "totFlow": totFlow,
    "powerDuration": powerDuration,
    "ctrlDuration": ctrlDuration,
    "ctrlDuration1": ctrlDuration1,
  };
}

class FertilizerDatum {
  String date;
  String fertPump;
  String onTime;
  String offDate;
  String offTime;
  String duration;
  String flow;
  String zoneNumber;

  FertilizerDatum({
    required this.date,
    required this.fertPump,
    required this.onTime,
    required this.offDate,
    required this.offTime,
    required this.duration,
    required this.flow,
    required this.zoneNumber,
  });

  factory FertilizerDatum.fromJson(Map<String, dynamic> json) => FertilizerDatum(
    date: json["date"],
    fertPump: json["fertPump"],
    onTime: json["onTime"],
    offDate: json["offDate"],
    offTime: json["offTime"],
    duration: json["duration"],
    flow: json["flow"],
    zoneNumber: json["zoneNumber"],
  );

  Map<String, dynamic> toJson() => {
    "date": date,
    "fertPump": fertPump,
    "onTime": onTime,
    "offDate": offDate,
    "offTime": offTime,
    "duration": duration,
    "flow": flow,
    "zoneNumber": zoneNumber,
  };
}
