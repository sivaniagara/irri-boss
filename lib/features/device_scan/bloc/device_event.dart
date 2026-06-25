
import '../data/model/device_model.dart';

abstract class DeviceEvent {}

class LoadDevices extends DeviceEvent {}

class AddScannedDevice extends DeviceEvent {

  final QRDeviceModel device;

  AddScannedDevice(this.device);


}

class UploadDevice extends DeviceEvent {
  final QRDeviceModel device;
  final int userId;

  UploadDevice(this.device, this.userId);
}
class SendDevices
    extends DeviceEvent {

  final int userId;

  SendDevices(
      this.userId,
      );
}