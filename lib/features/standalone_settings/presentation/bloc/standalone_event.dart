abstract class StandaloneEvent {}

class FetchStandaloneDataEvent extends StandaloneEvent {
  final String userId;
  final String controllerId;
  final String deviceId;
  final String subUserId;
  final String menuId;
  final String settingsId;
  final bool isBackground;

  FetchStandaloneDataEvent({
    required this.userId,
    required this.controllerId,
    required this.deviceId,
    required this.subUserId,
    this.menuId = "2",
    this.settingsId = "59",
    this.isBackground = false,
  });
}

class ToggleZone extends StandaloneEvent {
  final int index;
  final bool value;

  ToggleZone(this.index, this.value);
}

class UpdateZoneTime extends StandaloneEvent {
  final int index;
  final String time;

  UpdateZoneTime(this.index, this.time);
}

class ToggleStandalone extends StandaloneEvent {
  final String userId;
  final String controllerId;
  final String deviceId;
  final String subUserId;
  final String menuId;
  final String settingsId;
  final bool value;

  ToggleStandalone({
    required this.userId,
    required this.controllerId,
    required this.deviceId,
    required this.subUserId,
    required this.menuId,
    required this.settingsId,
    required this.value,
  });
}

class ToggleDripStandalone extends StandaloneEvent {
  final String userId;
  final String controllerId;
  final String deviceId;
  final String subUserId;
  final String menuId;
  final String settingsId;
  final bool value;

  ToggleDripStandalone({
    required this.userId,
    required this.controllerId,
    required this.deviceId,
    required this.subUserId,
    required this.menuId,
    required this.settingsId,
    required this.value,
  });
}

enum StandaloneSendType { mode, drip, zones }

class SendStandaloneConfigEvent extends StandaloneEvent {
  final String userId;
  final String controllerId;
  final String deviceId;
  final String subUserId;
  final String menuId;
  final String settingsId;
  final String successMessage;
  final StandaloneSendType sendType;

  SendStandaloneConfigEvent({
    required this.userId,
    required this.controllerId,
    required this.deviceId,
    required this.subUserId,
    required this.menuId,
    required this.settingsId,
    required this.successMessage,
    required this.sendType,
  });
}

class ViewStandaloneEvent extends StandaloneEvent {
  final String userId;
  final String controllerId;
  final String subUserId;
  final String deviceId;
  final String successMessage;

  ViewStandaloneEvent({
    required this.userId,
    required this.controllerId,
    required this.subUserId,
    required this.deviceId,
    required this.successMessage,
  });
}
