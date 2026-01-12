import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/core/services/time_picker_service.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_switch.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/leaf_box.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/tiny_text_form_field.dart';

import '../../domain/entities/common_setting_item_entity.dart';
import '../bloc/template_irrigation_settings_bloc.dart';

class FindSuitableWidget extends StatelessWidget {
  final SingleSettingItemEntity singleSettingItemEntity;
  final void Function(dynamic)? onChanged;
  final void Function()? onTap;
  const FindSuitableWidget({
    super.key,
    required this.singleSettingItemEntity,
    required this.onChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if(singleSettingItemEntity.widgetType == 2){
      return CustomSwitch(value: singleSettingItemEntity.value == 'ON', onChanged: onChanged);
      return Switch(
          value: singleSettingItemEntity.value == 'ON' ? true : false,
          onChanged: onChanged
      );
    }else if(singleSettingItemEntity.widgetType == 3){
      return GestureDetector(
        onTap: onTap,
        child: LeafBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(singleSettingItemEntity.value, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.black),),
                Text('HH:MM', style: TextStyle(color: Theme.of(context).colorScheme.outline, fontSize: 10, fontWeight: FontWeight.w400),)
              ],
            )
        ),
      );
    }else if([9, 10].contains(singleSettingItemEntity.widgetType)){
      return LeafBox(
        child: TinyTextFormField(
            value: singleSettingItemEntity.value,
          onChanged: onChanged,
        ),
      );
    }else if(singleSettingItemEntity.widgetType == 8){
       return DropdownButton(
         key: UniqueKey(),
         underline: Container(),
         value: singleSettingItemEntity.value,
         items: singleSettingItemEntity.option.map((e){
           return DropdownMenuItem(
             value: e,
               child: Text(e)
           );
         }).toList(),
         onChanged: onChanged,
       );
    }

    return Container();
  }
}

final integerFormatter = FilteringTextInputFormatter.allow(RegExp(r'[0-9]'));
final decimalFormatter = FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'));
