// To parse this JSON data, do
//
//     final flowGraphModel = flowGraphModelFromJson(jsonString);

import 'dart:convert';

FlowGraphModel flowGraphModelFromJson(String str) => FlowGraphModel.fromJson(json.decode(str));

String flowGraphModelToJson(FlowGraphModel data) => json.encode(data.toJson());

class FlowGraphModel {
  int code;
  String message;
  List<FlowGraphDatum> data;

  FlowGraphModel({
    required this.code,
    required this.message,
    required this.data,
  });

  factory FlowGraphModel.fromJson(Map<String, dynamic> json) => FlowGraphModel(
    code: json["code"],
    message: json["message"],
    data: List<FlowGraphDatum>.from(json["data"].map((x) => FlowGraphDatum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class FlowGraphDatum {
  String date;
  String totalFlow;
  String totalRunTime;
  String total3PhaseOnTime;
  String total2PhaseOnTime;
  String totalPowerOnTime;

  FlowGraphDatum({
    required this.date,
    required this.totalFlow,
    required this.totalRunTime,
    required this.total3PhaseOnTime,
    required this.total2PhaseOnTime,
    required this.totalPowerOnTime,
  });

  factory FlowGraphDatum.fromJson(Map<String, dynamic> json) => FlowGraphDatum(
    date: json["date"],
    totalFlow: json["totalFlow"],
    totalRunTime: json["totalRunTime"],
    total3PhaseOnTime: json["total3PhaseOnTime"],
    total2PhaseOnTime: json["total2PhaseOnTime"],
    totalPowerOnTime: json["totalPowerOnTime"],
  );

  Map<String, dynamic> toJson() => {
    "date": date,
    "totalFlow": totalFlow,
    "totalRunTime": totalRunTime,
    "total3PhaseOnTime": total3PhaseOnTime,
    "total2PhaseOnTime": total2PhaseOnTime,
    "totalPowerOnTime": totalPowerOnTime,
  };
}
