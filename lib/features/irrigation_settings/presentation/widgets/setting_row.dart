import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/presentation/widgets/find_suitable_widget.dart';

import '../../domain/entities/common_setting_item_entity.dart';
import '../bloc/template_irrigation_settings_bloc.dart';

class SettingRow extends StatelessWidget {
  final SingleSettingItemEntity singleSettingItemEntity;
  final bool hideSendButton;
  final void Function(dynamic)? onChanged;
  final void Function()? onTap;
  final int groupIndex;
  final int settingIndex;
  const SettingRow({
    super.key,
    required this.singleSettingItemEntity,
    required this.hideSendButton,
    required this.onChanged,
    required this.onTap,
    required this.groupIndex,
    required this.settingIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(singleSettingItemEntity.titleText, style: Theme.of(context).textTheme.labelLarge,)),
          Container(
            padding: EdgeInsets.only(right: singleSettingItemEntity.widgetType == 2 ? 10 : 0),
            width: singleSettingItemEntity.widgetType == 2 ? 65 : 150,
            child: FindSuitableWidget(
              singleSettingItemEntity: singleSettingItemEntity,
              onChanged: onChanged, onTap: onTap,
            ),
          ),
          if(!hideSendButton)
            ...[
              InkWell(
                onTap: (){
                  context.read<TemplateIrrigationSettingsBloc>().add(
                      UpdateTemplateSettingEvent(
                          groupIndex: groupIndex,
                          settingIndex: settingIndex
                      )
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Image.asset(
                      'assets/images/icons/send_icon.png',
                    width: 25,
                  ),
                ),
              )
            ]
        ],
      ),
    );
  }
}
