import 'package:equatable/equatable.dart';

/// Failures are returned to the domain layer instead of throwing exceptions.
/// They are higher-level, safe to expose to UI or usecases.
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message];
}

/// Represents general server/API failures
class ServerFailure extends Failure {
  const ServerFailure([super.message = "Server Failure"]);
}

/// Represents failures when reading/writing cache/local storage
class CacheFailure extends Failure {
  const CacheFailure([super.message = "Cache Failure"]);
}

/// Represents failures when device has no internet
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = "No Internet Connection"]);
}

/// Represents request timeout or cancellation
class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = "Request Timeout"]);
}

/// Represents MQTT connection/publish/subscribe issues
class MqttFailure extends Failure {
  const MqttFailure([super.message = "MQTT Failure"]);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = "Unexpected Failure"]);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class ConflictFailure extends Failure {
  const ConflictFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}
