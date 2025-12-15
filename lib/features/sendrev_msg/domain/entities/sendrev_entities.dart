/// Entity representing the entire send/receive response
class SendrevEntity {
  final int code;
  final String message;
  final List<SendrevDatumEntity> data;

  SendrevEntity({
    required this.code,
    required this.message,
    required this.data,
  });
}

/// Entity representing each message datum
class SendrevDatumEntity {
  final String date;
  final String time;
  final String msgType;
  final String ctrlMsg;
  final String ctrlDesc;
  final String status;
  final String msgCode;

  SendrevDatumEntity({
    required this.date,
    required this.time,
    required this.msgType,
    required this.ctrlMsg,
    required this.ctrlDesc,
    required this.status,
    required this.msgCode,
  });
}
