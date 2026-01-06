// greenhouse_state.dart
abstract class GreenHouseState {}

class GreenHouseInitial extends GreenHouseState {}

class GreenHouseLoading extends GreenHouseState {}

class GreenHouseLoaded extends GreenHouseState {
  final String url;

  GreenHouseLoaded(this.url);
}

class GreenHouseError extends GreenHouseState {
  final String message;

  GreenHouseError(this.message);
}
