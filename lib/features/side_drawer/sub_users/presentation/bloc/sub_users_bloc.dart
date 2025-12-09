import 'package:flutter_bloc/flutter_bloc.dart';

import '../../sub_users_barrel.dart';

class SubUsersBloc extends Bloc<SubUsersEvent, SubUsersState> {
  final GetSubUsersUsecase getSubUsersUsecase;
  final GetSubUserDetailsUsecase getSubUserDetailsUsecase;
  final UpdateSubUserDetailsUseCase updateSubUserDetailsUseCase;
  final GetSubUserByPhoneUsecase getSubUserByPhoneUsecase;
  SubUsersBloc({
    required this.getSubUsersUsecase,
    required this.getSubUserDetailsUsecase,
    required this.updateSubUserDetailsUseCase,
    required this.getSubUserByPhoneUsecase,
  }) : super(SubUserInitial()) {
    on<GetSubUsersEvent>(_onGetSubUsers);
    on<GetSubUserDetailsEvent>(_onGetSubUserDetails);
    on<UpdateControllerSelectionEvent>(_onUpdateSelection);
    on<UpdateControllerDndEvent>(_onUpdateDnd);
    on<SubUserDetailsUpdateEvent>(_onUpdateDetails);
    on<GetSubUserByPhoneEvent>(_onGetUserByPhone);
  }

  Future<void> _onGetSubUsers(GetSubUsersEvent event, Emitter<SubUsersState> emit) async {
    emit(SubUserLoading());
    final result = await getSubUsersUsecase(GetSubUsersParams(userId: event.userId));
    result.fold(
          (failure) => emit(SubUsersError(message: failure.message)),
          (subUsers) {
        emit(SubUsersLoaded(subUsersList: subUsers));
      },
    );
  }

  Future<void> _onGetSubUserDetails(GetSubUserDetailsEvent event, Emitter<SubUsersState> emit) async {
    emit(SubUserDetailsLoading());
    final result = await getSubUserDetailsUsecase(
        GetSubUserDetailsParams(
            userId: event.subUserDetailsParams.userId,
            subUserCode: event.subUserDetailsParams.subUserCode,
            isNewSubUser: event.subUserDetailsParams.isNewSubUser
        )
    );
    result.fold(
          (failure) => emit(SubUserDetailsError(message: failure.message)),
          (subUserDetails) {
        emit(SubUserDetailsLoaded(subUserDetails: subUserDetails));
      },
    );
  }

  Future<void> _onUpdateSelection(
      UpdateControllerSelectionEvent event,
      Emitter<SubUsersState> emit,
      ) async {
    if (state is SubUserDetailsLoaded) {
      final currentState = state as SubUserDetailsLoaded;
      // Create immutable copy and update
      final updatedList = List<SubUserControllerEntity>.from(currentState.subUserDetails.controllerList);
      final controller = updatedList[event.controllerIndex];
      updatedList[event.controllerIndex] = SubUserControllerEntity(
        userDeviceId: controller.userDeviceId,
        productId: controller.productId,
        deviceName: controller.deviceName,
        deviceId: controller.deviceId,
        simNumber: controller.simNumber,
        dndStatus: controller.dndStatus,
        shareFlag: event.isSelected ? 1 : 0,
      );
      final updatedDetails = SubUserDetailsEntity(
        subUserDetail: currentState.subUserDetails.subUserDetail,
        controllerList: updatedList,
      );
      emit(SubUserDetailsLoaded(subUserDetails: updatedDetails));
    }
  }

  Future<void> _onUpdateDnd(
      UpdateControllerDndEvent event,
      Emitter<SubUsersState> emit,
      ) async {
    if (state is SubUserDetailsLoaded) {
      final currentState = state as SubUserDetailsLoaded;
      final updatedList = List<SubUserControllerEntity>.from(currentState.subUserDetails.controllerList);
      final controller = updatedList[event.controllerIndex];
      updatedList[event.controllerIndex] = SubUserControllerEntity(
        userDeviceId: controller.userDeviceId,
        productId: controller.productId,
        deviceName: controller.deviceName,
        deviceId: controller.deviceId,
        simNumber: controller.simNumber,
        dndStatus: event.isEnabled ? '1' : '0',
        shareFlag: controller.shareFlag,
      );
      final updatedDetails = SubUserDetailsEntity(
        subUserDetail: currentState.subUserDetails.subUserDetail,
        controllerList: updatedList,
      );
      emit(SubUserDetailsLoaded(subUserDetails: updatedDetails));
    }
  }

  Future<void> _onUpdateDetails(
      SubUserDetailsUpdateEvent event,
      Emitter<SubUsersState> emit,
      ) async {
    emit(SubUserDetailsUpdateStarted());
    final result = await updateSubUserDetailsUseCase(event.updatedDetails);
    result.fold(
          (failure) => emit(SubUserDetailsUpdateError(message: failure.message)),
          (message) => emit(SubUserDetailsUpdateSuccess(message: message)),
    );
  }

  Future<void> _onGetUserByPhone(
      GetSubUserByPhoneEvent event,
      Emitter<SubUsersState> emit,
      ) async {
    if (state is SubUserDetailsLoaded) {
      final currentState = state as SubUserDetailsLoaded;
      final result = await getSubUserByPhoneUsecase(
        GetSubUserByPhoneParams(phoneNumber: event.getSubUserByPhoneParams.phoneNumber),
      );
      result.fold(
            (failure) => emit(
          GetSubUserByPhoneError(
            message: failure.message,
            subUserDetails: currentState.subUserDetails,
          ),
        ),
            (subUserModel) {
          print("subUserModel :: $subUserModel");
          if (subUserModel is! Map<String, dynamic>) {
            emit(GetSubUserByPhoneError(
              message: 'Invalid subUserModel format',
              subUserDetails: currentState.subUserDetails,
            ));
            return;
          }

          final userName = subUserModel['userName'];
          final subUserId = subUserModel['subUserId'];
          final mobileNumber = subUserModel['mobileNumber'];

          final updatedSubUserDetail = currentState.subUserDetails.subUserDetail.copyWith(
            userName: userName,
            subuserId: subUserId,
            mobileNumber: mobileNumber
          );
          final updatedDetails = SubUserDetailsEntity(
            subUserDetail: updatedSubUserDetail,
            controllerList: currentState.subUserDetails.controllerList,
          );
          emit(SubUserDetailsLoaded(subUserDetails: updatedDetails));
        },
      );
    }
  }
}