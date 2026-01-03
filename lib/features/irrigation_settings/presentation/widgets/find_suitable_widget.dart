import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/core/services/time_picker_service.dart';

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
      return Switch(
          value: singleSettingItemEntity.value == 'ON' ? true : false,
          onChanged: onChanged
      );
    }else if(singleSettingItemEntity.widgetType == 3){
      return GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), topRight: Radius.circular(15)),
              border: Border.all(width: 1)
          ),
          child: Center(
              child: Text(singleSettingItemEntity.value)
          ),
        ),
      );
    }else if([9, 10].contains(singleSettingItemEntity.widgetType)){
      return TextFormField(
        initialValue: singleSettingItemEntity.value,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            // borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 1.5,
            ),
          ),
          // contentPadding:
          // const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        onChanged: onChanged,
      );
    }else if(singleSettingItemEntity.widgetType == 8){
       return DropdownButton(
         key: UniqueKey(),
         underline: Container(),
         value: singleSettingItemEntity.value,
         items: singleSettingItemEntity.optionSno.map((e){
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
