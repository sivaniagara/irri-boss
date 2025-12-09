import 'package:equatable/equatable.dart';
import '../../domain/dashboard_domain.dart';

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