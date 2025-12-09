import 'package:equatable/equatable.dart';

import '../../domain/sub_users_domain.dart';

abstract class SubUsersState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SubUserLoading extends SubUsersState {}

class SubUserInitial extends SubUsersState {}

class SubUsersLoaded extends SubUsersState {
  final List<SubUserEntity> subUsersList;
  SubUsersLoaded({required this.subUsersList});

  @override
  List<Object?> get props => [subUsersList];
}

class SubUsersError extends SubUsersState {
  final String message;
  SubUsersError({required this.message});

  @override
  List<Object?> get props => [message];
}

class SubUserDetailsLoading extends SubUsersState {}

class SubUserDetailsLoaded extends SubUsersState {
  final SubUserDetailsEntity subUserDetails;
  SubUserDetailsLoaded({required this.subUserDetails});

  @override
  List<Object?> get props => [subUserDetails];
}

class SubUserDetailsError extends SubUsersState {
  final String message;
  SubUserDetailsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class SubUserDetailsUpdateStarted extends SubUsersState {}

class SubUserDetailsUpdateSuccess extends SubUsersState {
  final String message;
  SubUserDetailsUpdateSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class SubUserDetailsUpdateError extends SubUsersState {
  final String message;
  SubUserDetailsUpdateError({required this.message});

  @override
  List<Object?> get props => [message];
}

class GetSubUserByPhoneStarted extends SubUsersState {}

class GetSubUserByPhoneSuccess extends SubUsersState {
  final dynamic userData;
  GetSubUserByPhoneSuccess({required this.userData});

  @override
  List<Object?> get props => [userData];
}

class GetSubUserByPhoneError extends SubUsersState {
  final String message;
  final SubUserDetailsEntity subUserDetails;

  GetSubUserByPhoneError({
    required this.message,
    required this.subUserDetails,
  });

  @override
  List<Object?> get props => [message, subUserDetails];
}

class DeleteSubUserStarted extends SubUsersState {}

class DeleteSubUserSuccess extends SubUsersState {
  final String message;
  DeleteSubUserSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class DeleteSubUserError extends SubUsersState {
  final String message;
  DeleteSubUserError({required this.message});

  @override
  List<Object?> get props => [message];
}