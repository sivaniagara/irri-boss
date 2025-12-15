import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/setserialsettings/presentation/bloc/setserial_bloc_event.dart';
import 'package:niagara_smart_drip_irrigation/features/setserialsettings/presentation/bloc/setserial_state.dart';

import '../../data/repositories/setserial_details_repositories.dart';

class SetSerialBloc extends Bloc<SetSerialEvent, SetSerialState> {
  final SetSerialRepository repo;

  SetSerialBloc(this.repo) : super(SetSerialInitial()) {
    on<SendSerialEvent>(_sendSerial);
    on<ResetSerialEvent>(_resetSerial);
    on<ViewSerialEvent>(_viewSerial);
    on<LoadSerialEvent>(_loadSerial);
  }

  Future<void> _sendSerial(
      SendSerialEvent event, Emitter<SetSerialState> emit) async {
    emit(SetSerialLoading());
    try {
      // mqtt.publish(event.sentSms);   // <-- your MQTT publish
      final message = await repo.sendSerial(
        userId: event.userId,
        controllerId: event.controllerId,
        sendList: event.sendList,
        sentSms: event.sentSms,
      );
      emit(SendSerialSuccess(message));
    } catch (e) {
      emit(SendSerialError(e.toString()));
    }
  }

  Future<void> _resetSerial(
      ResetSerialEvent event, Emitter<SetSerialState> emit) async {
    emit(SetSerialLoading());
    try {
      // mqtt.publish(event.sentSms);
      final message = await repo.resetSerial(
        userId: event.userId,
        controllerId: event.controllerId,
        nodeIds: event.nodeIds,
        sentSms: event.sentSms,
      );
      emit(ResetSerialSuccess(message));
    } catch (e) {
      emit(ResetSerialError(e.toString()));
    }
  }

  Future<void> _viewSerial(
      ViewSerialEvent event, Emitter<SetSerialState> emit) async {
    emit(SetSerialLoading());
    try {
      // mqtt.publish(event.sentSms);
      final message = await repo.viewSerial(
        userId: event.userId,
        controllerId: event.controllerId,
        sentSms: event.sentSms,
      );
      emit(ViewSerialSuccess(message));
    } catch (e) {
      emit(ViewSerialError(e.toString()));
    }
  }

  Future<void> _loadSerial(
      LoadSerialEvent event, Emitter<SetSerialState> emit) async {
    emit(SetSerialLoading());
    try {
      final nodeList = await repo.loadSerial(
        userId: event.userId,
        controllerId: event.controllerId,
      );
      emit(SerialDataLoaded(nodeList));
    } catch (e) {
      emit(LoadSerialError(e.toString()));
    }
  }
}
