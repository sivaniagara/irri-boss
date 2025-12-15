/// Entity representing the entire send/receive response
class faultmsgEntity {
  final int code;
  final String message;
  final List<faultmsgDatumEntity> data;

  faultmsgEntity({
    required this.code,
    required this.message,
    required this.data,
  });
}

/// Entity representing each message datum
/// messageCode
class faultmsgDatumEntity {
  final int userId;
  final int controllerId;
  final String messageCode;
  final String controllerMessage;
  final String readStatus;
  final String messageType;
  final String messageDescription;
  final String ctrlDate;
  final String ctrlTime;


  faultmsgDatumEntity({
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
}
