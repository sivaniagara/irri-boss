import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/mqtt/mqtt_manager.dart';
import '../../../../core/services/mqtt/publish_messages.dart';
import '../../../../core/services/selected_controller_persistence.dart';
import '../../dashboard.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final FetchDashboardGroups fetchDashboardGroups;
  final FetchControllers fetchControllers;
  Timer? _pollTimer;

  DashboardBloc({
    required this.fetchDashboardGroups,
    required this.fetchControllers,
  }) : super(DashboardInitial()) {
    on<FetchDashboardGroupsEvent>((event, emit) async {
      emit(DashboardLoading());
      final result = await fetchDashboardGroups(DashboardGroupsParams(event.userId, event.routeState));

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
              sl<MqttManager>().subscribe(controllers[0].deviceId);
              sl<MqttManager>().publish(controllers[0].deviceId, jsonEncode(PublishMessageHelper.requestLive));
              // sl<MqttManager>.add(SubscribeMqttEvent(controllers[0].deviceId));
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
            sl<MqttManager>().subscribe(controllers[0].deviceId);
            sl<MqttManager>().publish(controllers[0].deviceId, jsonEncode(PublishMessageHelper.requestLive));
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
      sl<MqttManager>().subscribe(selectedController.deviceId);
      sl<MqttManager>().publish(selectedController.deviceId, jsonEncode(PublishMessageHelper.requestLive));

      // Persist selection
      final persistence = sl.get<SelectedControllerPersistence>();
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
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _onUpdateLiveMessage(UpdateLiveMessageEvent event, Emitter<DashboardState> emit) async {
    if (state is! DashboardGroupsLoaded) return;

    final currentState = state as DashboardGroupsLoaded;
    final updatedGroupControllers = Map<int, List<ControllerEntity>>.from(currentState.groupControllers);
    bool updated = false;

    for (final entry in updatedGroupControllers.entries) {
      final groupId = entry.key;
      final controllers = entry.value;
      final updatedControllersList = <ControllerEntity>[];
      bool groupUpdated = false;

      for (final ctrl in controllers) {
        if (ctrl.deviceId == event.deviceId) {
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