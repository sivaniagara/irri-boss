



abstract class GreenHouseRepository {
  Future<dynamic> getMoistureData({
    required int userId,
    required int subUserId,
    required int controllerId,
    required String fromDate,
    required String toDate,
   });
}


