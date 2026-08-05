import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class LocationRepository {
  Future<Either<Failure, Map<String, dynamic>>> updateLatLong({
    required int userId,
    required int controllerId,
    required String latLong,
  });
}
