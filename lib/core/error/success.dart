import 'package:equatable/equatable.dart';

abstract class Success extends Equatable {
  final String message;
  final String? code;
  const Success(this.message, {this.code});

  @override
  List<Object?> get props => [message];
}

class ZoneCreatedSuccess extends Success{
  const ZoneCreatedSuccess([super.message = 'Zone created SuccessFully.']);
}

class ZoneNotCreatedSuccess extends Success{
  const ZoneNotCreatedSuccess([super.message = 'Zone created failed.']);
}

class ZoneDeleteSuccess extends Success{
  const ZoneDeleteSuccess([super.message = 'Zone deleted successfully.']);
}
