import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ControllerContextState{}

class ControllerContextInitial extends ControllerContextState{}

class ControllerContextLoaded extends ControllerContextState{
  final String userId;
  final String controllerId;
  final String deviceId;
  final String userType;
  final String subUserId;
  ControllerContextLoaded({
    required this.userId,
    required this.controllerId,
    required this.deviceId,
    required this.userType,
    required this.subUserId,
  });
}

class ControllerContextCubit extends Cubit<ControllerContextState>{
  ControllerContextCubit() : super(ControllerContextInitial());

  void setContext({
    required String userId,
    required String controllerId,
    required String userType,
    required String subUserId,
    required String deviceId,
  }){
    emit(
        ControllerContextLoaded(
            userId: userId,
            controllerId: controllerId,
            userType: userType,
            subUserId: subUserId,
          deviceId: deviceId,
        )
    );
    print('ControllerContextLoaded updayed....');
  }

  void updateController({
    required String controllerId,
    required String deviceId,
  }) {
    print("controllerId ==> $controllerId");
    final currentState = state;

    // ✅ SAFETY CHECK
    if (currentState is ControllerContextLoaded) {
      emit(
        ControllerContextLoaded(
          userId: currentState.userId,
          controllerId: controllerId,
          userType: currentState.userType,
          subUserId: currentState.subUserId,
          deviceId: deviceId,
        ),
      );
    }
  }
}