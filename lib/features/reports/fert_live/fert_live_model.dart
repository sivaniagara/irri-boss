class LiveFertilizerState {
  final bool motorOn;
  final String rtc;
  final String vrb;
  final String amp;
  final String preWater;
  final String postWater;
  final String programName;
  final String modeType;
  final String ph;
  final String ec;
  final String pressure;
  final List<FertilizerStatus> fertilizers;

  const LiveFertilizerState({
    required this.motorOn,
    required this.rtc,
    required this.vrb,
    required this.amp,
    required this.preWater,
    required this.postWater,
    required this.programName,
    required this.modeType,
    required this.ph,
    required this.ec,
    required this.pressure,
    required this.fertilizers,
  });
}

class FertilizerStatus {
  final int index;
  final bool isOn;
  final double rate;
  final String ventureOnTime;
  final String ventureOffTime;
  final String rtcOn;
  final String rtcOff;

  const FertilizerStatus({
    required this.index,
    required this.isOn,
    required this.rate,
    required this.ventureOnTime,
    required this.ventureOffTime,
    required this.rtcOn,
    required this.rtcOff,
  });
}

extension SafeList<T> on List<T> {
  T? safe(int index) => (index >= 0 && index < length) ? this[index] : null;
}
