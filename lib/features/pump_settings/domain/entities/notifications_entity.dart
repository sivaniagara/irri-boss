import 'package:equatable/equatable.dart';

class NotificationsEntity extends Equatable{
  final int msgId;
  final String msgCode;
  final String msgDesc;
  final int checkFlag;

  const NotificationsEntity({
    required this.msgId,
    required this.msgCode,
    required this.msgDesc,
    required this.checkFlag
  });

  NotificationsEntity copyWith({int? checkFlag}) {
    return NotificationsEntity(
        msgId: msgId,
        msgCode: msgCode,
        msgDesc: msgDesc,
        checkFlag: checkFlag ?? this.checkFlag
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [msgId, msgCode, msgDesc, checkFlag];
}