import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ControllerContextState{}

class ControllerContextInitial extends ControllerContextState{}

class ControllerContextLoaded extends ControllerContextState{
  final String userId;
  final String controllerId;
  final String deviceId;
  final String userType;
  final String subUserId;
  final int modelId; // 👈 Added modelId
  ControllerContextLoaded({
    required this.userId,
    required this.controllerId,
    required this.deviceId,
    required this.userType,
    required this.subUserId,
    required this.modelId, // 👈 Added modelId
  });
}

class ControllerContextCubit extends Cubit<ControllerContextState>{
  ControllerContextCubit() : super(ControllerContextInitial());

  void setContext({
    required String userId,
    required String controllerId,
    required String deviceId,
    required String userType,
    required String subUserId,
    required int modelId, // 👈 Added modelId
  }){
    emit(
        ControllerContextLoaded(
          userId: userId,
          controllerId: controllerId,
          deviceId: deviceId,
          userType: userType,
          subUserId: subUserId,
          modelId: modelId, // 👈 Added modelId
        )
    );
    print('ControllerContextLoaded updated....');
  }

  void toInitial(){
    emit(ControllerContextInitial());
  }

  void updateController({
    required String controllerId,
    required String deviceId,
    required int modelId, // 👈 Added modelId
  }) {
    final currentState = state;

    if (currentState is ControllerContextLoaded) {
      emit(
        ControllerContextLoaded(
          userId: currentState.userId,
          controllerId: controllerId,
          userType: currentState.userType,
          subUserId: currentState.subUserId,
          deviceId: deviceId,
          modelId: modelId, // 👈 Added modelId
        ),
      );
    }
  }
}