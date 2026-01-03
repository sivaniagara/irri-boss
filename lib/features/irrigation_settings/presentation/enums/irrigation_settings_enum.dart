enum IrrigationSettingsEnum{
  irrigationFertigation,
  dripCommonSettings,
  programCommonSettings,
  adjustPercentage,
  changeFrom,
  backwash,
  pumpChangeOver,
  sump,
  moistureAndLevel,
  pumpConfiguration,
  valveFlow,
  dayCountRtc,
  alarm,
  ecAndPh,
  greenHouse,
}

extension IrrigationSettingsEnumExtension on IrrigationSettingsEnum{
  int get settingId {
    switch(this){
      case IrrigationSettingsEnum.irrigationFertigation: return 517;
      case IrrigationSettingsEnum.dripCommonSettings: return 517;
      case IrrigationSettingsEnum.programCommonSettings: return 518;
      case IrrigationSettingsEnum.adjustPercentage: return 519;
      case IrrigationSettingsEnum.changeFrom: return 520;
      case IrrigationSettingsEnum.backwash: return 521;
      case IrrigationSettingsEnum.pumpChangeOver: return 522;
      case IrrigationSettingsEnum.sump: return 523;
      case IrrigationSettingsEnum.moistureAndLevel: return 524;
      case IrrigationSettingsEnum.pumpConfiguration: return 525;
      case IrrigationSettingsEnum.valveFlow: return 526;
      case IrrigationSettingsEnum.dayCountRtc: return 527;
      case IrrigationSettingsEnum.alarm: return 528;
      case IrrigationSettingsEnum.ecAndPh: return 529;
      case IrrigationSettingsEnum.greenHouse: return 530;

    }
  }
}

