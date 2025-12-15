import '../entities/sendrev_entities.dart';


abstract class SendrevRepository {
  Future<SendrevEntity> getMessages({
    required int userId,
    required int subuserId,
    required int controllerId,
    required String fromDate,
    required String toDate,
  });
}