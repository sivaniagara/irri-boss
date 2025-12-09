import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart' as di;
import '../../../../core/services/selected_controller_persistence.dart';
import '../../../mqtt/mqtt_barrel.dart';
import '../../dashboard.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final FetchDashboardGroups fetchDashboardGroups;
  final FetchControllers fetchControllers;
  final MqttBloc mqttBloc;
  Timer? _pollTimer;
  DateTime? _lastPollTime;
  bool _isPollingActive = false;

  DashboardBloc({
    required this.fetchDashboardGroups,
    required this.fetchControllers,
    required this.mqttBloc,
  }) : super(DashboardInitial()) {
    on<FetchDashboardGroupsEvent>((event, emit) async {
      emit(DashboardLoading());
      final result = await fetchDashboardGroups(DashboardGroupsParams(event.userId));

      result.fold(
            (failure) => emit(DashboardError(message: failure.message)),
            (groups) {
          emit(DashboardGroupsLoaded(groups: groups, groupControllers: {}));

          if (groups.isNotEmpty) {
            add(FetchControllersEvent(event.userId, groups[0].userGroupId));
          }
        },
      );
    });

    on<FetchControllersEvent>((event, emit) async {
      if (state is DashboardGroupsLoaded) {
        final currentState = state as DashboardGroupsLoaded;
        final result = await fetchControllers(UserGroupParams(event.userId, event.groupId));

        final updatedControllers = Map<int, List<ControllerEntity>>.from(currentState.groupControllers);
        result.fold(
              (failure) => emit(DashboardError(message: failure.message)),
              (controllers) {
            updatedControllers[event.groupId] = controllers;
            if (controllers.isNotEmpty) {
              mqttBloc.add(SubscribeMqttEvent(controllers[0].deviceId));
            }
            emit(DashboardGroupsLoaded(
              groups: currentState.groups,
              groupControllers: updatedControllers,
            ));
          },
        );
      }
    });

    on<SelectGroupEvent>((event, emit) async {
      if (state is! DashboardGroupsLoaded) return;

      final currentState = state as DashboardGroupsLoaded;

      // Step 1: Immediately update UI with selected group (optimistic)
      final newState = currentState.copyWith(
        selectedGroupId: event.groupId,
        selectedControllerIndex: null,
      );
      emit(newState);

      final group = currentState.groups.firstWhere(
            (g) => g.userGroupId == event.groupId,
        orElse: () => throw Exception('Group not found'),
      );

      final userId = group.userId;
      final persistence = di.sl.get<SelectedControllerPersistence>();

      // Step 2: Check if controllers already loaded
      if (currentState.groupControllers.containsKey(event.groupId)) {
        final controllers = currentState.groupControllers[event.groupId]!;

        if (controllers.isNotEmpty) {
          mqttBloc.add(SubscribeMqttEvent(controllers[0].deviceId));
          await persistence.save(controllers[0].deviceId, event.groupId);
        }

        emit(newState.copyWith(
          selectedControllerIndex: controllers.isNotEmpty ? 0 : null,
        ));
        return;
      }

      emit(DashboardLoading());

      final result = await fetchControllers(UserGroupParams(userId, event.groupId));

      await result.fold(
            (failure) async {
          emit(DashboardError(message: failure.message));
        },
            (controllers) async {
          final updatedControllers = Map<int, List<ControllerEntity>>.from(currentState.groupControllers);
          updatedControllers[event.groupId] = controllers;

          if (controllers.isNotEmpty) {
            mqttBloc.add(SubscribeMqttEvent(controllers[0].deviceId));
            await persistence.save(controllers[0].deviceId, event.groupId);
          }

          emit(DashboardGroupsLoaded(
            groups: currentState.groups,
            groupControllers: updatedControllers,
            selectedGroupId: event.groupId,
            selectedControllerIndex: controllers.isNotEmpty ? 0 : null,
          ));
        },
      );
    });

    on<SelectControllerEvent>((event, emit) async {
      if (state is! DashboardGroupsLoaded) return;

      final currentState = state as DashboardGroupsLoaded;
      final groupId = currentState.selectedGroupId;
      if (groupId == null) return;

      final controllers = currentState.groupControllers[groupId] ?? [];
      if (event.controllerIndex >= controllers.length) return;

      final selectedController = controllers[event.controllerIndex];

      // Subscribe to MQTT
      mqttBloc.add(SubscribeMqttEvent(selectedController.deviceId));

      // Persist selection
      final persistence = di.sl.get<SelectedControllerPersistence>();
      await persistence.save(selectedController.deviceId, groupId);

      // Update state
      emit(currentState.copyWith(selectedControllerIndex: event.controllerIndex));
    });

    on<ResetDashboardSelectionEvent>((event, emit) async {
      if (state is DashboardGroupsLoaded) {
        final currentState = state as DashboardGroupsLoaded;
        emit(currentState.copyWith(
          selectedGroupId: null,
          selectedControllerIndex: null,
        ));
        _stopPolling();
      }
    });

    on<UpdateLiveMessageEvent>(_onUpdateLiveMessage);

    on<StartPollingEvent>(_onStartPolling);
    on<StopPollingEvent>(_onStopPolling);
  }

  void _onStartPolling(StartPollingEvent event, Emitter<DashboardState> emit) {
    if (_isPollingActive) {
      debugPrint('Polling already active - skipping start');
      return;
    }
    _stopPolling(); // Clean any partial
    _isPollingActive = true;
    _lastPollTime = DateTime.now();

    // Immediate first poll
    _performPoll();

    _pollTimer = Timer.periodic(const Duration(seconds: 40), (timer) {
      _performPoll();
    });
  }

  void _onStopPolling(StopPollingEvent event, Emitter<DashboardState> emit) {
    _stopPolling();
  }

  void _performPoll() {
    if (_lastPollTime != null && DateTime.now().difference(_lastPollTime!).inMilliseconds < 10000) {
      final seconds = DateTime.now().difference(_lastPollTime!).inSeconds;
      debugPrint('Poll throttled: too soon since last (${seconds}s)');
      return;
    }

    if (state is DashboardGroupsLoaded) {
      final currentState = state as DashboardGroupsLoaded;
      if (currentState.selectedControllerIndex != null && currentState.selectedGroupId != null) {
        final controllers = currentState.groupControllers[currentState.selectedGroupId!] ?? [];
        final selectedIndex = currentState.selectedControllerIndex!;
        if (selectedIndex < controllers.length) {
          final deviceId = controllers[selectedIndex].deviceId;
          if (mqttBloc.state is MqttConnected || mqttBloc.state is MqttMessagesState) {
            final publishMessage = jsonEncode(PublishMessageHelper.requestLive);
            mqttBloc.add(PublishMqttEvent(deviceId: deviceId, message: publishMessage));
            _lastPollTime = DateTime.now();
            debugPrint('Bloc polled live for $deviceId at $_lastPollTime');
          } else {
            debugPrint('Poll skipped: MQTT not ready (${mqttBloc.state.runtimeType})');
          }
        }
      }
    }
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _isPollingActive = false;
    _lastPollTime = null;
  }

  Future<void> _onUpdateLiveMessage(UpdateLiveMessageEvent event, Emitter<DashboardState> emit) async {
    if (state is! DashboardGroupsLoaded) return;

    final currentState = state as DashboardGroupsLoaded;
    final updatedGroupControllers = Map<int, List<ControllerEntity>>.from(currentState.groupControllers);
    bool updated = false;

    // Iterate over all groups' controllers to find the matching deviceId
    for (final entry in updatedGroupControllers.entries) {
      final groupId = entry.key;
      final controllers = entry.value;
      final updatedControllersList = <ControllerEntity>[]; // Renamed for clarity
      bool groupUpdated = false;

      for (final ctrl in controllers) {
        if (ctrl.deviceId == event.deviceId) {
          // Cast to ControllerModel assuming it implements ControllerEntity and has copyWith
          final model = ctrl as ControllerModel;
          final updatedCtrl = model.copyWith(liveMessage: event.liveMessage);
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

  @override
  Future<void> close() {
    _stopPolling();
    return super.close();
  }
}