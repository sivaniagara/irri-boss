import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/entities/notifications_entity.dart';

class NotificationsModel extends NotificationsEntity {
  const NotificationsModel({
    required super.msgId,
    required super.msgCode,
    required super.msgDesc,
    required super.checkFlag
  });

  factory NotificationsModel.fromJson(Map<String, dynamic> json) {
    return NotificationsModel(
        msgId: json["msgId"],
        msgCode: json["msgCode"],
        msgDesc: json["msgDesc"],
        checkFlag: json["checkFlag"]
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "msgCode": msgId,
      "checkStatus": checkFlag
    };
  }
}

extension NotificationsEntityX on NotificationsEntity {
  NotificationsModel toModel() {
    return NotificationsModel(
      msgId: msgId,
      msgCode: msgCode,
      msgDesc: msgDesc,
      checkFlag: checkFlag,
    );
  }
}