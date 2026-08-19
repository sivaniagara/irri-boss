import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class LocationRepository {
  Future<Either<Failure, bool>> updateLatLong({
    required int userId,
    required int controllerId,
    required String latLong,
  });
}
