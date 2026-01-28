import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_app_bar.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/gradiant_background.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/presentation/widgets/setting_row.dart';

import '../../../../core/services/time_picker_service.dart';
import '../../../../core/widgets/alert_dialog.dart';
import '../../../../core/widgets/app_alerts.dart';
import '../../../../core/widgets/tiny_text_form_field.dart';
import '../../domain/entities/common_setting_group_entity.dart';
import '../../domain/entities/common_setting_item_entity.dart';
import '../bloc/template_irrigation_settings_bloc.dart';
import '../enums/update_template_setting_status.dart';

class TemplateSettingPage extends StatelessWidget {
  final String appBarTitle;
  const TemplateSettingPage({super.key, required this.appBarTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: appBarTitle),
      body: BlocConsumer<TemplateIrrigationSettingsBloc, TemplateIrrigationSettingsState>(
          builder: (context, state){
            if (state is TemplateIrrigationSettingsLoading) {
              return const Center(child: CircularProgressIndicator());
            }else if(state is TemplateIrrigationSettingsLoaded){
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      SizedBox(height: 10,),
                      ...List.generate(state.controllerIrrigationSettingEntity.settings.length, (groupIndex){
                        CommonSettingGroupEntity commonSettingGroupEntity = state.controllerIrrigationSettingEntity.settings[groupIndex];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(commonSettingGroupEntity.name, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.black, fontWeight: FontWeight.w400)),
                            SizedBox(height: 8,),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white
                              ),
                              child: Column(
                                children: [
                                  ...List.generate(commonSettingGroupEntity.sets.length, (index){
                                    CommonSettingItemEntity setting = commonSettingGroupEntity.sets[index];
                                    if(setting is SingleSettingItemEntity){
                                      return Column(
                                        children: [
                                          BlocSelector<TemplateIrrigationSettingsBloc, TemplateIrrigationSettingsState, String>(
                                              selector: (state){
                                                if (state is! TemplateIrrigationSettingsLoaded) return '';
                                                return (state
                                                    .controllerIrrigationSettingEntity
                                                    .settings[groupIndex]
                                                    .sets[index] as SingleSettingItemEntity)
                                                    .value;
                                              },
                                              builder: (context, value){
                                                return SettingRow(
                                                  singleSettingItemEntity: setting,
                                                  hideSendButton: false,
                                                  onChanged: (value) {
                                                    print('value : $value');
                                                    context.read<TemplateIrrigationSettingsBloc>().add(
                                                        UpdateSingleSettingRowEvent(
                                                            groupIndex: groupIndex,
                                                            index: index,
                                                            value: setting.widgetType == 2 ? (value ? 'ON': 'OF') : value
                                                        )
                                                    );
                                                  },
                                                  onTap: () async{
                                                    final result = await TimePickerService.show(
                                                        context: context,
                                                        initialTime: setting.value
                                                    );
                                                    context.read<TemplateIrrigationSettingsBloc>().add(
                                                        UpdateSingleSettingRowEvent(
                                                            groupIndex: groupIndex,
                                                            index: index,
                                                            value: result
                                                        )
                                                    );
                                                  },
                                                  groupIndex: groupIndex,
                                                  settingIndex: index,
                                                );
                                              }
                                          ),
                                        ],
                                      );
                                    }
                                    else if (setting is MultipleSettingItemEntity){
                                      return Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              if(groupIndex == 1 && index == 0 && state.settingId == '518')
                                                Wrap(
                                                  spacing: 10,
                                                  alignment: WrapAlignment.start,
                                                  children: List.generate(setting.listOfSingleSettingItemEntity.length, (multipleIndex){
                                                    return GestureDetector(
                                                      onTap: (){
                                                        context.read<TemplateIrrigationSettingsBloc>().add(
                                                          UpdateMultipleSettingRowEvent(
                                                            groupIndex: groupIndex,
                                                            multipleIndex: index,
                                                            index: multipleIndex,
                                                            value: setting.listOfSingleSettingItemEntity[multipleIndex].value == 'OF' ? 'ON' : 'OF',
                                                          ),
                                                        );
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets.all(10),
                                                        decoration: BoxDecoration(
                                                            color: setting.listOfSingleSettingItemEntity[multipleIndex].value == 'ON' ? Theme.of(context).colorScheme.primary : null,
                                                            border: Border.all(width: 1, color: Theme.of(context).colorScheme.primary),
                                                            borderRadius: BorderRadius.circular(6)
                                                        ),
                                                        child: Text(setting.listOfSingleSettingItemEntity[multipleIndex].titleText, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: setting.listOfSingleSettingItemEntity[multipleIndex].value == 'ON' ? Colors.white : null),),
                                                      ),
                                                    );
                                                  }),
                                                )
                                              else if(groupIndex == 2 && index == 0 && state.settingId == '518')
                                                Expanded(
                                                  child: Wrap(
                                                    runSpacing: 10,
                                                    spacing: 10,
                                                    alignment: WrapAlignment.start,
                                                    children: List.generate(setting.listOfSingleSettingItemEntity.length, (multipleIndex){
                                                      return Container(
                                                        decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.only(
                                                              bottomLeft: Radius.circular(10),
                                                              topRight: Radius.circular(10),
                                                            ),
                                                            border: Border.all(width: 1, color: Theme.of(context).colorScheme.outline)
                                                        ),
                                                        child: SizedBox(
                                                          width: 150,
                                                          child: Row(
                                                            children: [
                                                              Container(
                                                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                                                decoration: BoxDecoration(
                                                                    color: Theme.of(context).colorScheme.primary,
                                                                    borderRadius: BorderRadius.only(
                                                                      bottomLeft: Radius.circular(10),
                                                                      topRight: Radius.circular(10),
                                                                    )
                                                                ),
                                                                child: Text(
                                                                  setting.listOfSingleSettingItemEntity[multipleIndex].titleText, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white),),
                                                              ),
                                                              SizedBox(
                                                                width: 100,
                                                                child: TinyTextFormField(
                                                                    value: setting.listOfSingleSettingItemEntity[multipleIndex].value
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                                  ),
                                                )
                                              else
                                                Expanded(
                                                  child: Column(
                                                    children: [
                                                      ...List.generate(setting.listOfSingleSettingItemEntity.length, (multipleIndex) {
                                                        return BlocSelector<TemplateIrrigationSettingsBloc, TemplateIrrigationSettingsState, String>(
                                                          selector: (state) {
                                                            if (state is! TemplateIrrigationSettingsLoaded) return '';

                                                            final groups = state.controllerIrrigationSettingEntity.settings;
                                                            if (groupIndex >= groups.length) return '';

                                                            final sets = groups[groupIndex].sets;
                                                            if (index >= sets.length) return '';

                                                            final item = sets[index];
                                                            if (item is! MultipleSettingItemEntity) return '';

                                                            final innerList = item.listOfSingleSettingItemEntity;
                                                            if (multipleIndex >= innerList.length) return '';

                                                            return innerList[multipleIndex].value;
                                                          },
                                                          builder: (context, currentValue) {
                                                            final childEntity = setting.listOfSingleSettingItemEntity[multipleIndex];

                                                            return SettingRow(
                                                              singleSettingItemEntity: childEntity,
                                                              hideSendButton: true,
                                                              onChanged: (value) {
                                                                print('multi onChanged: $value');
                                                                context.read<TemplateIrrigationSettingsBloc>().add(
                                                                  UpdateMultipleSettingRowEvent(
                                                                    groupIndex: groupIndex,
                                                                    multipleIndex: index,         // index of MultipleSettingItemEntity in sets
                                                                    index: multipleIndex,         // index inside the inner list
                                                                    value: childEntity.widgetType == 2
                                                                        ? (value == true ? 'ON' : 'OF')
                                                                        : value.toString(),
                                                                  ),
                                                                );
                                                              },
                                                              onTap: childEntity.widgetType == 3 ? () async {  // only if it's time picker
                                                                final result = await TimePickerService.show(
                                                                  context: context,
                                                                  initialTime: childEntity.value,
                                                                );
                                                                if (result != null) {
                                                                  context.read<TemplateIrrigationSettingsBloc>().add(
                                                                    UpdateMultipleSettingRowEvent(
                                                                      groupIndex: groupIndex,
                                                                      multipleIndex: index,
                                                                      index: multipleIndex,
                                                                      value: result,
                                                                    ),
                                                                  );
                                                                }
                                                              } : null,
                                                              groupIndex: groupIndex,
                                                              settingIndex: index,
                                                            );
                                                          },
                                                        );
                                                      })
                                                    ],
                                                  ),
                                                ),
                                              InkWell(
                                                onTap: (){
                                                  context.read<TemplateIrrigationSettingsBloc>().add(
                                                      UpdateTemplateSettingEvent(
                                                          groupIndex: groupIndex,
                                                          settingIndex: index
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
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    }else{
                                      return Placeholder();
                                    }


                                  })

                                ],
                              ),
                            ),
                            SizedBox(height: 10,)
                          ],
                        );
                      }),


                    ],
                  ),
                ),
              );
            }else{
              return Placeholder();
            }

          },
          listener: (context, state){
            if(state is TemplateIrrigationSettingsLoaded && state.updateTemplateSettingStatus == UpdateTemplateSettingStatus.loading){
              showGradientLoadingDialog(context);
            }else if(state is TemplateIrrigationSettingsLoaded && state.updateTemplateSettingStatus == UpdateTemplateSettingStatus.failure){
              context.pop();
              showErrorAlert(context: context, message: state.message);
            }else if(state is TemplateIrrigationSettingsLoaded && state.updateTemplateSettingStatus == UpdateTemplateSettingStatus.success){
              context.pop();
              showSuccessAlert(
                  context: context,
                  message: state.message,
                  onPressed: (){
                    context.pop();
                  }
              );
            }
          }
      ),
    );
  }
}
