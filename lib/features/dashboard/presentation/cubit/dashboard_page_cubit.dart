import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/mqtt/mqtt_manager.dart';
import '../../../../core/services/mqtt/publish_messages.dart';
import '../../../../core/services/selected_controller_persistence.dart';
import '../../dashboard.dart';

class DashboardPageCubit extends Cubit<DashboardState> {
  final FetchDashboardGroups fetchDashboardGroups;
  final FetchControllers fetchControllers;

  DashboardPageCubit({
    required this.fetchDashboardGroups,
    required this.fetchControllers,
  }) : super(DashboardInitial());

  Future<void> getGroups(int userId, GoRouterState routeState) async {
    emit(DashboardLoading());
    final result = await fetchDashboardGroups(DashboardGroupsParams(userId, routeState));

    result.fold(
          (failure) => emit(DashboardError(message: failure.message)),
          (groups) {
        emit(DashboardGroupsLoaded(groups: groups, groupControllers: {}));

        if (groups.isNotEmpty) {
          fetchControllersForGroup(userId, groups[0].userGroupId);
        }
      },
    );
  }

  Future<void> fetchControllersForGroup(int userId, int groupId) async {
    if (state is DashboardGroupsLoaded) {
      final currentState = state as DashboardGroupsLoaded;
      final result = await fetchControllers(UserGroupParams(userId, groupId));

      final updatedControllers = Map<int, List<ControllerEntity>>.from(currentState.groupControllers);
      result.fold(
            (failure) => emit(DashboardError(message: failure.message)),
            (controllers) {
          updatedControllers[groupId] = controllers;
          if (controllers.isNotEmpty) {
            sl<MqttManager>().subscribe(controllers[0].deviceId);
            sl<MqttManager>().publish(controllers[0].deviceId, jsonEncode(PublishMessageHelper.requestLive));
          }
          emit(DashboardGroupsLoaded(
            groups: currentState.groups,
            groupControllers: updatedControllers,
          ));
        },
      );
    }
  }

  Future<void> selectGroup(int groupId, int userId) async {
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

    final result = await fetchControllers(UserGroupParams(userId, groupId));

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

    final persistence = sl.get<SelectedControllerPersistence>();
    await persistence.save(selectedController.deviceId, groupId);

    emit(currentState.copyWith(selectedControllerIndex: controllerIndex));
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
        if (ctrl.deviceId == deviceId) {
          final model = ctrl as ControllerModel;
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
}