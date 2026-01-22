import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/dealer_customer_entity.dart';
import '../repositories/dealer_dashboard_repository.dart';

class GetSelectedCustomerDetails implements UseCase<List<DealerCustomerEntity>, String> {
  final DealerDashboardRepository repository;

  GetSelectedCustomerDetails(this.repository);

  @override
  Future<Either<Failure, List<DealerCustomerEntity>>> call(String params) async {
    return await repository.getSelectedCustomerDetails(params);
  }
}