import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/dealer_customer_entity.dart';

abstract class DealerDashboardRepository {
  Future<Either<Failure, List<DealerCustomerEntity>>> getDealerCustomerDetails(String userId);
  Future<Either<Failure, List<DealerCustomerEntity>>> getSelectedCustomerDetails(String userId);
}
