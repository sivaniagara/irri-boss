class ZoneWaterFertilizerEntity{
  final String zoneNumber;
  String time;
  String liters;
  String ch1Time;
  String ch2Time;
  String ch3Time;
  String ch4Time;
  String ch5Time;
  String ch6Time;
  String ch1Liters;
  String ch2Liters;
  String ch3Liters;
  String ch4Liters;
  String ch5Liters;
  String ch6Liters;
  String preTime;
  String preLiters;
  String postTime;
  String postLiters;

  ZoneWaterFertilizerEntity({
    required this.zoneNumber,
    required this.time,
    required this.liters,
    required this.ch1Time,
    required this.ch2Time,
    required this.ch3Time,
    required this.ch4Time,
    required this.ch5Time,
    required this.ch6Time,
    required this.ch1Liters,
    required this.ch2Liters,
    required this.ch3Liters,
    required this.ch4Liters,
    required this.ch5Liters,
    required this.ch6Liters,
    required this.preTime,
    required this.preLiters,
    required this.postTime,
    required this.postLiters,
  });

  ZoneWaterFertilizerEntity copyWith({
    String? updatedTime,
    String? updatedLiters,
    String? updatedCh1Time,
    String? updatedCh2Time,
    String? updatedCh3Time,
    String? updatedCh4Time,
    String? updatedCh5Time,
    String? updatedCh6Time,
    String? updatedCh1Liters,
    String? updatedCh2Liters,
    String? updatedCh3Liters,
    String? updatedCh4Liters,
    String? updatedCh5Liters,
    String? updatedCh6Liters,
    String? updatedPreTime,
    String? updatedPreLiters,
    String? updatedPostTime,
    String? updatedPostLiters,
  }){
    print('updatedCh1Liters : ${updatedCh1Liters}');
    return ZoneWaterFertilizerEntity(
        zoneNumber: zoneNumber,
        time: updatedTime ?? time,
        liters: updatedLiters ?? liters,
        ch1Time: updatedCh1Time ?? ch1Time,
        ch2Time: updatedCh2Time ?? ch2Time,
        ch3Time: updatedCh3Time ?? ch3Time,
        ch4Time: updatedCh4Time ?? ch4Time,
        ch5Time: updatedCh5Time ?? ch5Time,
        ch6Time: updatedCh6Time ?? ch6Time,
        ch1Liters: updatedCh1Liters ?? ch1Liters,
        ch2Liters: updatedCh2Liters ?? ch2Liters,
        ch3Liters: updatedCh3Liters ?? ch3Liters,
        ch4Liters: updatedCh4Liters ?? ch4Liters,
        ch5Liters: updatedCh5Liters ?? ch5Liters,
        ch6Liters: updatedCh6Liters ?? ch6Liters,
        preTime: updatedPreTime ?? preTime,
        preLiters: updatedPreLiters ?? preLiters,
        postTime: updatedPostTime ?? postTime,
        postLiters: updatedPostLiters ?? postLiters
    );
  }
}