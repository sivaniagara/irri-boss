
import 'dart:convert';

StandaloneModel standaloneModelFromJson(String str) => StandaloneModel.fromJson(json.decode(str));

String standaloneModelToJson(StandaloneModel data) => json.encode(data.toJson());

class StandaloneModel {
  int code;
  String message;
  List<StandaloneDatum> data;
  String totDuration;
  String totFlow;
  String powerDuration;
  String ctrlDuration;
  String ctrlDuration1;

  StandaloneModel({
    required this.code,
    required this.message,
    required this.data,
    required this.totDuration,
    required this.totFlow,
    required this.powerDuration,
    required this.ctrlDuration,
    required this.ctrlDuration1,
  });

  factory StandaloneModel.fromJson(Map<String, dynamic> json) => StandaloneModel(
    code: json["code"],
    message: json["message"],
    data: List<StandaloneDatum>.from(json["data"].map((x) => StandaloneDatum.fromJson(x))),
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

class StandaloneDatum {
  String date;
  String zone;
  String onTime;
  String offDate;
  String offTime;
  String duration;
  String dateTime;

  StandaloneDatum({
    required this.date,
    required this.zone,
    required this.onTime,
    required this.offDate,
    required this.offTime,
    required this.duration,
    required this.dateTime,
  });

  factory StandaloneDatum.fromJson(Map<String, dynamic> json) => StandaloneDatum(
    date: json["date"],
    zone: json["zone"],
    onTime: json["OnTime"],
    offDate: json["offDate"],
    offTime: json["OffTime"],
    duration: json["duration"],
    dateTime: json["dateTime"],
  );

  Map<String, dynamic> toJson() => {
    "date": date,
    "zone": zone,
    "OnTime": onTime,
    "offDate": offDate,
    "OffTime": offTime,
    "duration": duration,
    "dateTime": dateTime,
  };
}
