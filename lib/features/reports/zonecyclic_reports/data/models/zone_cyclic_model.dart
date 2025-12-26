// To parse this JSON data, do
//
//     final zoneCyclicModel = zoneCyclicModelFromJson(jsonString);

import 'dart:convert';

ZoneCyclicModel zoneCyclicModelFromJson(String str) => ZoneCyclicModel.fromJson(json.decode(str));

String zoneCyclicModelToJson(ZoneCyclicModel data) => json.encode(data.toJson());

class ZoneCyclicModel {
  int code;
  String message;
  List<Datum> data;
  String totDuration;
  String totFlow;
  String powerDuration;
  String ctrlDuration;
  String ctrlDuration1;

  ZoneCyclicModel({
    required this.code,
    required this.message,
    required this.data,
    required this.totDuration,
    required this.totFlow,
    required this.powerDuration,
    required this.ctrlDuration,
    required this.ctrlDuration1,
  });

  factory ZoneCyclicModel.fromJson(Map<String, dynamic> json) => ZoneCyclicModel(
    code: json["code"],
    message: json["message"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
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

class Datum {
  String program;
  List<ZoneList> zoneList;

  Datum({
    required this.program,
    required this.zoneList,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    program: json["program"],
    zoneList: List<ZoneList>.from(json["zoneList"].map((x) => ZoneList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "program": program,
    "zoneList": List<dynamic>.from(zoneList.map((x) => x.toJson())),
  };
}

class ZoneList {
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
  String ph;

  ZoneList({
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
    required this.ph,
  });

  factory ZoneList.fromJson(Map<String, dynamic> json) => ZoneList(
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
    ph: json["ph"],
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
    "ph": ph,
  };
}
