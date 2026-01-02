
class SetSerialData {
  final String lorakey;
  final String type;
  final List<SetSerialNodeList> nodeList;

  SetSerialData({
    required this.lorakey,
    required this.type,
    required this.nodeList,
  });

  factory SetSerialData.fromJson(Map<String, dynamic> json) {
    return SetSerialData(
      lorakey: json['lorakey'] ?? "",
      type: json['type'] ?? "",
      nodeList: (json['nodeList'] as List).map((e) => SetSerialNodeList.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "lorakey": lorakey,
      "type": type,
      "nodeList": nodeList.map((e) => e.toJson()).toList(),
    };
  }
}

class SetSerialNodeList {
  final String nodeName;
  final String qrCode;
  final String nodeValue;
  final String nodeId;
  final String serialNo;

  SetSerialNodeList({
    required this.nodeName,
    required this.qrCode,
    required this.nodeValue,
    required this.nodeId,
    required this.serialNo,
  });

  factory SetSerialNodeList.fromJson(Map<String, dynamic> json) {
    return SetSerialNodeList(
      nodeName: json['nodeName'] ?? "",
      qrCode: json['QRCode'] ?? "",
      nodeValue: json['nodeValue'] ?? "",
      nodeId: json['nodeId'] ?? "",
      serialNo: json['serialNo'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "nodeName": nodeName,
      "QRCode": qrCode,
      "nodeValue": nodeValue,
      "nodeId": nodeId,
      "serialNo": serialNo,
    };
  }
}
