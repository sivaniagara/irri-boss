// To parse this JSON data, do
//
//     final powerGraphModel = powerGraphModelFromJson(jsonString);

import 'dart:convert';

PowerGraphModel powerGraphModelFromJson(String str) => PowerGraphModel.fromJson(json.decode(str));

String powerGraphModelToJson(PowerGraphModel data) => json.encode(data.toJson());

class PowerGraphModel {
  int code;
  String message;
  List<PowerDatum> data;

  PowerGraphModel({
    required this.code,
    required this.message,
    required this.data,
  });

  factory PowerGraphModel.fromJson(Map<String, dynamic> json) => PowerGraphModel(
    code: json["code"],
    message: json["message"],
    data: List<PowerDatum>.from(json["data"].map((x) => PowerDatum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class PowerDatum {
  String date;
  String time;
  String totalPowerOnTime;
  String totalPowerOffTime;
  String motorRunTime;
  String motorRunTime2;
  String motorIdleTime;
  String motorIdleTime2;
  String dryRunTripTime;
  String dryRunTripTime2;
  String cyclicTripTime;
  String cyclicTripTime2;
  String otherTripTime;
  String otherTripTime2;
  String totalFlowToday;
  String cumulativeFlowToday;
  String averageFlowRate;
  String pressureIn;
  String pressureOut;
  String battery1Volt;
  String battery2Volt;
  String battery3Volt;
  String battery4Volt;
  String solar1Volt;
  String solar2Volt;
  String solar3Volt;
  String solar4Volt;

  PowerDatum({
    required this.date,
    required this.time,
    required this.totalPowerOnTime,
    required this.totalPowerOffTime,
    required this.motorRunTime,
    required this.motorRunTime2,
    required this.motorIdleTime,
    required this.motorIdleTime2,
    required this.dryRunTripTime,
    required this.dryRunTripTime2,
    required this.cyclicTripTime,
    required this.cyclicTripTime2,
    required this.otherTripTime,
    required this.otherTripTime2,
    required this.totalFlowToday,
    required this.cumulativeFlowToday,
    required this.averageFlowRate,
    required this.pressureIn,
    required this.pressureOut,
    required this.battery1Volt,
    required this.battery2Volt,
    required this.battery3Volt,
    required this.battery4Volt,
    required this.solar1Volt,
    required this.solar2Volt,
    required this.solar3Volt,
    required this.solar4Volt,
  });

  factory PowerDatum.fromJson(Map<String, dynamic> json) => PowerDatum(
    date: json["date"],
    time: json["time"],
    totalPowerOnTime: json["totalPowerOnTime"],
    totalPowerOffTime: json["totalPowerOffTime"],
    motorRunTime: json["motorRunTime"],
    motorRunTime2: json["motorRunTime2"],
    motorIdleTime: json["motorIdleTime"],
    motorIdleTime2: json["motorIdleTime2"],
    dryRunTripTime: json["dryRunTripTime"],
    dryRunTripTime2: json["dryRunTripTime2"],
    cyclicTripTime: json["cyclicTripTime"],
    cyclicTripTime2: json["cyclicTripTime2"],
    otherTripTime: json["otherTripTime"],
    otherTripTime2: json["otherTripTime2"],
    totalFlowToday: json["totalFlowToday"],
    cumulativeFlowToday: json["cumulativeFlowToday"],
    averageFlowRate: json["averageFlowRate"],
    pressureIn: json["pressureIn"],
    pressureOut: json["pressureOut"],
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
    "totalPowerOnTime": totalPowerOnTime,
    "totalPowerOffTime": totalPowerOffTime,
    "motorRunTime": motorRunTime,
    "motorRunTime2": motorRunTime2,
    "motorIdleTime": motorIdleTime,
    "motorIdleTime2": motorIdleTime2,
    "dryRunTripTime": dryRunTripTime,
    "dryRunTripTime2": dryRunTripTime2,
    "cyclicTripTime": cyclicTripTime,
    "cyclicTripTime2": cyclicTripTime2,
    "otherTripTime": otherTripTime,
    "otherTripTime2": otherTripTime2,
    "totalFlowToday": totalFlowToday,
    "cumulativeFlowToday": cumulativeFlowToday,
    "averageFlowRate": averageFlowRate,
    "pressureIn": pressureIn,
    "pressureOut": pressureOut,
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
