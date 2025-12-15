import '../entities/faultmsg_entities.dart';
import '../repositories/faultmsg_repo.dart';



class FetchfaultmsgMessages {
  final faultmsgRepository repository;

  FetchfaultmsgMessages(this.repository);

  Future<faultmsgEntity> call({
    required int userId,
    required int subuserId,
    required int controllerId,
   }) async {
    return await repository.getMessages(
      userId: userId,
      subuserId: subuserId,
      controllerId: controllerId,
     );
  }
}
