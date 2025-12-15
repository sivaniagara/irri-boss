import '../../domain/entities/sendrev_entities.dart';

abstract class SendrevState {}

class SendrevInitial extends SendrevState {}

class SendrevLoading extends SendrevState {}

class SendrevLoaded extends SendrevState {
  final List<SendrevDatumEntity> messages;

  SendrevLoaded(this.messages);
}

class SendrevError extends SendrevState {
  final String message;

  SendrevError(this.message);
}
