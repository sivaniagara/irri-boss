import 'dart:async';
import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/utils/dashboard_routes.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/mqtt/mqtt_manager.dart';
import '../../../../core/services/mqtt/publish_messages.dart';
import '../../dashboard.dart';
import '../../domain/usecases/control_motor_usecase.dart';
import '../../domain/usecases/update_change_from_usecase.dart';

enum ChangeFromStatus { initial, loading, success, failure }

enum ControlMotorStatus { initial, loading, success, failure }

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
  List<Object?> get props => [
        groups,
        groupControllers,
        selectedGroupId,
        selectedControllerIndex,
        changeFromStatus,
        controlMotorStatus,
        errorMsg
      ];

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
      selectedControllerIndex:
          selectedControllerIndex ?? this.selectedControllerIndex,
      changeFromStatus: changeFromStatus ?? this.changeFromStatus,
      controlMotorStatus: controlMotorStatus ?? this.controlMotorStatus,
      errorMsg: errorMsg ?? this.errorMsg,
    );
  }
}

class DashboardError extends DashboardState {
  final String message;

  @override
  List<Object?> get props => [message];

  DashboardError({required this.message});
}

class DashboardPageCubit extends Cubit<DashboardState> {
  final FetchDashboardGroups fetchDashboardGroups;
  final FetchControllers fetchControllers;
  final UpdateChangeFromUsecase updateChangeFromUsecase;
  final ControlMotorUsecase controlMotorUsecase;

  /// TIMER VARIABLES - Now per device
  final Map<String, Timer> _deviceTimers = {};
  final Map<String, int> _deviceRemainingSeconds = {};

  DashboardPageCubit({
    required this.fetchDashboardGroups,
    required this.fetchControllers,
    required this.updateChangeFromUsecase,
    required this.controlMotorUsecase,
  }) : super(DashboardInitial());

  /// ---------------- TIMER FUNCTIONS ----------------

  int _timeToSeconds(String time) {
    try {
      final parts = time.split(':');
      if (parts.length < 3) return 0;
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final s = int.parse(parts[2]);
      return h * 3600 + m * 60 + s;
    } catch (_) {
      return 0;
    }
  }

  String _secondsToTime(int seconds) {
    if (seconds < 0) seconds = 0;
    final h = (seconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$h:$m:$s";
  }

  void _manageZoneTimer(String deviceId, LiveMessageEntity liveMessage) {
    // If motor is OFF, stop any existing timer for this device
    if (liveMessage.motorOnOff == '0') {
      _deviceTimers[deviceId]?.cancel();
      _deviceTimers.remove(deviceId);
      _deviceRemainingSeconds.remove(deviceId);
      return;
    }

    // If motor is ON
    int newRemaining = _timeToSeconds(liveMessage.zoneRemainingTime);
    
    // Check if we should update/start timer
    // We update if no timer exists OR if the hardware time drifted by more than 5 seconds
    int? currentRemaining = _deviceRemainingSeconds[deviceId];
    bool shouldReset = _deviceTimers[deviceId] == null || 
                      (currentRemaining != null && (newRemaining - currentRemaining).abs() > 5);

    if (shouldReset && newRemaining > 0) {
      _deviceTimers[deviceId]?.cancel();
      _deviceRemainingSeconds[deviceId] = newRemaining;
      
      _deviceTimers[deviceId] = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_deviceRemainingSeconds[deviceId] == null || _deviceRemainingSeconds[deviceId]! <= 0) {
          timer.cancel();
          _deviceTimers.remove(deviceId);
          return;
        }

        _deviceRemainingSeconds[deviceId] = _deviceRemainingSeconds[deviceId]! - 1;

        // Update state with decremented time
        _updateSingleDeviceState(deviceId, (ctrl) {
          final model = ctrl as ControllerModel;
          return model.copyWith(
            liveMessage: model.liveMessage.copyWith(
              zoneRemainingTime: _secondsToTime(_deviceRemainingSeconds[deviceId]!),
            ),
          );
        });
      });
    }
  }

  /// Helper to update a single device in the complex groupControllers map
  void _updateSingleDeviceState(String deviceId, ControllerEntity Function(ControllerEntity) updateFn) {
    if (state is! DashboardGroupsLoaded) return;
    final currentState = state as DashboardGroupsLoaded;
    
    final updatedGroupControllers = Map<int, List<ControllerEntity>>.from(currentState.groupControllers);
    bool anyUpdated = false;

    updatedGroupControllers.forEach((groupId, controllers) {
      final index = controllers.indexWhere((c) => c.deviceId == deviceId);
      if (index != -1) {
        final newList = List<ControllerEntity>.from(controllers);
        newList[index] = updateFn(controllers[index]);
        updatedGroupControllers[groupId] = newList;
        anyUpdated = true;
      }
    });

    if (anyUpdated) {
      emit(currentState.copyWith(groupControllers: updatedGroupControllers));
    }
  }

  /// -------------------------------------------------

  Future<void> getGroups(
      int userId, GoRouterState routeState, int userType) async {
    emit(DashboardLoading());

    if (userType == 2 &&
        (routeState.extra != null &&
            (routeState.extra as Map<String, dynamic>)['name'] !=
                DashBoardRoutes.dashboard)) {
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
      final result =
          await fetchDashboardGroups(DashboardGroupsParams(userId, routeState));

      result.fold(
        (failure) => emit(DashboardError(message: failure.message)),
        (groups) {
          int? selectedId = groups.isNotEmpty ? groups[0].userGroupId : null;
          emit(DashboardGroupsLoaded(
            groups: groups,
            groupControllers: {},
            selectedGroupId: selectedId,
          ));
          if (groups.isNotEmpty) {
            fetchControllersForGroup(userId, groups[0].userGroupId, routeState);
          }
        },
      );
    }
  }

  Future<void> fetchControllersForGroup(
      int userId, int groupId, GoRouterState routeState) async {
    if (state is DashboardGroupsLoaded) {
      final currentState = state as DashboardGroupsLoaded;
      final result =
          await fetchControllers(UserGroupParams(userId, groupId, routeState));

      final updatedControllers =
          Map<int, List<ControllerEntity>>.from(currentState.groupControllers);

      result.fold(
        (failure) => emit(DashboardError(message: failure.message)),
        (controllers) {
          updatedControllers[groupId] = controllers;

          int? newSelectedIndex = currentState.selectedControllerIndex;

          if (newSelectedIndex == null && controllers.isNotEmpty) {
            newSelectedIndex = 0;

            sl<MqttManager>().subscribe(controllers[0].deviceId);
            sl<MqttManager>().publish(controllers[0].deviceId,
                jsonEncode(PublishMessageHelper.requestLive));
          }

          emit(DashboardGroupsLoaded(
            groups: currentState.groups,
            groupControllers: updatedControllers,
            selectedGroupId: currentState.selectedGroupId ?? groupId,
            selectedControllerIndex: newSelectedIndex,
          ));
        },
      );
    }
  }

  Future<void> selectGroup(
      int groupId, int userId, GoRouterState routeState) async {
    if (state is! DashboardGroupsLoaded) return;

    final currentState = state as DashboardGroupsLoaded;

    final newState = currentState.copyWith(
      selectedGroupId: groupId,
      selectedControllerIndex: null,
    );
    emit(newState);

    emit(DashboardLoading());

    final result =
        await fetchControllers(UserGroupParams(userId, groupId, routeState));

    await result.fold(
      (failure) async {
        emit(DashboardError(message: failure.message));
      },
      (controllers) async {
        final updatedControllers =
            Map<int, List<ControllerEntity>>.from(currentState.groupControllers);
        updatedControllers[groupId] = controllers;

        if (controllers.isNotEmpty) {
          sl<MqttManager>().subscribe(controllers[0].deviceId);
          sl<MqttManager>().publish(controllers[0].deviceId,
              jsonEncode(PublishMessageHelper.requestLive));
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
    sl<MqttManager>().publish(selectedController.deviceId,
        jsonEncode(PublishMessageHelper.requestLive));
    emit(currentState.copyWith(selectedControllerIndex: controllerIndex));
  }

  void getLive(String deviceId) {
    sl<MqttManager>()
        .publish(deviceId, jsonEncode(PublishMessageHelper.requestLive));
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

  void updateLiveMessage(String deviceId, LiveMessageEntity liveMessage,
      {String? date, String? time, String? fullMsg, String? msgDesc}) {
    if (state is! DashboardGroupsLoaded) return;

    // Manage Timer independently from state update to avoid recursion loop
    _manageZoneTimer(deviceId, liveMessage);
    
    // If motor is off, ensure display is 0
    if (liveMessage.motorOnOff == '0') {
      liveMessage = liveMessage.copyWith(zoneRemainingTime: "00:00:00");
    }

    _updateSingleDeviceState(deviceId, (ctrl) {
      final model = ctrl as ControllerModel;
      return model.copyWith(
          liveMessage: liveMessage,
          livesyncDate: date,
          livesyncTime: time,
          ctrlLatestMsg: fullMsg,
          msgDesc: msgDesc);
    });
  }

  void updateControllerMessage(String deviceId,
      {String? fullMsg, String? msgDesc}) {
    _updateSingleDeviceState(deviceId, (ctrl) {
      final model = ctrl as ControllerModel;
      return model.copyWith(ctrlLatestMsg: fullMsg, msgDesc: msgDesc);
    });
  }

  void updateServerTime(String deviceId, {String? date, String? time}) {
    if (state is! DashboardGroupsLoaded) return;
    final currentState = state as DashboardGroupsLoaded;

    final newGroupControllers =
    Map<int, List<ControllerEntity>>.from(currentState.groupControllers);

    bool updated = false;

    newGroupControllers.forEach((groupId, controllers) {
      final index = controllers.indexWhere((c) => c.deviceId == deviceId);
      if (index != -1) {
        final List<ControllerEntity> updatedList = List.from(controllers);
        updatedList[index] = updatedList[index].copyWith(
          livesyncDate: date,
          livesyncTime: time,
        );
        newGroupControllers[groupId] = updatedList;
        updated = true;
      }
    });

    if (updated && !isClosed) {
      emit(currentState.copyWith(groupControllers: newGroupControllers));
    }
  }

  Future<void> updateChangeFrom({
    required String userId,
    required String controllerId,
    required String programId,
    required String deviceId,
    required String payload,
  }) async {
    if (state is! DashboardGroupsLoaded) return;
    final currentState = state as DashboardGroupsLoaded;

    emit(currentState.copyWith(changeFromStatus: ChangeFromStatus.loading));

    final result = await updateChangeFromUsecase(UpdateChangeFromParam(
      userId: userId,
      controllerId: controllerId,
      programId: programId,
      deviceId: deviceId,
      payload: payload,
    ));

    result.fold(
      (failure) => emit(currentState.copyWith(
          changeFromStatus: ChangeFromStatus.failure,
          errorMsg: failure.message)),
      (_) => emit(
          currentState.copyWith(changeFromStatus: ChangeFromStatus.success)),
    );
  }

  Future<void> controlMotorStatus({
    required String userId,
    required String controllerId,
    required String programId,
    required String deviceId,
    required String payload,
  }) async {
    if (state is! DashboardGroupsLoaded) return;
    final currentState = state as DashboardGroupsLoaded;

    emit(currentState.copyWith(controlMotorStatus: ControlMotorStatus.loading));

    final result = await controlMotorUsecase(ControlMotorParams(
      userId: userId,
      controllerId: controllerId,
      programId: programId,
      deviceId: deviceId,
      payload: payload,
    ));

    result.fold(
      (failure) => emit(currentState.copyWith(
          controlMotorStatus: ControlMotorStatus.failure,
          errorMsg: failure.message)),
      (_) => emit(
          currentState.copyWith(controlMotorStatus: ControlMotorStatus.success)),
    );
  }

  @override
  Future<void> close() {
    for (final t in _deviceTimers.values) {
      t.cancel();
    }
    return super.close();
  }
}
