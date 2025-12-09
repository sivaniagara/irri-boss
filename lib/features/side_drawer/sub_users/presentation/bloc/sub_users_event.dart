import 'package:equatable/equatable.dart';
import '../../domain/sub_users_domain.dart';

abstract class SubUsersEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetSubUsersEvent extends SubUsersEvent {
  final int userId;
  GetSubUsersEvent({required this.userId});

  @override
  List<Object?> get props => [];
}

class GetSubUserDetailsEvent extends SubUsersEvent {
  final GetSubUserDetailsParams subUserDetailsParams;
  GetSubUserDetailsEvent({required this.subUserDetailsParams});

  @override
  List<Object?> get props => [];
}

class UpdateControllerSelectionEvent extends SubUsersEvent {
  final int controllerIndex;
  final bool isSelected;

  UpdateControllerSelectionEvent({
    required this.controllerIndex,
    required this.isSelected,
  });

  @override
  List<Object?> get props => [controllerIndex, isSelected];
}

class UpdateControllerDndEvent extends SubUsersEvent {
  final int controllerIndex;
  final bool isEnabled;

  UpdateControllerDndEvent({
    required this.controllerIndex,
    required this.isEnabled,
  });

  @override
  List<Object?> get props => [controllerIndex, isEnabled];
}

class SubUserDetailsUpdateEvent extends SubUsersEvent {
  final UpdateSubUserDetailsParams updatedDetails;

  SubUserDetailsUpdateEvent({required this.updatedDetails});

  @override
  List<Object?> get props => [];
}

class GetSubUserByPhoneEvent extends SubUsersEvent {
  final GetSubUserByPhoneParams getSubUserByPhoneParams;

  GetSubUserByPhoneEvent({required this.getSubUserByPhoneParams});

  @override
  List<Object?> get props => [];
}