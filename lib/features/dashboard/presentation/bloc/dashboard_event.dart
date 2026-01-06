import 'package:equatable/equatable.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/livemessage_entity.dart';

abstract class DashboardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchDashboardGroupsEvent extends DashboardEvent {
  final int userId;
  final GoRouterState routeState;
  FetchDashboardGroupsEvent(this.userId, this.routeState);

  @override
  List<Object?> get props => [userId];
}

class FetchControllersEvent extends DashboardEvent {
  final int userId;
  final int groupId;
  FetchControllersEvent(this.userId, this.groupId);

  @override
  List<Object?> get props => [userId, groupId];
}

class SelectGroupEvent extends DashboardEvent {
  final int groupId;
  SelectGroupEvent(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class SelectControllerEvent extends DashboardEvent {
  final int controllerIndex;
  SelectControllerEvent(this.controllerIndex);

  @override
  List<Object?> get props => [controllerIndex];
}

class ResetDashboardSelectionEvent extends DashboardEvent {
  @override List<Object?> get props => [];
}

class UpdateLiveMessageEvent extends DashboardEvent {
  final String deviceId;
  final LiveMessageEntity liveMessage;

  UpdateLiveMessageEvent(this.deviceId, this.liveMessage);
}

class StartPollingEvent extends DashboardEvent {}

class StopPollingEvent extends DashboardEvent {}