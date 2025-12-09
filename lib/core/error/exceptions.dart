class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException({this.message = "Server Exception", this.statusCode});

  @override
  String toString() => "$message (code: $statusCode)";
}

class AuthException implements Exception {
  final String message;
  final String? statusCode;

  AuthException({this.message = "Server Exception", this.statusCode});

  @override
  String toString() => "$message (code: $statusCode)";
}

/// Thrown when there is an error with cached/local data.
class CacheException implements Exception {
  final String message;

  CacheException([this.message = "Cache Exception"]);

  @override
  String toString() => message;
}

/// Thrown when request is cancelled or times out.
class TimeoutException implements Exception {
  final String message;

  TimeoutException([this.message = "Request Timeout"]);

  @override
  String toString() => message;
}

/// Thrown when there is an error related to MQTT communication.
class MqttException implements Exception {
  final String message;
  final int? code;

  MqttException({this.message = "MQTT Exception", this.code});

  @override
  String toString() => "$message (code: $code)";
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException({this.message = "Unauthorized"});
  @override
  String toString() => message;
}

class UnexpectedException implements Exception {
  final String message;
  UnexpectedException(this.message);
  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  NetworkException({required this.message});
  @override
  String toString() => message;
}

class NotFoundException implements Exception {
  final String message;
  final int code;
  NotFoundException({required this.message, required this.code});
  @override
  String toString() => "$message (code: $code)";
}

class ValidationException implements Exception {
  final String message;
  final int code;
  ValidationException({required this.message, required this.code});
  @override
  String toString() => "$message (code: $code)";
}


