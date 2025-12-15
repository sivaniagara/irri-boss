import 'package:equatable/equatable.dart';

class SetSerialEntity extends Equatable{
  final String lorakey;
  final String type;
  final List<SetSerialNodeEntity> nodeList;

  SetSerialEntity({
    required this.lorakey,
    required this.type,
    required this.nodeList,
  });


@override
// TODO: implement props
List<Object?> get props => [
  lorakey,
  type,
  nodeList
];
}

class SetSerialNodeEntity {
  final String nodeName;
  final String qrCode;
  final String nodeValue;
  final String nodeId;
  final String serialNo;

  SetSerialNodeEntity({
    required this.nodeName,
    required this.qrCode,
    required this.nodeValue,
    required this.nodeId,
    required this.serialNo,
  });
}
