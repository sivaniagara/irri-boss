

import 'dart:convert';

VoltageGraphModel voltageGraphModelFromJson(String str) => VoltageGraphModel.fromJson(json.decode(str));

String voltageGraphModelToJson(VoltageGraphModel data) => json.encode(data.toJson());

class VoltageGraphModel {
  int code;
  String message;
  List<VoltageDatum> data;

  VoltageGraphModel({
    required this.code,
    required this.message,
    required this.data,
  });

  factory VoltageGraphModel.fromJson(Map<String, dynamic> json) => VoltageGraphModel(
    code: json["code"],
    message: json["message"],
    data: List<VoltageDatum>.from(json["data"].map((x) => VoltageDatum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class VoltageDatum {
  String date;
  String time;
  String r;
  String y;
  String b;
  String ry;
  String yb;
  String br;
  String c1;
  String c2;
  String c3;
  String runTime;
  String runFlow;
  String lastDayRunTime;
  String lastDayrunFlow;
  String twoPhaseOnTime;
  String twoPhaseLastDayOnTime;
  String threePhaseOnTime;
  String threePhaseLastDayOnTime;
  String powerOffTime;
  String lastDayPowerOffTime;
  String totalPowerOnTime;
  String totalPowerOffTime;
  String wellLevel;
  String wellPercentage;
  String csq;
  String battery1Volt;
  String battery2Volt;
  String battery3Volt;
  String battery4Volt;
  String solar1Volt;
  String solar2Volt;
  String solar3Volt;
  String solar4Volt;

  VoltageDatum({
    required this.date,
    required this.time,
    required this.r,
    required this.y,
    required this.b,
    required this.ry,
    required this.yb,
    required this.br,
    required this.c1,
    required this.c2,
    required this.c3,
    required this.runTime,
    required this.runFlow,
    required this.lastDayRunTime,
    required this.lastDayrunFlow,
    required this.twoPhaseOnTime,
    required this.twoPhaseLastDayOnTime,
    required this.threePhaseOnTime,
    required this.threePhaseLastDayOnTime,
    required this.powerOffTime,
    required this.lastDayPowerOffTime,
    required this.totalPowerOnTime,
    required this.totalPowerOffTime,
    required this.wellLevel,
    required this.wellPercentage,
    required this.csq,
    required this.battery1Volt,
    required this.battery2Volt,
    required this.battery3Volt,
    required this.battery4Volt,
    required this.solar1Volt,
    required this.solar2Volt,
    required this.solar3Volt,
    required this.solar4Volt,
  });

  factory VoltageDatum.fromJson(Map<String, dynamic> json) => VoltageDatum(
    date: json["date"],
    time: json["time"],
    r: json["R"],
    y: json["Y"],
    b: json["B"],
    ry: json["RY"],
    yb: json["YB"],
    br: json["BR"],
    c1: json["C1"],
    c2: json["C2"],
    c3: json["C3"],
    runTime: json["runTime"],
    runFlow: json["runFlow"],
    lastDayRunTime: json["lastDayRunTime"],
    lastDayrunFlow: json["lastDayrunFlow"],
    twoPhaseOnTime: json["twoPhaseOnTime"],
    twoPhaseLastDayOnTime: json["twoPhaseLastDayOnTime"],
    threePhaseOnTime: json["threePhaseOnTime"],
    threePhaseLastDayOnTime: json["threePhaseLastDayOnTime"],
    powerOffTime: json["powerOffTime"],
    lastDayPowerOffTime: json["lastDayPowerOffTime"],
    totalPowerOnTime: json["totalPowerOnTime"],
    totalPowerOffTime: json["totalPowerOffTime"],
    wellLevel: json["wellLevel"],
    wellPercentage: json["wellPercentage"],
    csq: json["csq"],
    battery1Volt: json["battery1Volt"],
    battery2Volt: json["battery2Volt"],
    battery3Volt: json["battery3Volt"],
    battery4Volt: json["battery4Volt"],
    solar1Volt: json["solar1Volt"],
    solar2Volt: json["solar2Volt"],
    solar3Volt: json["solar3Volt"],
    solar4Volt: json["solar4Volt"],
  );

  Map<String, dynamic> toJson() => {
    "date": date,
    "time": time,
    "R": r,
    "Y": y,
    "B": b,
    "RY": ry,
    "YB": yb,
    "BR": br,
    "C1": c1,
    "C2": c2,
    "C3": c3,
    "runTime": runTime,
    "runFlow": runFlow,
    "lastDayRunTime": lastDayRunTime,
    "lastDayrunFlow": lastDayrunFlow,
    "twoPhaseOnTime": twoPhaseOnTime,
    "twoPhaseLastDayOnTime": twoPhaseLastDayOnTime,
    "threePhaseOnTime": threePhaseOnTime,
    "threePhaseLastDayOnTime": threePhaseLastDayOnTime,
    "powerOffTime": powerOffTime,
    "lastDayPowerOffTime": lastDayPowerOffTime,
    "totalPowerOnTime": totalPowerOnTime,
    "totalPowerOffTime": totalPowerOffTime,
    "wellLevel": wellLevel,
    "wellPercentage": wellPercentage,
    "csq": csq,
    "battery1Volt": battery1Volt,
    "battery2Volt": battery2Volt,
    "battery3Volt": battery3Volt,
    "battery4Volt": battery4Volt,
    "solar1Volt": solar1Volt,
    "solar2Volt": solar2Volt,
    "solar3Volt": solar3Volt,
    "solar4Volt": solar4Volt,
  };
}
