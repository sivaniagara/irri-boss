import '../entities/faultmsg_entities.dart';


abstract class faultmsgRepository {
  Future<faultmsgEntity> getMessages({
    required int userId,
    required int subuserId,
    required int controllerId,
   });
}