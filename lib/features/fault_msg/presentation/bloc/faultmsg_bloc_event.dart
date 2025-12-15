abstract class FaultMsgEvent {}


class LoadFaultMsgEvent extends FaultMsgEvent {
  final int userId;
  final int subuserId;
  final int controllerId;

  LoadFaultMsgEvent({
    required this.userId,
    required this.subuserId,
    required this.controllerId,
   });
}
