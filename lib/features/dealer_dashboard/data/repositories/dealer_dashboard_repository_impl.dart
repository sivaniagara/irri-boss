import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/dealer_customer_entity.dart';
import '../../domain/repositories/dealer_dashboard_repository.dart';
import '../datasources/dealer_dashboard_remote_data_source.dart';

class DealerDashboardRepositoryImpl implements DealerDashboardRepository {
  final DealerDashboardRemoteDataSource remoteDataSource;

  DealerDashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<DealerCustomerEntity>>> getDealerCustomerDetails(String userId) async {
    try {
      final remoteData = await remoteDataSource.getDealerCustomerDetails(userId);
      return Right(remoteData);
    } on Exception {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<DealerCustomerEntity>>> getSelectedCustomerDetails(String userId) async{
    try {
      final remoteData = await remoteDataSource.getSelectedCustomerDetails(userId);
      return Right(remoteData);
    } on Exception {
      return Left(ServerFailure());
    }
  }
}
