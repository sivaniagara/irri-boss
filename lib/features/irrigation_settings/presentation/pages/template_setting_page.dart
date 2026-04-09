import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_app_bar.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_material_button.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/presentation/widgets/setting_row.dart';

import '../../../../core/services/time_picker_service.dart';
import '../../../../core/widgets/alert_dialog.dart';
import '../../../../core/widgets/app_alerts.dart';
import '../../../../core/widgets/tiny_text_form_field.dart';
import '../../../dashboard/presentation/cubit/controller_context_cubit.dart';
import '../../domain/entities/common_setting_group_entity.dart';
import '../../domain/entities/common_setting_item_entity.dart';
import '../../domain/entities/controller_irrigation_setting_entity.dart';
import '../bloc/template_irrigation_settings_bloc.dart';
import '../enums/update_template_setting_status.dart';

class TemplateSettingPage extends StatelessWidget {
  final String appBarTitle;
  final String settingNo;
  const TemplateSettingPage({super.key, required this.appBarTitle, required this.settingNo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: appBarTitle,
        actions: [
          IconButton(
            onPressed: () {
              final bloc = context.read<TemplateIrrigationSettingsBloc>();
              if (bloc.state is TemplateIrrigationSettingsLoaded) {
                _showVisibilityBottomSheet(context, bloc.state as TemplateIrrigationSettingsLoaded);
              }
            },
            icon: const Icon(Icons.settings_suggest_outlined),
          ),
        ],
      ),
      body: BlocConsumer<TemplateIrrigationSettingsBloc, TemplateIrrigationSettingsState>(
          builder: (context, state){
            if (state is TemplateIrrigationSettingsLoading) {
              return const Center(child: CircularProgressIndicator());
            }else if(state is TemplateIrrigationSettingsLoaded){
              final currentEntity = state.updatedControllerIrrigationSettingEntity ?? state.controllerIrrigationSettingEntity;

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 10,),
                      ...List.generate(currentEntity.settings.length, (groupIndex){
                        CommonSettingGroupEntity commonSettingGroupEntity = currentEntity.settings[groupIndex];

                        // Check if any setting in this group is visible
                        bool anyVisible = commonSettingGroupEntity.sets.any((s) {
                          if (s is SingleSettingItemEntity) return s.hf == '1';
                          if (s is MultipleSettingItemEntity) return s.listOfSingleSettingItemEntity.any((ss) => ss.hf == '1');
                          return false;
                        });
                        if (!anyVisible) return const SizedBox.shrink();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(commonSettingGroupEntity.name, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.black, fontWeight: FontWeight.w400)),
                            const SizedBox(height: 8,),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                                      if (setting.hf == '0') return const SizedBox.shrink();

                                      return Column(
                                        children: [
                                          BlocSelector<TemplateIrrigationSettingsBloc, TemplateIrrigationSettingsState, String>(
                                              selector: (state){
                                                if (state is! TemplateIrrigationSettingsLoaded) return '';
                                                final currentEntity = state.updatedControllerIrrigationSettingEntity ?? state.controllerIrrigationSettingEntity;
                                                return (currentEntity
                                                    .settings[groupIndex]
                                                    .sets[index] as SingleSettingItemEntity)
                                                    .value;
                                              },
                                              builder: (context, value){
                                                return SettingRow(
                                                  singleSettingItemEntity: setting.copyWith(updateValue: value),
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
                                                        initialTime: value
                                                    );
                                                    if(result != null) {
                                                      context.read<TemplateIrrigationSettingsBloc>().add(
                                                          UpdateSingleSettingRowEvent(
                                                              groupIndex: groupIndex,
                                                              index: index,
                                                              value: result
                                                          )
                                                      );
                                                    }
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
                                      bool allHidden = setting.listOfSingleSettingItemEntity.every((s) => s.hf == '0');
                                      if (allHidden) return const SizedBox.shrink();

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
                                                    final child = setting.listOfSingleSettingItemEntity[multipleIndex];
                                                    if (child.hf == '0') return const SizedBox.shrink();

                                                    return BlocSelector<TemplateIrrigationSettingsBloc, TemplateIrrigationSettingsState, String>(
                                                      selector: (state) {
                                                        if (state is! TemplateIrrigationSettingsLoaded) return 'OF';
                                                        final entity = state.updatedControllerIrrigationSettingEntity ?? state.controllerIrrigationSettingEntity;
                                                        final item = entity.settings[groupIndex].sets[index] as MultipleSettingItemEntity;
                                                        return item.listOfSingleSettingItemEntity[multipleIndex].value;
                                                      },
                                                      builder: (context, currentValue) {
                                                        return GestureDetector(
                                                          onTap: (){
                                                            context.read<TemplateIrrigationSettingsBloc>().add(
                                                              UpdateMultipleSettingRowEvent(
                                                                groupIndex: groupIndex,
                                                                multipleIndex: index,
                                                                index: multipleIndex,
                                                                value: currentValue == 'OF' ? 'ON' : 'OF',
                                                              ),
                                                            );
                                                          },
                                                          child: Container(
                                                            padding: const EdgeInsets.all(10),
                                                            decoration: BoxDecoration(
                                                                color: currentValue == 'ON' ? Theme.of(context).colorScheme.primary : null,
                                                                border: Border.all(width: 1, color: Theme.of(context).colorScheme.primary),
                                                                borderRadius: BorderRadius.circular(6)
                                                            ),
                                                            child: Text(setting.listOfSingleSettingItemEntity[multipleIndex].titleText, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: currentValue == 'ON' ? Colors.white : null),),
                                                          ),
                                                        );
                                                      },
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
                                                      final child = setting.listOfSingleSettingItemEntity[multipleIndex];
                                                      if (child.hf == '0') return const SizedBox.shrink();

                                                      return BlocSelector<TemplateIrrigationSettingsBloc, TemplateIrrigationSettingsState, String>(
                                                        selector: (state) {
                                                          if (state is! TemplateIrrigationSettingsLoaded) return '';
                                                          final entity = state.updatedControllerIrrigationSettingEntity ?? state.controllerIrrigationSettingEntity;
                                                          final item = entity.settings[groupIndex].sets[index] as MultipleSettingItemEntity;
                                                          return item.listOfSingleSettingItemEntity[multipleIndex].value;
                                                        },
                                                        builder: (context, currentValue) {
                                                          return Container(
                                                            decoration: BoxDecoration(
                                                                borderRadius: const BorderRadius.only(
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
                                                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                                                    decoration: BoxDecoration(
                                                                        color: Theme.of(context).colorScheme.primary,
                                                                        borderRadius: const BorderRadius.only(
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
                                                                        value: currentValue,
                                                                        onChanged: (newValue) {
                                                                          context.read<TemplateIrrigationSettingsBloc>().add(
                                                                            UpdateMultipleSettingRowEvent(
                                                                              groupIndex: groupIndex,
                                                                              multipleIndex: index,
                                                                              index: multipleIndex,
                                                                              value: newValue,
                                                                            ),
                                                                          );
                                                                        }
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    }),
                                                  ),
                                                )
                                              else
                                                Expanded(
                                                  child: Column(
                                                    children: [
                                                      ...List.generate(setting.listOfSingleSettingItemEntity.length, (multipleIndex) {
                                                        final child = setting.listOfSingleSettingItemEntity[multipleIndex];
                                                        if (child.hf == '0') return const SizedBox.shrink();

                                                        return BlocSelector<TemplateIrrigationSettingsBloc, TemplateIrrigationSettingsState, String>(
                                                          selector: (state) {
                                                            if (state is! TemplateIrrigationSettingsLoaded) return '';

                                                            final entity = state.updatedControllerIrrigationSettingEntity ?? state.controllerIrrigationSettingEntity;
                                                            final groups = entity.settings;
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
                                                              singleSettingItemEntity: childEntity.copyWith(updateValue: currentValue),
                                                              hideSendButton: true,
                                                              onChanged: (value) {
                                                                print('multi onChanged: $value');
                                                                context.read<TemplateIrrigationSettingsBloc>().add(
                                                                  UpdateMultipleSettingRowEvent(
                                                                    groupIndex: groupIndex,
                                                                    multipleIndex: index,
                                                                    index: multipleIndex,
                                                                    value: childEntity.widgetType == 2
                                                                        ? (value == true ? 'ON' : 'OF')
                                                                        : value.toString(),
                                                                  ),
                                                                );
                                                              },
                                                              onTap: childEntity.widgetType == 3 ? () async {
                                                                final result = await TimePickerService.show(
                                                                  context: context,
                                                                  initialTime: currentValue,
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
                                                  padding: const EdgeInsets.all(10),
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
                                      return const Placeholder();
                                    }


                                  })

                                ],
                              ),
                            ),
                            const SizedBox(height: 10,)
                          ],
                        );
                      }),


                    ],
                  ),
                ),
              );
            }else{
              return Center(
                child: CustomMaterialButton(
                    onPressed: (){
                      final controllerContext = context.read<ControllerContextCubit>().state as ControllerContextLoaded;
                      context.read<TemplateIrrigationSettingsBloc>().add(
                          FetchTemplateSettingEvent(
                              userId: controllerContext.userId,
                              controllerId: controllerContext.controllerId,
                              subUserId: controllerContext.subUserId,
                              settingNo: settingNo,
                              deviceId: controllerContext.deviceId
                          )
                      );
                    },
                    title: 'Retry'
                ),
              );
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

  void _showVisibilityBottomSheet(BuildContext context, TemplateIrrigationSettingsLoaded state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return BlocProvider.value(
          value: context.read<TemplateIrrigationSettingsBloc>(),
          child: DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      height: 5,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.visibility_outlined, color: Theme.of(context).primaryColor),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Personalize View',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                              ),
                              Text(
                                'Toggle settings to show/hide on main page',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: BlocBuilder<TemplateIrrigationSettingsBloc, TemplateIrrigationSettingsState>(
                        builder: (context, state) {
                          if (state is! TemplateIrrigationSettingsLoaded) return const SizedBox.shrink();
                          final entity = state.updatedControllerIrrigationSettingEntity ?? state.controllerIrrigationSettingEntity;

                          return ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.only(bottom: 24),
                            itemCount: entity.settings.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 16),
                            itemBuilder: (context, groupIndex) {
                              final group = entity.settings[groupIndex];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                    child: Text(
                                      group.name.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.2,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.grey[200]!),
                                    ),
                                    child: Column(
                                      children: List.generate(group.sets.length, (settingIndex) {
                                        return _buildCreativeVisibilityItem(context, entity, groupIndex, settingIndex);
                                      }),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: CustomMaterialButton(
                        onPressed: () {
                          context.read<TemplateIrrigationSettingsBloc>().add(
                            UpdateTemplateSettingEvent(
                              groupIndex: 0,
                              settingIndex: 0,
                            ),
                          );
                        },
                        title: 'Save Changes',
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCreativeVisibilityItem(BuildContext context, ControllerIrrigationSettingEntity entity, int groupIndex, int settingIndex) {
    final setting = entity.settings[groupIndex].sets[settingIndex];
    if (setting is SingleSettingItemEntity) {
      return _buildOldTile(
        context: context,
        title: setting.titleText,
        isActive: setting.hf == '1',
        onChanged: (val) {
          context.read<TemplateIrrigationSettingsBloc>().add(
            UpdateHfValueEvent(
              groupIndex: groupIndex,
              index: settingIndex,
              hfValue: (val ?? false) ? '1' : '0',
            ),
          );
        },
      );
    } else if (setting is MultipleSettingItemEntity) {
      return Column(
        children: List.generate(setting.listOfSingleSettingItemEntity.length, (mIndex) {
          final subSetting = setting.listOfSingleSettingItemEntity[mIndex];
          return _buildOldTile(
            context: context,
            title: subSetting.titleText,
            isActive: subSetting.hf == '1',
            onChanged: (val) {
              context.read<TemplateIrrigationSettingsBloc>().add(
                UpdateHfValueEvent(
                  groupIndex: groupIndex,
                  index: mIndex,
                  multipleIndex: settingIndex,
                  hfValue: (val ?? false) ? '1' : '0',
                ),
              );
            },
          );
        }),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildOldTile({
    required BuildContext context,
    required String title,
    required bool isActive,
    required ValueChanged<bool?> onChanged,
  }) {
    return CheckboxListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isActive ? Colors.black87 : Colors.grey[500],
        ),
      ),
      value: isActive,
      activeColor: Theme.of(context).primaryColor,
      checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }
}
