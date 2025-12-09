import 'package:dartz/dartz.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../error/failures.dart';

enum ApiCode {
  success(200, 'Success'),
  created(201, 'Created/Empty (e.g., no data)'),
  badRequest(400, 'Bad Request'),
  unauthorized(401, 'Unauthorized'),
  forbidden(403, 'Forbidden'),
  notFound(404, 'Not Found'),
  conflict(409, 'Conflict'),
  internalError(500, 'Internal Server Error'),
  unknown(999, 'Unknown Error');

  const ApiCode(this.code, this.message);
  final int code;
  final String message;

  static ApiCode fromInt(int code) {
    return ApiCode.values.firstWhere(
          (e) => e.code == code,
      orElse: () => ApiCode.unknown,
    );
  }
}

Either<Failure, T> handleApiResponse<T>(
    Map<String, dynamic> response, {
      required T Function(dynamic data) parser,
      List<int> successCodes = const [200, 201],
      bool returnEmptyOn201 = true,
    }) {
  try {
    final code = response['code'] as int?;
    final message = response['message'] as String? ?? 'Unknown error';
    final data = response['data'];

    if (code == null) {
      return Left(ServerFailure('Invalid response: No code provided'));
    }

    final apiCode = ApiCode.fromInt(code);

    if (successCodes.contains(code)) {
      if (returnEmptyOn201 && code == 201 && data == null) {
        return Right(parser(null));
      }
      if (data == null) {
        return Right(null as T);
      }
      final parsed = parser(data);
      return Right(parsed);
    } else {
      return switch (apiCode) {
        ApiCode.unauthorized => Left(AuthFailure(message)),
        ApiCode.forbidden => Left(AuthFailure(message)),
        ApiCode.notFound => Left(NotFoundFailure(message)),
        ApiCode.badRequest => Left(ValidationFailure(message)),
        ApiCode.conflict => Left(ConflictFailure(message)),
        ApiCode.internalError => Left(ServerFailure(message)),
        _ => Left(ServerFailure('$message (code: $code)')),
      };
    }
  } catch (e) {
    return Left(ServerFailure('Response parsing error: $e'));
  }
}

Either<Failure, List<E>> handleListResponse<E>(
    Map<String, dynamic> response, {
      required E Function(Map<String, dynamic> json) fromJson,
      List<int> successCodes = const [200, 201],
    }) {
  return handleApiResponse<List<E>>(
    response,
    parser: (dynamic rawData) {
      if (rawData == null || (rawData is List && rawData.isEmpty)) {
        return <E>[];
      }

      final dataList = rawData as List<dynamic>;
      return List<E>.from(
          dataList.map<E>((item) => fromJson(item as Map<String, dynamic>))
      );
    },
    successCodes: successCodes,
  );
}