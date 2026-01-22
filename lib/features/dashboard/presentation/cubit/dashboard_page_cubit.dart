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

  DashboardGroupsLoaded({
    required this.groups,
    this.groupControllers = const {},
    this.selectedGroupId,
    this.selectedControllerIndex,
  });

  @override
  List<Object?> get props => [groups, groupControllers, selectedGroupId, selectedControllerIndex];

  DashboardGroupsLoaded copyWith({
    List<GroupDetailsEntity>? groups,
    Map<int, List<ControllerEntity>>? groupControllers,
    int? selectedGroupId,
    int? selectedControllerIndex,
  }) {
    return DashboardGroupsLoaded(
      groups: groups ?? this.groups,
      groupControllers: groupControllers ?? this.groupControllers,
      selectedGroupId: selectedGroupId ?? this.selectedGroupId,
      selectedControllerIndex: selectedControllerIndex ?? this.selectedControllerIndex,
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

  DashboardPageCubit({
    required this.fetchDashboardGroups,
    required this.fetchControllers,
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

    sl.get<MqttService>().updates.listen((message) {
      liveMessage = message;
    });

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