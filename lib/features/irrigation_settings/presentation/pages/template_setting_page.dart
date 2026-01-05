import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_app_bar.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glassy_wrapper.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/gradiant_background.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/presentation/widgets/find_suitable_widget.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/presentation/widgets/setting_row.dart';

import '../../../../core/services/time_picker_service.dart';
import '../../../../core/widgets/alert_dialog.dart';
import '../../../../core/widgets/app_alerts.dart';
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
            print(state);
            if (state is TemplateIrrigationSettingsLoading) {
              return const Center(child: CircularProgressIndicator());
            }else if(state is TemplateIrrigationSettingsLoaded){
              return GradiantBackground(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 10,),
                        ...List.generate(state.controllerIrrigationSettingEntity.settings.length, (groupIndex){
                          CommonSettingGroupEntity commonSettingGroupEntity = state.controllerIrrigationSettingEntity.settings[groupIndex];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(commonSettingGroupEntity.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
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
                                            Divider(color: Colors.grey.shade300,)
                                          ],
                                        );
                                      }else if (setting is MultipleSettingItemEntity){
                                        return Column(
                                          children: [
                                            Row(
                                              children: [
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
                                                IconButton(
                                                  onPressed: (){
                                                    print('send button clicked....');
                                                    context.read<TemplateIrrigationSettingsBloc>().add(
                                                        UpdateTemplateSettingEvent(
                                                          groupIndex: groupIndex,
                                                          settingIndex: index
                                                        )
                                                    );                                            },
                                                  icon: Icon(Icons.send_outlined, color: Theme.of(context).primaryColor,),
                                                  style: ButtonStyle(
                                                      backgroundColor: WidgetStatePropertyAll(Theme.of(context).primaryColorLight.withValues(alpha: 0.3))
                                                  ),
                                                )
                                              ],
                                            ),
                                            Divider(color: Colors.grey.shade300,)
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
                  )
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
