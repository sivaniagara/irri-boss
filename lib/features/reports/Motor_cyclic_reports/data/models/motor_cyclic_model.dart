import 'dart:convert';

MotoCyclicModel motoCyclicModelFromJson(String str) => MotoCyclicModel.fromJson(json.decode(str));

String motoCyclicModelToJson(MotoCyclicModel data) => json.encode(data.toJson());

class MotoCyclicModel {
  int code;
  String message;
  List<MotorCyclicDatum> data;
  String totDuration;
  String totFlow;
  String powerDuration;
  String ctrlDuration;
  String ctrlDuration1;

  MotoCyclicModel({
    required this.code,
    required this.message,
    required this.data,
    required this.totDuration,
    required this.totFlow,
    required this.powerDuration,
    required this.ctrlDuration,
    required this.ctrlDuration1,
  });

  factory MotoCyclicModel.fromJson(Map<String, dynamic> json) => MotoCyclicModel(
    code: json["code"],
    message: json["message"],
    data: List<MotorCyclicDatum>.from(json["data"].map((x) => MotorCyclicDatum.fromJson(x))),
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

class MotorCyclicDatum {
  String program;
  String ctrlMsg;
  List<ZoneList> zoneList;

  MotorCyclicDatum({
    required this.program,
    required this.ctrlMsg,
    required this.zoneList,
  });

  factory MotorCyclicDatum.fromJson(Map<String, dynamic> json) => MotorCyclicDatum(
    program: json["program"],
    ctrlMsg: json["ctrlMsg"],
    zoneList: List<ZoneList>.from(json["zoneList"].map((x) => ZoneList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "program": program,
    "ctrlMsg": ctrlMsg,
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
  String ec;
  String vrb;
  String c1;
  String c2;
  String c3;

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
    required this.ec,
    required this.vrb,
    required this.c1,
    required this.c2,
    required this.c3,
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
    ec: json["ec"],
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
    "ph": ph,
    "ec": ec,
    "vrb": vrb,
    "c1": c1,
    "c2": c2,
    "c3": c3,
  };
}
