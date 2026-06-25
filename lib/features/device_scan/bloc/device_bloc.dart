import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/model/device_model.dart';
import '../data/repository/device_repository.dart';
import 'device_event.dart';
import 'device_state.dart';

class QRDeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  final DeviceRepository repository;

  List<QRDeviceModel> devices = [];

  QRDeviceBloc(this.repository) : super(DeviceInitial()) {
    on<LoadDevices>((event, emit) async {
      emit(DeviceLoading());
      devices = await repository.getDevices();
      emit(DeviceLoaded(devices));
    });

    on<AddScannedDevice>((event, emit) async {
      final currentState = state;
      List<QRDeviceModel> currentDevices = [];
      if (currentState is DeviceLoaded) {
        currentDevices = List<QRDeviceModel>.from(currentState.devices);
      }

      final exists = currentDevices.any(
        (e) => e.deviceId == event.device.deviceId,
      );

      if (exists) return;

      currentDevices.add(event.device);
      await repository.saveDevice(event.device);
      emit(DeviceLoaded(currentDevices));
    });

    on<SendDevices>((event, emit) async {
      if (state is! DeviceLoaded) return;
      final currentState = state as DeviceLoaded;
      final currentDevices = List<QRDeviceModel>.from(currentState.devices);

      emit(DeviceLoading());

      try {
        final response = await repository.uploadBleProducts(event.userId, currentDevices);
        print("Upload Ble Product Response: $response");

        if (response != null && response['data'] != null) {
          final data = response['data'];
          final List errorDevices = data['errorDevice'] ?? [];
          final List alreadyInsert = data['alreadyInsert'] ?? [];

          for (var d in currentDevices) {
            // Check if device is in error list
            if (errorDevices.any((e) => e.toString() == d.deviceId)) {
              d.status = UploadStatus.failed;
            } 
            // Check if device was already inserted
            else if (alreadyInsert.any((e) => e.toString() == d.deviceId)) {
              d.status = UploadStatus.alreadyExists;
            } 
            // Otherwise assume success if code is 200
            else if (response['code'] == 200) {
              d.status = UploadStatus.success;
            }
          }
        }
        
        emit(DeviceLoaded(currentDevices));
      } catch (e) {
        print("Upload Ble Product Error: $e");
        for (var d in currentDevices) {
          d.status = UploadStatus.failed;
        }
        emit(DeviceLoaded(currentDevices));
      }
    });

    on<UploadDevice>((event, emit) async {
      if (state is! DeviceLoaded) return;
      final currentState = state as DeviceLoaded;
      final currentDevices = List<QRDeviceModel>.from(currentState.devices);

      try {
        final response = await repository.uploadBleProducts(event.userId, [event.device]);
        print("Upload Single Device Response: $response");
        
        if (response != null && response['data'] != null) {
          final data = response['data'];
          final List errorDevices = data['errorDevice'] ?? [];
          final List alreadyInsert = data['alreadyInsert'] ?? [];

          final index = currentDevices.indexWhere((d) => d.deviceId == event.device.deviceId);
          if (index != -1) {
            var d = currentDevices[index];
             if (errorDevices.any((e) => e.toString() == d.deviceId)) {
              d.status = UploadStatus.failed;
            } else if (alreadyInsert.any((e) => e.toString() == d.deviceId)) {
              d.status = UploadStatus.alreadyExists;
            } else if (response['code'] == 200) {
              d.status = UploadStatus.success;
            }
          }
        }
        
        emit(DeviceLoaded(currentDevices));
      } catch (e) {
        print("Upload Single Device Error: $e");
        final index = currentDevices.indexWhere((d) => d.deviceId == event.device.deviceId);
        if (index != -1) {
          currentDevices[index].status = UploadStatus.failed;
        }
        emit(DeviceLoaded(currentDevices));
      }
    });
  }
}
