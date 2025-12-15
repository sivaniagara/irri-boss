

import 'dart:convert';

SendrevModel sendrevModelFromJson(String str) => SendrevModel.fromJson(json.decode(str));

String sendrevModelToJson(SendrevModel data) => json.encode(data.toJson());

class SendrevModel {
  int code;
  String message;
  List<SendrevDatum> data;

  SendrevModel({
    required this.code,
    required this.message,
    required this.data,
  });

  factory SendrevModel.fromJson(Map<String, dynamic> json) => SendrevModel(
    code: json["code"],
    message: json["message"],
    data: List<SendrevDatum>.from(json["data"].map((x) => SendrevDatum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class SendrevDatum {
  String date;
  String time;
  String msgType;
  String ctrlMsg;
  String ctrlDesc;
  String status;
  String msgCode;

  SendrevDatum({
    required this.date,
    required this.time,
    required this.msgType,
    required this.ctrlMsg,
    required this.ctrlDesc,
    required this.status,
    required this.msgCode,
  });

  factory SendrevDatum.fromJson(Map<String, dynamic> json) => SendrevDatum(
    date: json["date"],
    time: json["time"],
    msgType: json["msgType"],
    ctrlMsg: json["ctrlMsg"],
    ctrlDesc: json["ctrlDesc"],
    status: json["status"],
    msgCode: json["msgCode"],
  );

  Map<String, dynamic> toJson() => {
    "date": date,
    "time": time,
    "msgType": msgType,
    "ctrlMsg": ctrlMsg,
    "ctrlDesc": ctrlDesc,
    "status": status,
    "msgCode": msgCode,
  };
}
