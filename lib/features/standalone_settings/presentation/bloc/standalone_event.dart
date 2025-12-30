abstract class StandaloneEvent {}

class FetchStandaloneDataEvent extends StandaloneEvent {
  final String userId;
  final String controllerId;
  final String menuId;
  final String settingsId;

  FetchStandaloneDataEvent({
    required this.userId, 
    required this.controllerId,
    this.menuId = "2",
    this.settingsId = "59",
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
  final bool value;

  ToggleStandalone(this.value);
}

class ToggleDripStandalone extends StandaloneEvent {
  final bool value;

  ToggleDripStandalone(this.value);
}

class SendStandaloneConfigEvent extends StandaloneEvent {
  final String userId;
  final String controllerId;
  final String menuId;
  final String settingsId;
  final String successMessage;

  SendStandaloneConfigEvent({
    required this.userId, 
    required this.controllerId,
    required this.menuId,
    required this.settingsId,
    required this.successMessage,
  });
}

class ViewStandaloneEvent extends StandaloneEvent {
  final String controllerId;
  final String successMessage;

  ViewStandaloneEvent({
    required this.controllerId,
    required this.successMessage,
  });
}
