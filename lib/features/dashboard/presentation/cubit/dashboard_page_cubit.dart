import 'dart:async';
import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/services/mqtt/mqtt_service.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/utils/dashboard_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/dealer_dashboard/utils/dealer_routes.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/mqtt/mqtt_manager.dart';
import '../../../../core/services/mqtt/publish_messages.dart';
import '../../../../core/services/selected_controller_persistence.dart';
import '../../dashboard.dart';
import '../../domain/usecases/control_motor_usecase.dart';
import '../../domain/usecases/update_change_from_usecase.dart';

enum ChangeFromStatus {initial, loading, success, failure}
enum ControlMotorStatus {initial, loading, success, failure}

abstract class DashboardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardGroupsLoaded extends DashboardState {
  final List<GroupDetailsEntity> groups;
  final Map<int, List<ControllerEntity>> groupControllers;
  final int? selectedGroupId;
  final int? selectedControllerIndex;
  final ChangeFromStatus changeFromStatus;
  final ControlMotorStatus controlMotorStatus;
  final String errorMsg;

  DashboardGroupsLoaded({
    required this.groups,
    this.groupControllers = const {},
    this.selectedGroupId,
    this.selectedControllerIndex,
    this.changeFromStatus = ChangeFromStatus.initial,
    this.controlMotorStatus = ControlMotorStatus.initial,
    this.errorMsg = '',
  });

  @override
  List<Object?> get props => [groups, groupControllers, selectedGroupId, selectedControllerIndex, changeFromStatus, controlMotorStatus, errorMsg];

  DashboardGroupsLoaded copyWith({
    List<GroupDetailsEntity>? groups,
    Map<int, List<ControllerEntity>>? groupControllers,
    int? selectedGroupId,
    int? selectedControllerIndex,
    ChangeFromStatus? changeFromStatus,
    ControlMotorStatus? controlMotorStatus,
    String? errorMsg,
  }) {
    return DashboardGroupsLoaded(
      groups: groups ?? this.groups,
      groupControllers: groupControllers ?? this.groupControllers,
      selectedGroupId: selectedGroupId ?? this.selectedGroupId,
      selectedControllerIndex: selectedControllerIndex ?? this.selectedControllerIndex,
      changeFromStatus: changeFromStatus ?? this.changeFromStatus,
      controlMotorStatus: controlMotorStatus ?? this.controlMotorStatus,
      errorMsg: errorMsg ?? this.errorMsg,
    );
  }
}

class DashboardError extends DashboardState {
  final String message;
  DashboardError({required this.message});

  @override
  List<Object?> get props => [message];
}

class DashboardPageCubit extends Cubit<DashboardState> {
  final FetchDashboardGroups fetchDashboardGroups;
  final FetchControllers fetchControllers;
  final UpdateChangeFromUsecase updateChangeFromUsecase;
  final ControlMotorUsecase controlMotorUsecase;

  DashboardPageCubit({
    required this.fetchDashboardGroups,
    required this.fetchControllers,
    required this.updateChangeFromUsecase,
    required this.controlMotorUsecase,
  }) : super(DashboardInitial());

  Future<void> getGroups(int userId, GoRouterState routeState, int userType) async {
    emit(DashboardLoading());

    if (userType == 2 && (routeState.extra != null && (routeState.extra as Map<String, dynamic>)['name'] != DashBoardRoutes.dashboard)) {
      final fakeGroup = GroupDetailsEntity(
        userGroupId: 0,
        groupName: 'All Controllers',
        userId: userId,
      );

      emit(DashboardGroupsLoaded(
        groups: [fakeGroup],
        groupControllers: {},
        selectedGroupId: 0,
        selectedControllerIndex: null,
      ));

      await fetchControllersForGroup(userId, 0, routeState);
    } else {
      final result = await fetchDashboardGroups(DashboardGroupsParams(userId, routeState));

      result.fold(
            (failure) => emit(DashboardError(message: failure.message)),
            (groups) {
          emit(DashboardGroupsLoaded(groups: groups, groupControllers: {}));
          if (groups.isNotEmpty) {
            fetchControllersForGroup(userId, groups[0].userGroupId, routeState);
          }
        },
      );
    }
  }

  Future<void> fetchControllersForGroup(int userId, int groupId, GoRouterState routeState) async {
    if (state is DashboardGroupsLoaded) {
      final currentState = state as DashboardGroupsLoaded;
      final result = await fetchControllers(UserGroupParams(userId, groupId, routeState));

      final updatedControllers = Map<int, List<ControllerEntity>>.from(currentState.groupControllers);

      result.fold(
            (failure) => emit(DashboardError(message: failure.message)),
            (controllers) {
          updatedControllers[groupId] = controllers;

          int? newSelectedIndex = currentState.selectedControllerIndex;

          if (newSelectedIndex == null && controllers.isNotEmpty) {
            newSelectedIndex = 0;

            sl<MqttManager>().subscribe(controllers[0].deviceId);
            sl<MqttManager>().publish(controllers[0].deviceId, jsonEncode(PublishMessageHelper.requestLive));
          }

          emit(DashboardGroupsLoaded(
            groups: currentState.groups,
            groupControllers: updatedControllers,
            selectedGroupId: currentState.selectedGroupId,
            selectedControllerIndex: newSelectedIndex,
          ));
        },
      );
    }
  }

  Future<void> selectGroup(int groupId, int userId, GoRouterState routeState) async {
    if (state is! DashboardGroupsLoaded) return;

    final currentState = state as DashboardGroupsLoaded;

    final newState = currentState.copyWith(
      selectedGroupId: groupId,
      selectedControllerIndex: null,
    );
    emit(newState);

    currentState.groups.firstWhere(
          (g) => g.userGroupId == groupId,
      orElse: () => throw Exception('Group not found'),
    );

    emit(DashboardLoading());

    final result = await fetchControllers(UserGroupParams(userId, groupId, routeState));

    await result.fold(
          (failure) async {
        emit(DashboardError(message: failure.message));
      },
          (controllers) async {
        final updatedControllers = Map<int, List<ControllerEntity>>.from(currentState.groupControllers);
        updatedControllers[groupId] = controllers;

        if (controllers.isNotEmpty) {
          sl<MqttManager>().subscribe(controllers[0].deviceId);
          sl<MqttManager>().publish(controllers[0].deviceId, jsonEncode(PublishMessageHelper.requestLive));
        }

        emit(DashboardGroupsLoaded(
          groups: currentState.groups,
          groupControllers: updatedControllers,
          selectedGroupId: groupId,
          selectedControllerIndex: controllers.isNotEmpty ? 0 : null,
        ));
      },
    );
  }

  Future<void> selectController(int controllerIndex) async {
    if (state is! DashboardGroupsLoaded) return;

    final currentState = state as DashboardGroupsLoaded;
    final groupId = currentState.selectedGroupId;
    if (groupId == null) return;

    final controllers = currentState.groupControllers[groupId] ?? [];
    if (controllerIndex >= controllers.length) return;

    final selectedController = controllers[controllerIndex];

    sl<MqttManager>().subscribe(selectedController.deviceId);
    sl<MqttManager>().publish(selectedController.deviceId, jsonEncode(PublishMessageHelper.requestLive));
    emit(currentState.copyWith(selectedControllerIndex: controllerIndex));
  }

  void getLive(String deviceId){
    sl<MqttManager>().publish(deviceId, jsonEncode(PublishMessageHelper.requestLive));
  }

  void resetDashboardSelection() {
    if (state is DashboardGroupsLoaded) {
      final currentState = state as DashboardGroupsLoaded;
      emit(currentState.copyWith(
        selectedGroupId: null,
        selectedControllerIndex: null,
      ));
    }
  }

  void updateLiveMessage(String deviceId, dynamic liveMessage) {
    print('liveMessage ::: $liveMessage');
    print("state ==> ${state}");
    if (state is! DashboardGroupsLoaded) return;

    final currentState = state as DashboardGroupsLoaded;
    final updatedGroupControllers = Map<int, List<ControllerEntity>>.from(currentState.groupControllers);
    bool updated = false;

    // sl.get<MqttService>().updates.listen((message) {
    //   liveMessage = message;
    // });
    print("updatedGroupControllers => ${updatedGroupControllers}");
    for (final entry in updatedGroupControllers.entries) {
      print('entry.key ::: ${entry.key}');
      final groupId = entry.key;
      final controllers = entry.value;
      final updatedControllersList = <ControllerEntity>[];

      bool groupUpdated = false;

      for (final ctrl in controllers) {
        if (ctrl.deviceId == deviceId) {
          final model = ctrl as ControllerModel;
          print("liveMessage => $liveMessage");
          print("liveMessage => ${liveMessage.runtimeType}");
          final updatedCtrl = model.copyWith(liveMessage: liveMessage);
          updatedControllersList.add(updatedCtrl);
          groupUpdated = true;
          updated = true;
        } else {
          updatedControllersList.add(ctrl);
        }
      }

      if (groupUpdated) {
        updatedGroupControllers[groupId] = updatedControllersList;
      }
    }

    if (updated) {
      emit(currentState.copyWith(groupControllers: updatedGroupControllers));
    }
  }

  void updateChangeFrom({
    required String userId,
    required String controllerId,
    required String programId,
    required String deviceId,
    required String payload,
  }) async {
    if (state is! DashboardGroupsLoaded) return;

    // 1. First — go to loading
    var current = state as DashboardGroupsLoaded;
    emit(current.copyWith(changeFromStatus: ChangeFromStatus.loading));

    try {
      final param = UpdateChangeFromParam(
        userId: userId,
        controllerId: controllerId,
        programId: programId,
        deviceId: deviceId,
        payload: payload,
      );

      // Send MQTT command
      sl<MqttManager>().publish(
        deviceId,
        PublishMessageHelper.settingsPayload(payload),
      );

      // Call backend / confirmation logic
      final result = await updateChangeFromUsecase(param);

      result.fold(
            (failure) {
          emit(current.copyWith(
            changeFromStatus: ChangeFromStatus.failure,
            errorMsg: failure.message,
          ));
          emit(current.copyWith(
            changeFromStatus: ChangeFromStatus.initial,
            errorMsg: '',
          ));
        },
            (success) {
          emit(current.copyWith(
            changeFromStatus: ChangeFromStatus.success,
          ));
          emit(current.copyWith(
            changeFromStatus: ChangeFromStatus.initial,
            errorMsg: '',
          ));
        },
      );
    } catch (e) {
      emit(current.copyWith(
        changeFromStatus: ChangeFromStatus.failure,
        errorMsg: e.toString(),
      ));
      emit(current.copyWith(
        changeFromStatus: ChangeFromStatus.initial,
        errorMsg: '',
      ));
    }
  }

  void controlMotorStatus({
    required String userId,
    required String controllerId,
    required String programId,
    required String deviceId,
    required String payload,
  }) async {
    if (state is! DashboardGroupsLoaded) return;

    // 1. First — go to loading
    var current = state as DashboardGroupsLoaded;
    emit(current.copyWith(controlMotorStatus: ControlMotorStatus.loading));

    try {
      final param = ControlMotorParams(
        userId: userId,
        controllerId: controllerId,
        programId: programId,
        deviceId: deviceId,
        payload: payload,
      );

      // Send MQTT command
      sl<MqttManager>().publish(
        deviceId,
        PublishMessageHelper.settingsPayload(payload),
      );

      // Call backend / confirmation logic
      final result = await controlMotorUsecase(param);

      result.fold(
            (failure) {
          emit(current.copyWith(
            controlMotorStatus: ControlMotorStatus.failure,
            errorMsg: failure.message,
          ));
          emit(current.copyWith(
            controlMotorStatus: ControlMotorStatus.initial,
            errorMsg: '',
          ));
        },
            (success) {
          emit(current.copyWith(
            controlMotorStatus: ControlMotorStatus.success,
          ));
          emit(current.copyWith(
            controlMotorStatus: ControlMotorStatus.initial,
            errorMsg: '',
          ));
        },
      );
    } catch (e) {
      emit(current.copyWith(
        controlMotorStatus: ControlMotorStatus.failure,
        errorMsg: e.toString(),
      ));
      emit(current.copyWith(
        controlMotorStatus: ControlMotorStatus.initial,
        errorMsg: '',
      ));
    }
  }
}