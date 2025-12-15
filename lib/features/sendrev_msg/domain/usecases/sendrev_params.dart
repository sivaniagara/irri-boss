import '../entities/sendrev_entities.dart';
import '../repositories/sendrev_repo.dart';



class FetchSendRevMessages {
  final SendrevRepository repository;

  FetchSendRevMessages(this.repository);

  Future<SendrevEntity> call({
    required int userId,
    required int subuserId,
    required int controllerId,
    required String fromDate,
    required String toDate,
  }) async {
    return await repository.getMessages(
      userId: userId,
      subuserId: subuserId,
      controllerId: controllerId,
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}
