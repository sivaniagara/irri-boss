import 'package:equatable/equatable.dart';

import '../../domain/entities/notifications_entity.dart';

class NotificationsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetNotificationsInitial extends NotificationsState {}

class GetNotificationsLoaded extends NotificationsState {
  final List<NotificationsEntity> notifications;
  GetNotificationsLoaded({required this.notifications});

  @override List<Object?> get props => [notifications];
}

class GetNotificationsFailure extends NotificationsState {
  final String message;
  GetNotificationsFailure({required this.message});

  @override
  List<Object> get props => [message];
}

class UpdateNotificationsLoading extends NotificationsState {}

class UpdateNotificationsSuccess extends NotificationsState {
  final String message;
  UpdateNotificationsSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class UpdateNotificationsFailure extends NotificationsState {
  final String message;
  UpdateNotificationsFailure({required this.message});

  @override
  List<Object> get props => [message];
}