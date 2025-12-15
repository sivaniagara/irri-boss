import 'package:dartz/dartz.dart';

import '../../../../../core/error/failures.dart';

 import '../../data/repositories/setserial_details_repositories.dart';

class LoadSerialUsecase {
  final SetSerialRepository repository;

  LoadSerialUsecase(this.repository);

  Future<List> call({
    required int userId,
    required int controllerId,
  }) async {
    return await repository.loadSerial(
      userId: userId,
      controllerId: controllerId,
    );
  }
}

