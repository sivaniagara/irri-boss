import '../data/model/device_model.dart';

abstract class DeviceState {}

class DeviceInitial extends DeviceState {}

class DeviceLoading extends DeviceState {}

class DeviceLoaded extends DeviceState {
  final List<QRDeviceModel> devices;

  DeviceLoaded(this.devices);
}

class DeviceError extends DeviceState {
  final String message;

  DeviceError(this.message);
}

