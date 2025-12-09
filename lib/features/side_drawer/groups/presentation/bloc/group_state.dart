import 'package:equatable/equatable.dart';

import '../../domain/entities/group_entity.dart';

abstract class GroupState extends Equatable {
  @override
  List<Object?> get props => [];
}

class GroupInitial extends GroupState {}
class GroupLoading extends GroupState {}

class GroupLoaded extends GroupState {
  final List<GroupEntity> groups;

  GroupLoaded({required this.groups});

  @override
  List<Object?> get props => [groups];
}

class GroupFetchingError extends GroupState {
  final String message;
  GroupFetchingError({required this.message});

  @override
  List<Object?> get props => [message];
}

class GroupAddingStarted extends GroupState {}

class GroupAddingLoaded extends GroupState {
  final String message;

  GroupAddingLoaded({required this.message});
  @override
  List<Object?> get props => [message];
}

class GroupAddingError extends GroupState {
  final String message;

  GroupAddingError({required this.message});
  @override
  List<Object?> get props => [message];
}

class EditGroupInitial extends GroupState {}

class EditGroupSuccess extends GroupState {
  final String message;

  EditGroupSuccess({required this.message});
  @override
  List<Object?> get props => [message];
}

class EditGroupError extends GroupState {
  final String message;
  EditGroupError({required this.message});

  @override
  List<Object?> get props => [message];
}

class GroupDeletingStarted extends GroupState {}

class GroupDeleteSuccess extends GroupState {
  final String message;

  GroupDeleteSuccess({required this.message});
  @override
  List<Object?> get props => [message];
}

class GroupDeleteError extends GroupState {
  final String message;

  GroupDeleteError({required this.message});
  @override
  List<Object?> get props => [message];
}