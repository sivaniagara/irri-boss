import 'dart:async';
import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/utils/dashboard_routes.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/ble/mqtt_or_ble.dart';
import '../../../../core/services/mqtt/mqtt_manager.dart';
import '../../../../core/services/mqtt/publish_messages.dart';
import '../../../../core/utils/app_constants.dart';
import '../../dashboard.dart';
import '../../domain/usecases/control_motor_usecase.dart';
import '../../domain/usecases/update_change_from_usecase.dart';

import 'package:niagara_smart_drip_irrigation/core/utils/log.dart';

import '../pages/dashboard_2_0.dart';
enum ChangeFromStatus { initial, loading, success, failure }

enum ControlMotorStatus { initial, loading, success, failure }

enum ManualModeStatus { initial, loading, success, failure }

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
  final ManualModeStatus manualModeStatus;
  final String errorMsg;

  DashboardGroupsLoaded({
    required this.groups,
    this.groupControllers = const {},
    this.selectedGroupId,
    this.selectedControllerIndex,
    this.changeFromStatus = ChangeFromStatus.initial,
    this.controlMotorStatus = ControlMotorStatus.initial,
    this.manualModeStatus = ManualModeStatus.initial,
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
    manualModeStatus,
    errorMsg
  ];

  DashboardGroupsLoaded copyWith({
    List<GroupDetailsEntity>? groups,
    Map<int, List<ControllerEntity>>? groupControllers,
    int? selectedGroupId,
    int? selectedControllerIndex,
    ChangeFromStatus? changeFromStatus,
    ControlMotorStatus? controlMotorStatus,
    ManualModeStatus? manualModeStatus,
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
      manualModeStatus: manualModeStatus ?? this.manualModeStatus,
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

  final Map<String, Timer> _deviceOnDelayTimers = {};
  final Map<String, int> _deviceOnDelaySeconds = {};

  DashboardPageCubit({
    required this.fetchDashboardGroups,
    required this.fetchControllers,
    required this.updateChangeFromUsecase,
    required this.controlMotorUsecase,
  }) : super(DashboardInitial());

  /// ---------------- TIMER FUNCTIONS ----------------

  int _timeToSeconds(String time) {
    try {
      final cleanTime = time.replaceAll(RegExp(r'[^0-9:]'), '').trim();
      if (cleanTime.isEmpty) return 0;

      final parts = cleanTime.split(':');
      // Handle HH:MM:SS or MM:SS or SS
      if (parts.length == 3) {
        final h = int.parse(parts[0]);
        final m = int.parse(parts[1]);
        final s = int.parse(parts[2]);
        return h * 3600 + m * 60 + s;
      } else if (parts.length == 2) {
        final m = int.parse(parts[0]);
        final s = int.parse(parts[1]);
        return m * 60 + s;
      } else if (parts.length == 1) {
        return int.parse(parts[0]);
      }
      return 0;
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

  String? _selectedDeviceId([DashboardGroupsLoaded? currentState]) {
    final loadedState = currentState ??
        (state is DashboardGroupsLoaded
            ? state as DashboardGroupsLoaded
            : null);
    if (loadedState == null) return null;

    final groupId = loadedState.selectedGroupId;
    final controllerIndex = loadedState.selectedControllerIndex;
    if (groupId == null || controllerIndex == null) return null;

    final controllers =
        loadedState.groupControllers[groupId] ?? const <ControllerEntity>[];
    if (controllerIndex < 0 || controllerIndex >= controllers.length) return null;

    return controllers[controllerIndex].deviceId;
  }

  void _cancelTimerForDevice(String deviceId) {
    _deviceTimers.remove(deviceId)?.cancel();
    _deviceRemainingSeconds.remove(deviceId);

    _deviceOnDelayTimers.remove(deviceId)?.cancel();
    _deviceOnDelaySeconds.remove(deviceId);
  }

  void _cancelInactiveDeviceTimers(String? activeDeviceId) {
    final deviceIds = _deviceTimers.keys.toList(growable: false);
    for (final deviceId in deviceIds) {
      if (activeDeviceId == null || deviceId != activeDeviceId) {
        _cancelTimerForDevice(deviceId);
      }
    }

    final onDelayDeviceIds = _deviceOnDelayTimers.keys.toList(growable: false);
    for (final deviceId in onDelayDeviceIds) {
      if (activeDeviceId == null || deviceId != activeDeviceId) {
        _cancelTimerForDevice(deviceId);
      }
    }
  }

  /// Starts (or restarts) the on-delay local countdown for [deviceId] at
  /// [startSeconds] and ticks it down once per real second, independent of
  /// how often live packets arrive.
  void _startOnDelayCountdown(String deviceId, int startSeconds) {
    _deviceOnDelayTimers[deviceId]?.cancel();
    _deviceOnDelaySeconds[deviceId] = startSeconds;

    _deviceOnDelayTimers[deviceId] =
        Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_selectedDeviceId() != deviceId) {
            _cancelTimerForDevice(deviceId);
            return;
          }

          if (_deviceOnDelaySeconds[deviceId] == null ||
              _deviceOnDelaySeconds[deviceId]! <= 0) {
            timer.cancel();
            _deviceOnDelayTimers.remove(deviceId);
            _deviceOnDelaySeconds.remove(deviceId);
            return;
          }

          _deviceOnDelaySeconds[deviceId] = _deviceOnDelaySeconds[deviceId]! - 1;

          _updateSingleDeviceState(deviceId, (ctrl) {
            final model = ctrl as ControllerModel;
            return model.copyWith(
              liveMessage: model.liveMessage.copyWith(
                onDelayTimer: _secondsToTime(_deviceOnDelaySeconds[deviceId]!),
              ),
            );
          });
        });
  }

  /// Starts (or restarts) the zone-remaining local countdown for [deviceId]
  /// at [startSeconds] and ticks it down once per real second, independent
  /// of how often live packets arrive.
  void _startZoneCountdown(String deviceId, int startSeconds) {
    _deviceTimers[deviceId]?.cancel();
    _deviceRemainingSeconds[deviceId] = startSeconds;

    _deviceTimers[deviceId] =
        Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_selectedDeviceId() != deviceId) {
            _cancelTimerForDevice(deviceId);
            return;
          }

          if (_deviceRemainingSeconds[deviceId] == null ||
              _deviceRemainingSeconds[deviceId]! <= 0) {
            timer.cancel();
            _deviceTimers.remove(deviceId);
            _deviceRemainingSeconds.remove(deviceId);
            return;
          }

          _deviceRemainingSeconds[deviceId] =
              _deviceRemainingSeconds[deviceId]! - 1;

          _updateSingleDeviceState(deviceId, (ctrl) {
            final model = ctrl as ControllerModel;
            return model.copyWith(
              liveMessage: model.liveMessage.copyWith(
                zoneRemainingTime:
                _secondsToTime(_deviceRemainingSeconds[deviceId]!),
              ),
            );
          });
        });
  }

  void _manageOnDelayTimer(String deviceId, LiveMessageEntity liveMessage) {
    final activeDeviceId = _selectedDeviceId();
    if (activeDeviceId != null && activeDeviceId != deviceId) {
      _cancelTimerForDevice(deviceId);
      return;
    }

    _cancelInactiveDeviceTimers(deviceId);

    int hardwareOnDelay = _timeToSeconds(liveMessage.onDelayTimer);
    if (hardwareOnDelay <= 0) {
      _deviceOnDelayTimers[deviceId]?.cancel();
      _deviceOnDelayTimers.remove(deviceId);
      _deviceOnDelaySeconds.remove(deviceId);
      return;
    }

    final bool hasRunningTimer = _deviceOnDelayTimers[deviceId] != null;
    final int? currentOnDelay = _deviceOnDelaySeconds[deviceId];

    final bool freshCycle =
        currentOnDelay != null && hardwareOnDelay > currentOnDelay + 1;
    final bool badlyBehind =
        currentOnDelay != null && hardwareOnDelay < currentOnDelay - 5;

    if (!hasRunningTimer || freshCycle || badlyBehind) {
      _startOnDelayCountdown(deviceId, hardwareOnDelay);
    }
  }

  void _manageZoneTimer(String deviceId, LiveMessageEntity liveMessage) {
    final activeDeviceId = _selectedDeviceId();
    if (activeDeviceId != null && activeDeviceId != deviceId) {
      _cancelTimerForDevice(deviceId);
      return;
    }

    _cancelInactiveDeviceTimers(deviceId);

    // If motor is OFF, stop any existing timer for this device
    if (liveMessage.motorOnOff == '0') {
      _cancelTimerForDevice(deviceId);
      return;
    }

    int hardwareRemaining = _timeToSeconds(liveMessage.zoneRemainingTime);
    if (hardwareRemaining <= 0) {
      // A stray zero/unparsable value from one packet shouldn't kill a
      // countdown that's already running — let it keep ticking locally.
      return;
    }

    final bool hasRunningTimer = _deviceTimers[deviceId] != null;
    final int? currentRemaining = _deviceRemainingSeconds[deviceId];

    // Same reasoning as the on-delay timer above: only resync for a fresh
    // zone cycle or a large catch-up, never for small per-packet jitter.
    final bool freshCycle =
        currentRemaining != null && hardwareRemaining > currentRemaining + 1;
    final bool badlyBehind =
        currentRemaining != null && hardwareRemaining < currentRemaining - 5;

    if (!hasRunningTimer || freshCycle || badlyBehind) {
      _startZoneCountdown(deviceId, hardwareRemaining);
    }
  }

  /// Helper to update a single device in the complex groupControllers map
  void _updateSingleDeviceState(
      String deviceId,
      ControllerEntity Function(ControllerEntity) updateFn,
      ) {
    if (state is! DashboardGroupsLoaded) return;
    final currentState = state as DashboardGroupsLoaded;

    final updatedGroupControllers =
    Map<int, List<ControllerEntity>>.from(currentState.groupControllers);
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
    kdebugmode("fetchControllersForGroup");
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
          String? selectedDeviceId;

          if (newSelectedIndex == null && controllers.isNotEmpty) {
            newSelectedIndex = 0;
            selectedDeviceId = controllers[0].deviceId;

            sl<MqttManager>().subscribe(selectedDeviceId);
            sl<MqttManager>().publish(
              selectedDeviceId,
              crcModels.contains(controllers[0].modelId) ? AppConstants.sendWlcCommand("#live,$selectedDeviceId") :
              jsonEncode(PublishMessageHelper.requestLive),
            );
          } else if (newSelectedIndex != null &&
              newSelectedIndex < controllers.length) {
            selectedDeviceId = controllers[newSelectedIndex].deviceId;
          }

          _cancelInactiveDeviceTimers(selectedDeviceId);

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

  Future<(int modelId, int controllerId, String deviceId)> selectGroup(
      int groupId, int userId, GoRouterState routeState) async {
    kdebugmode("selectGroup");

    if (state is! DashboardGroupsLoaded) return (0, 0, '');
    final currentState = state as DashboardGroupsLoaded;

    final newState = currentState.copyWith(
      selectedGroupId: groupId,
      selectedControllerIndex: null,
    );
    emit(newState);

    emit(DashboardLoading());

    final result =
    await fetchControllers(UserGroupParams(userId, groupId, routeState));
    int firstControllerModelId = 0;
    int firstControllerControllerId = 0;
    String firstControllerDeviceId = '';

    final response = await result.fold(
          (failure) async {
        emit(DashboardError(message: failure.message));
        return (0, 0, '');
      },
          (controllers) async {

        final updatedControllers =
        Map<int, List<ControllerEntity>>.from(currentState.groupControllers);
        updatedControllers[groupId] = controllers;

        String? selectedDeviceId;
        if (controllers.isNotEmpty) {
          firstControllerModelId = controllers[0].modelId;
          firstControllerControllerId = controllers[0].userDeviceId;
          firstControllerDeviceId = controllers[0].deviceId;

          selectedDeviceId = controllers[0].deviceId;
          sl<MqttManager>().subscribe(selectedDeviceId);
          sl<MqttManager>().publish(
            selectedDeviceId,
            crcModels.contains(controllers[0].modelId) ? AppConstants.sendWlcCommand("#live,$selectedDeviceId") :
            jsonEncode(PublishMessageHelper.requestLive),
          );
        }

        _cancelInactiveDeviceTimers(selectedDeviceId);

        emit(DashboardGroupsLoaded(
          groups: currentState.groups,
          groupControllers: updatedControllers,
          selectedGroupId: groupId,
          selectedControllerIndex: controllers.isNotEmpty ? 0 : null,
        ));
        return (firstControllerModelId, firstControllerControllerId, firstControllerDeviceId);
      },
    );
    return response;
  }

  Future<void> selectController(int controllerIndex) async {
    kdebugmode('selectController');
    if (state is! DashboardGroupsLoaded) return;

    final currentState = state as DashboardGroupsLoaded;
    final groupId = currentState.selectedGroupId;
    if (groupId == null) return;

    final controllers = currentState.groupControllers[groupId] ?? [];
    if (controllerIndex >= controllers.length) return;

    final selectedController = controllers[controllerIndex];
    _cancelInactiveDeviceTimers(selectedController.deviceId);

    sl<MqttOrBle>().subscribe(selectedController.deviceId);
    sl<MqttOrBle>().publish(selectedController.deviceId,
        crcModels.contains(selectedController.modelId) ? AppConstants.sendWlcCommand("#live,${selectedController.deviceId}") :
        jsonEncode(PublishMessageHelper.requestLive));
    emit(currentState.copyWith(selectedControllerIndex: controllerIndex));
  }

  void getLive(String deviceId, int modelId) {
    sl<MqttOrBle>().publish(
        deviceId,
        (crcModels.contains(modelId) || AppConstants.isWlc(modelId))
            ? AppConstants.sendWlcCommand("#live,$deviceId")
            : jsonEncode(PublishMessageHelper.requestLive));
  }

  void resetDashboardSelection() {
    if (state is DashboardGroupsLoaded) {
      final currentState = state as DashboardGroupsLoaded;
      _cancelInactiveDeviceTimers(null);
      emit(currentState.copyWith(
        selectedGroupId: null,
        selectedControllerIndex: null,
      ));
    }
  }

  void updateLiveMessage(String deviceId, LiveMessageEntity liveMessage,
      {String? date, String? time, String? fullMsg, String? msgDesc}) {
    print("liveMessage : ${liveMessage}");
    if (state is! DashboardGroupsLoaded) return;

    // Manage Timers independently from state update to avoid recursion loop.
    // These calls are the SOURCE OF TRUTH for the two countdown fields below:
    // they either (a) leave the existing local per-second counter untouched
    // (normal case — packet arrived mid-countdown, nothing to do), or
    // (b) reset the counter to the hardware value if it has drifted by more
    // than 5s (e.g. motor just turned on, or we lost sync). Either way, after
    // these two calls _deviceOnDelaySeconds[deviceId] / _deviceRemainingSeconds[deviceId]
    // hold the correct current value to display.
    _manageZoneTimer(deviceId, liveMessage);
    _manageOnDelayTimer(deviceId, liveMessage);

    final formattedMessage = (fullMsg != null && fullMsg.trim().isNotEmpty)
        ? fullMsg.trim()
        : liveMessage.fullMessage;
    final latestMessageDescription =
    (msgDesc != null && msgDesc.trim().isNotEmpty)
        ? msgDesc.trim()
        : liveMessage.msgDesc;

    // IMPORTANT: don't take zoneRemainingTime / onDelayTimer straight from the
    // raw incoming packet here. Doing that was clobbering the smoothly
    // ticking local countdown on every single packet arrival — which is why
    // the timer looked "frozen" and only ever jumped when the hardware's own
    // reported value changed. Instead, read the live, ticking value from the
    // local counters that _manageZoneTimer/_manageOnDelayTimer just updated.
    final String displayZoneRemaining = liveMessage.motorOnOff == '0'
        ? "00:00:00"
        : (_deviceRemainingSeconds[deviceId] != null
        ? _secondsToTime(_deviceRemainingSeconds[deviceId]!)
        : liveMessage.zoneRemainingTime);

    final String displayOnDelay = (_deviceOnDelaySeconds[deviceId] != null && _deviceOnDelaySeconds[deviceId]! > 0)
        ? _secondsToTime(_deviceOnDelaySeconds[deviceId]!)
        : (liveMessage.isOnDelayTimerActive ? liveMessage.onDelayTimer : "00:00:00");

    final updatedLiveMessage = liveMessage.copyWith(
      zoneRemainingTime: displayZoneRemaining,
      onDelayTimer: displayOnDelay,
      fullMessage: formattedMessage,
      msgDesc: latestMessageDescription,
    );

    _updateSingleDeviceState(deviceId, (ctrl) {
      final model = ctrl as ControllerModel;
      return model.copyWith(
        liveMessage: updatedLiveMessage,
        livesyncDate: date,
        livesyncTime: time,
      );
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
          (_) {
        sl<MqttManager>().publish(deviceId, PublishMessageHelper.settingsPayload(payload));
        emit(currentState.copyWith(changeFromStatus: ChangeFromStatus.success));
      },
    );
  }

  Future<void> sendManualMode({
    required String deviceId,
    required String payload,
  }) async {
    if (state is! DashboardGroupsLoaded) return;
    final currentState = state as DashboardGroupsLoaded;

    emit(currentState.copyWith(manualModeStatus: ManualModeStatus.loading));

    try {
      sl<MqttOrBle>().publish(deviceId, AppConstants.sendWlcCommand('MANUAL,$payload'));
      await Future.delayed(const Duration(seconds: 5));
      emit(currentState.copyWith(manualModeStatus: ManualModeStatus.success));
    } catch (e) {
      emit(currentState.copyWith(
          manualModeStatus: ManualModeStatus.failure,
          errorMsg: e.toString()));
    }
  }

  Future<void> sendPumpCount({
    required String deviceId,
    required int count,
  }) async {
    if (state is! DashboardGroupsLoaded) return;
    final currentState = state as DashboardGroupsLoaded;

    // Standard format for setting pump count: PUMPCOUNT,X
    final command = 'PUMPCOUNT,$count';
    final payload = AppConstants.sendWlcCommand(command);

    try {
      // Send via MQTT
      sl<MqttOrBle>().publish(deviceId, payload);

      // We can also send to backend if needed, following the same pattern as controlMotor
      // For now, publishing via MQTT as requested.

      kdebugmode("Sent Pump Count: $payload");
    } catch (e) {
      kdebugmode("Error sending pump count: $e");
    }
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

    final cleanPayload = payload.replaceAll(",", "");

    // Get model ID
    int modelId = 4;
    for (var groupControllers in currentState.groupControllers.values) {
      for (var controller in groupControllers) {
        if (controller.deviceId == deviceId) {
          modelId = controller.modelId;
          break;
        }
      }
    }

    final isWlc = wlcModel.contains(modelId);
    final useCrc = crcModels.contains(modelId);

    if (cleanPayload.toUpperCase().contains("ON")) {
      /// -------------------- STEP 1: OFF FIRST --------------------
      dynamic offPayload;
      String offCommand = 'MTROF';

      if (useCrc) {
        offPayload = AppConstants.sendWlcCommand(offCommand);
      } else {
        offPayload = PublishMessageHelper.settingsPayload(offCommand);
      }

      if (!isWlc) {
        // ✅ Call API ONLY for NON-WLC
        await controlMotorUsecase(ControlMotorParams(
          userId: userId,
          controllerId: controllerId,
          programId: programId,
          deviceId: deviceId,
          payload: useCrc ? "$offPayload," : "MTROF,",
        ));
      }

      // ✅ MQTT for ALL
      sl<MqttOrBle>().publish(deviceId, offPayload);
      await Future.delayed(const Duration(seconds: 5));

      /// -------------------- STEP 2: ON COMMAND --------------------
      String onCommand;
      if (modelId == 27) {
        onCommand = cleanPayload.toUpperCase();
      } else {
        onCommand = "MTRON";
      }

      dynamic onPayload;
      if (useCrc) {
        onPayload = AppConstants.sendWlcCommand(onCommand);
      } else {
        onPayload = PublishMessageHelper.settingsPayload(onCommand);
      }

      if (isWlc) {
        // ❌ NO API CALL for WLC
        sl<MqttOrBle>().publish(deviceId, onPayload);

        emit(currentState.copyWith(
          controlMotorStatus: ControlMotorStatus.success,
        ));
      } else {
        // ✅ API call for NON-WLC
        final result = await controlMotorUsecase(ControlMotorParams(
          userId: userId,
          controllerId: controllerId,
          programId: programId,
          deviceId: deviceId,
          payload: useCrc ? "$onPayload," : "$onCommand,",
        ));

        result.fold(
              (failure) => emit(currentState.copyWith(
            controlMotorStatus: ControlMotorStatus.failure,
            errorMsg: failure.message,
          )),
              (_) {
            sl<MqttOrBle>().publish(deviceId, onPayload);

            emit(currentState.copyWith(
              controlMotorStatus: ControlMotorStatus.success,
            ));
          },
        );
      }
    } else {
      /// -------------------- OFF FLOW --------------------
      if (useCrc) {
        // ❌ No API call
        final offPayload = AppConstants.sendWlcCommand(cleanPayload);
        sl<MqttOrBle>().publish(deviceId, offPayload);

        if (!isWlc) {
          // ✅ API call for NON-WLC (e.g. Model 27)
          await controlMotorUsecase(ControlMotorParams(
            userId: userId,
            controllerId: controllerId,
            programId: programId,
            deviceId: deviceId,
            payload: "$offPayload,",
          ));
        }

        emit(currentState.copyWith(
          controlMotorStatus: ControlMotorStatus.success,
        ));
      } else {
        // ✅ API + MQTT
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
            errorMsg: failure.message,
          )),
              (_) {
            sl<MqttOrBle>().publish(deviceId, PublishMessageHelper.settingsPayload(cleanPayload));

            emit(currentState.copyWith(
              controlMotorStatus: ControlMotorStatus.success,
            ));
          },
        );
      }
    }
  }


  void resetControlStatus() {
    if (state is DashboardGroupsLoaded) {
      final currentState = state as DashboardGroupsLoaded;
      emit(currentState.copyWith(
        controlMotorStatus: ControlMotorStatus.initial,
        changeFromStatus: ChangeFromStatus.initial,
        manualModeStatus: ManualModeStatus.initial,
      ));
    }
  }

  @override
  Future<void> close() {
    for (final t in _deviceTimers.values) {
      t.cancel();
    }
    for (final t in _deviceOnDelayTimers.values) {
      t.cancel();
    }
    return super.close();
  }
}