import 'package:flutter/material.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/presentation/widgets/find_suitable_widget.dart';

import '../../domain/entities/common_setting_item_entity.dart';

class SettingRow extends StatelessWidget {
  final SingleSettingItemEntity singleSettingItemEntity;
  final bool hideSendButton;
  final void Function(dynamic)? onChanged;
  final void Function()? onTap;
  const SettingRow({
    super.key,
    required this.singleSettingItemEntity,
    required this.hideSendButton,
    required this.onChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(singleSettingItemEntity.titleText, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)),
          SizedBox(
            width: 150,
            child: FindSuitableWidget(
              singleSettingItemEntity: singleSettingItemEntity,
              onChanged: onChanged, onTap: onTap,
            ),
          ),
          if(!hideSendButton)
            ...[
              SizedBox(width: 10,),
              IconButton(
                onPressed: (){

                },
                icon: Icon(Icons.send_outlined, color: Theme.of(context).primaryColor,),
                style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Theme.of(context).primaryColorLight.withValues(alpha: 0.3))
                ),
              )
            ]

        ],
      ),
    );
  }
}
