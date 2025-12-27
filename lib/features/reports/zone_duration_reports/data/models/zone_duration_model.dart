// To parse this JSON data, do
//
//     final zoneDurationModel = zoneDurationModelFromJson(jsonString);

import 'dart:convert';

ZoneDurationModel zoneDurationModelFromJson(String str) => ZoneDurationModel.fromJson(json.decode(str));

String zoneDurationModelToJson(ZoneDurationModel data) => json.encode(data.toJson());

class ZoneDurationModel {
  int code;
  String message;
  List<ZoneDurationDatum> data;
  String totDuration;
  String totFlow;
  String powerDuration;
  String ctrlDuration;
  String ctrlDuration1;

  ZoneDurationModel({
    required this.code,
    required this.message,
    required this.data,
    required this.totDuration,
    required this.totFlow,
    required this.powerDuration,
    required this.ctrlDuration,
    required this.ctrlDuration1,
  });

  factory ZoneDurationModel.fromJson(Map<String, dynamic> json) => ZoneDurationModel(
    code: json["code"],
    message: json["message"],
    data: List<ZoneDurationDatum>.from(json["data"].map((x) => ZoneDurationDatum.fromJson(x))),
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

class ZoneDurationDatum {
  String date;
  String zone;
  String onTime;
  String offDate;
  String offTime;
  String duration;
  String dateTime;
  String flow;
  String pressure;
  String pressureIn;
  String pressureOut;
  String wellLevel;
  String wellPercentage;
  String ec;
  String ph;
  String program;
  String vrb;
  String c1;
  String c2;
  String c3;

  ZoneDurationDatum({
    required this.date,
    required this.zone,
    required this.onTime,
    required this.offDate,
    required this.offTime,
    required this.duration,
    required this.dateTime,
    required this.flow,
    required this.pressure,
    required this.pressureIn,
    required this.pressureOut,
    required this.wellLevel,
    required this.wellPercentage,
    required this.ec,
    required this.ph,
    required this.program,
    required this.vrb,
    required this.c1,
    required this.c2,
    required this.c3,
  });

  factory ZoneDurationDatum.fromJson(Map<String, dynamic> json) => ZoneDurationDatum(
    date: json["date"],
    zone: json["zone"],
    onTime: json["OnTime"],
    offDate: json["offDate"],
    offTime: json["OffTime"],
    duration: json["duration"],
    dateTime: json["dateTime"],
    flow: json["flow"],
    pressure: json["pressure"],
    pressureIn: json["pressureIn"],
    pressureOut: json["pressureOut"],
    wellLevel: json["wellLevel"],
    wellPercentage: json["wellPercentage"],
    ec: json["ec"],
    ph: json["ph"],
    program: json["program"],
    vrb: json["vrb"],
    c1: json["c1"],
    c2: json["c2"],
    c3: json["c3"],
  );

  Map<String, dynamic> toJson() => {
    "date": date,
    "zone": zone,
    "OnTime": onTime,
    "offDate": offDate,
    "OffTime": offTime,
    "duration": duration,
    "dateTime": dateTime,
    "flow": flow,
    "pressure": pressure,
    "pressureIn": pressureIn,
    "pressureOut": pressureOut,
    "wellLevel": wellLevel,
    "wellPercentage": wellPercentage,
    "ec": ec,
    "ph": ph,
    "program": program,
    "vrb": vrb,
    "c1": c1,
    "c2": c2,
    "c3": c3,
  };
}
