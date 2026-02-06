abstract class ValveFlowEvent {}

class FetchValveFlowDataEvent extends ValveFlowEvent {
  final String userId;
  final String controllerId;
  final String deviceId;
  final String subUserId;
  FetchValveFlowDataEvent({
    required this.userId,
    required this.controllerId,
    required this.deviceId,
    required this.subUserId
  });
}

class UpdateValveFlowNodeEvent extends ValveFlowEvent {
  final int index;
  final String nodeValue;
  UpdateValveFlowNodeEvent({required this.index, required this.nodeValue});
}

class UpdateCommonFlowDeviationEvent extends ValveFlowEvent {
  final String deviation;
  UpdateCommonFlowDeviationEvent({required this.deviation});
}

class SendValveFlowSmsEvent extends ValveFlowEvent {
  final int index;
  SendValveFlowSmsEvent({required this.index});
}

class SaveCommonDeviationEvent extends ValveFlowEvent {
  SaveCommonDeviationEvent();
}

class ViewValveFlowEvent extends ValveFlowEvent {
  final String successMessage;
  ViewValveFlowEvent({required this.successMessage});
}
