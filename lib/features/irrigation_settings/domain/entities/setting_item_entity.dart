import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/presentation/enums/irrigation_settings_enum.dart';

class SettingItemEntity {
  final String name;
  final String image;
  final IrrigationSettingsEnum irrigationSettingsEnum;

  SettingItemEntity({
    required this.name,
    required this.image,
    required this.irrigationSettingsEnum,
  });
}
