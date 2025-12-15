import '../../domain/entities/faultmsg_entities.dart';

abstract class faultmsgState {}

class faultmsgInitial extends faultmsgState {}

class faultmsgLoading extends faultmsgState {}

class faultmsgLoaded extends faultmsgState {
  final List<faultmsgDatumEntity> messages;

  faultmsgLoaded(this.messages);
}

class faultmsgError extends faultmsgState {
  final String message;

  faultmsgError(this.message);
}
