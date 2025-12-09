import 'package:dartz/dartz.dart';

import 'exceptions.dart';
import 'failures.dart';

abstract class BaseRepository {
  // Generic wrapper: Calls a data source method and maps exceptions to Failures
  Future<Either<Failure, T>> safeCall<T>(
      Future<T> Function() dataSourceCall, {
        String? context,  // Optional: For logging, e.g., "Fetching sub-users"
      }) async {
    try {
      final result = await dataSourceCall();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(e.message));
    } on NotFoundException catch (e) {  // Assuming you add this exception
      return Left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      // Catch-all: Log if you have a logger, then map
      // e.g., logger.e('Unexpected error in $context: $e');
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  // Overload for dynamic returns (e.g., your getSubUserByPhone)
  Future<Either<Failure, dynamic>> safeCallDynamic(Future<dynamic> Function() dataSourceCall, {String? context}) async {
    return await safeCall(dataSourceCall, context: context);
  }
}