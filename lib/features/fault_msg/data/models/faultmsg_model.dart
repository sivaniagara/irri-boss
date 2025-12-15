

import 'dart:convert';

FaultMsgModel faultMsgModelFromJson(String str) => FaultMsgModel.fromJson(json.decode(str));

String faultMsgModelToJson(FaultMsgModel data) => json.encode(data.toJson());

class FaultMsgModel {
  int code;
  String message;
  List<FaultDatum> data;

  FaultMsgModel({
    required this.code,
    required this.message,
    required this.data,
  });

  factory FaultMsgModel.fromJson(Map<String, dynamic> json) => FaultMsgModel(
    code: json["code"],
    message: json["message"],
    data: List<FaultDatum>.from(json["data"].map((x) => FaultDatum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class FaultDatum {
  int userId;
  int controllerId;
  String messageCode;
  String controllerMessage;
  String readStatus;
  String messageType;
  String messageDescription;
  String ctrlDate;
  String ctrlTime;

  FaultDatum({
    required this.userId,
    required this.controllerId,
    required this.messageCode,
    required this.controllerMessage,
    required this.readStatus,
    required this.messageType,
    required this.messageDescription,
    required this.ctrlDate,
    required this.ctrlTime,
  });

  factory FaultDatum.fromJson(Map<String, dynamic> json) => FaultDatum(
    userId: json["userId"],
    controllerId: json["controllerId"],
    messageCode: json["messageCode"],
    controllerMessage: json["controllerMessage"],
    readStatus: json["readStatus"],
    messageType: json["messageType"],
    messageDescription: json["messageDescription"],
    ctrlDate: json["ctrlDate"],
    ctrlTime: json["ctrlTime"],
  );

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "controllerId": controllerId,
    "messageCode": messageCode,
    "controllerMessage": controllerMessage,
    "readStatus": readStatus,
    "messageType": messageType,
    "messageDescription": messageDescription,
    "ctrlDate": ctrlDate,
    "ctrlTime": ctrlTime,
  };
}
