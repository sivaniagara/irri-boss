import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_app_bar.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_list_tile.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/gradiant_background.dart';
import 'package:niagara_smart_drip_irrigation/features/edit_program/presentation/widgets/custom_card.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/presentation/enums/irrigation_settings_enum.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/presentation/enums/irrigation_settings_enum.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/presentation/enums/irrigation_settings_enum.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/presentation/enums/irrigation_settings_enum.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/presentation/enums/irrigation_settings_enum.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/presentation/enums/irrigation_settings_enum.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/presentation/enums/irrigation_settings_enum.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/presentation/enums/irrigation_settings_enum.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/presentation/enums/irrigation_settings_enum.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/presentation/enums/irrigation_settings_enum.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/presentation/enums/irrigation_settings_enum.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/presentation/enums/irrigation_settings_enum.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/presentation/enums/irrigation_settings_enum.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/presentation/enums/irrigation_settings_enum.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/presentation/enums/irrigation_settings_enum.dart';

import '../../../dashboard/utils/dashboard_routes.dart';
import '../../../water_fertilizer_settings/utils/water_fertilizer_settings_routes.dart';
import '../../domain/entities/setting_item_entity.dart';
import '../../utils/irrigation_settings_routes.dart';
import '../widgets/setting_card.dart';

class IrrigationSettingsPage extends StatelessWidget {
  IrrigationSettingsPage({super.key});

  final settings = [
    SettingItemEntity(name: 'Irrigation & Fertigation', image: 'assets/images/common/irrigation_fertigation.png', irrigationSettingsEnum: IrrigationSettingsEnum.irrigationFertigation),
    SettingItemEntity(name: 'Drip Common Settings', image: 'assets/images/common/drip_common_setting.png', irrigationSettingsEnum: IrrigationSettingsEnum.dripCommonSettings),
    SettingItemEntity(name: 'Program Common Settings', image: 'assets/images/common/program_common_setting.png', irrigationSettingsEnum: IrrigationSettingsEnum.programCommonSettings),
    SettingItemEntity(name: 'Adjust %', image: 'assets/images/common/adjust_percentage.png', irrigationSettingsEnum: IrrigationSettingsEnum.adjustPercentage),
    SettingItemEntity(name: 'Change From', image: 'assets/images/common/change_from.png', irrigationSettingsEnum: IrrigationSettingsEnum.changeFrom),
    SettingItemEntity(name: 'Backwash', image: 'assets/images/common/backwash.png', irrigationSettingsEnum: IrrigationSettingsEnum.backwash),
    SettingItemEntity(name: 'Pump Change Over', image: 'assets/images/common/pump_change_over.png', irrigationSettingsEnum: IrrigationSettingsEnum.pumpChangeOver),
    SettingItemEntity(name: 'Sump', image: 'assets/images/common/sump_setting.png', irrigationSettingsEnum: IrrigationSettingsEnum.sump),
    SettingItemEntity(name: 'Moisture & Level', image: 'assets/images/common/moisture_level.png', irrigationSettingsEnum: IrrigationSettingsEnum.moistureAndLevel),
    SettingItemEntity(name: 'Pump Configuration', image: 'assets/images/common/pump_configuration.png', irrigationSettingsEnum: IrrigationSettingsEnum.pumpConfiguration),
    SettingItemEntity(name: 'Valve Flow', image: 'assets/images/common/valve_flow.png', irrigationSettingsEnum: IrrigationSettingsEnum.valveFlow),
    SettingItemEntity(name: 'Day Count RTC', image: 'assets/images/common/day_count_rtc.png', irrigationSettingsEnum: IrrigationSettingsEnum.dayCountRtc),
    SettingItemEntity(name: 'Alarm', image: 'assets/images/common/alarm.png', irrigationSettingsEnum: IrrigationSettingsEnum.alarm),
    SettingItemEntity(name: 'Ec & Ph', image: 'assets/images/common/ec_ph.png', irrigationSettingsEnum: IrrigationSettingsEnum.ecAndPh),
    SettingItemEntity(name: 'Green House', image: 'assets/images/common/green_house.png', irrigationSettingsEnum: IrrigationSettingsEnum.greenHouse),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: 'Irrigation Settings'
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: SingleChildScrollView(
          child: Column(
            spacing: 20,
            children: [
              settingsSection(
                context: context,
                sectionTitle: 'Drip Setting',
                items: [
                  settings[1],
                  settings[2],
                ],
              ),
              settingsSection(
                context: context,
                sectionTitle: 'Flow & Valve Management',
                items: [
                  settings[10],
                  settings[5],
                ],
              ),
              settingsSection(
                context: context,
                sectionTitle: 'Water Source & Pump Control',
                items: [
                  settings[6],
                  settings[9],
                  settings[7],
                ],
              ),
              settingsSection(
                context: context,
                sectionTitle: 'Sensors & Field Conditions',
                items: [
                  settings[8],
                  settings[13],
                ],
              ),
              settingsSection(
                context: context,
                sectionTitle: 'Time, Safety & Alerts',
                items: [
                  settings[11],
                  settings[12],
                ],
              ),
              settingsSection(
                context: context,
                sectionTitle: 'Protected Cultivation',
                items: [
                  settings[14],
                ],
              ),
              SizedBox(height: 60,)
            ],
          ),
        ),
      ),
      // body: GradiantBackground(
      //     child: GridView.builder(
      //       padding: const EdgeInsets.all(16),
      //       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      //         crossAxisCount: 3,        // ✅ 3 per row
      //         crossAxisSpacing: 14,
      //         mainAxisSpacing: 14,
      //         childAspectRatio: 0.8,   // perfect card ratio
      //       ),
      //       itemCount: settings.length,
      //       itemBuilder: (context, index) {
      //         return SettingCard(item: settings[index]);
      //       },
      //     )
      // ),
    );
  }

  Widget _navigationRow(BuildContext context, SettingItemEntity entity, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Image.asset(
              entity.image,
            width: 25,
            height: 25,
          ),
          SizedBox(width: 10,),
          Text(entity.name, style: Theme.of(context).textTheme.labelLarge),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 14,),
        ],
      ),
    );
  }

  Widget settingsSection({
    required BuildContext context,
    required String sectionTitle,
    required List<SettingItemEntity> items,
    List<VoidCallback?>? onTaps,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sectionTitle,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 10),
        CustomCard(
          child: Column(
            children: List.generate(items.length * 2 - 1, (index) {
              if (index.isOdd) {
                return const Divider(thickness: 0.6);
              }
              final itemIndex = index ~/ 2;
              return _navigationRow(
                context,
                items[itemIndex],
                onTap: () {
                  if(items[itemIndex].irrigationSettingsEnum != IrrigationSettingsEnum.irrigationFertigation){
                    context.push('${IrrigationSettingsRoutes.irrigationSettings}${IrrigationSettingsRoutes.templateSetting
                        .replaceAll(':settingName', items[itemIndex].name)
                        .replaceAll(':settingNo', items[itemIndex].irrigationSettingsEnum.settingId.toString())
                    }');
                  }
                },
              );
            }),
          ),
        ),
      ],
    );
  }



}
