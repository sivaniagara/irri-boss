import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/app_alerts.dart';
import 'package:niagara_smart_drip_irrigation/features/edit_program/presentation/enums/add_remove_enum.dart';
import 'package:niagara_smart_drip_irrigation/features/edit_program/presentation/pages/payload_page.dart';
import 'package:niagara_smart_drip_irrigation/features/edit_program/presentation/widgets/card_header.dart';
import 'package:niagara_smart_drip_irrigation/features/edit_program/presentation/widgets/custom_card.dart';
import 'package:niagara_smart_drip_irrigation/features/edit_program/presentation/widgets/custom_radio_selection.dart';
import 'package:niagara_smart_drip_irrigation/features/edit_program/presentation/widgets/sharp_radius_card.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:niagara_smart_drip_irrigation/features/edit_program/presentation/widgets/wrap_or_row.dart';
import '../../../../core/services/time_picker_service.dart';
import '../../../../core/widgets/alert_dialog.dart';
import '../../domain/entities/zone_setting_entity.dart';
import '../bloc/edit_program_bloc.dart';
import '../../../../core/widgets/tiny_text_form_field.dart';

class EditProgramPage extends StatefulWidget {
  const EditProgramPage({super.key});

  @override
  State<EditProgramPage> createState() => _EditProgramPageState();
}

class _EditProgramPageState extends State<EditProgramPage> {
  int irrigationDosingOrPrePostMode = 1;
  int timeOrQuantity = 1;
  int selectedChannel = 0;
  bool showZone = true;
  bool showValve = true;
  bool showMoisture = true;
  bool showLevel = true;
  bool showAdjustPercent = true;
  int selectedZone = 0;
  DeleteMode deleteMode = DeleteMode.single;

  void showPayloadBottomSheet(BuildContext context) {
    final editProgramBloc = context.read<EditProgramBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return BlocProvider.value(
          value: editProgramBloc,
          child: PayloadPage(
            channelNo: selectedChannel + 1,
            irrigationDosingOrPrePost: irrigationDosingOrPrePostMode,
            method: timeOrQuantity,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Program 1', style: Theme.of(context).textTheme.titleLarge,),
        actions: [
          GestureDetector(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Image.asset('assets/images/icons/sent_and_receive_icon.png'),
            ),
          )
        ],
      ),
      floatingActionButton: BlocListener<EditProgramBloc, EditProgramState>(
        listener: (BuildContext context, state) {
          if(state is EditProgramLoaded && state.saveProgramStatus == SaveProgramStatus.loading){
            showGradientLoadingDialog(context);
          }else if(state is EditProgramLoaded && state.saveProgramStatus == SaveProgramStatus.success){
            context.pop();
            showPayloadBottomSheet(context);
          }else if(state is EditProgramLoaded && state.saveProgramStatus == SaveProgramStatus.failure){
            context.pop();
            showErrorAlert(
                context: context,
                message: 'Program Failed to Save!',
            );
          }
        },
        child: FloatingActionButton(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Image.asset(
              'assets/images/icons/send_icon.png',
            width: 30,
            color: Colors.white,
          ),
            onPressed: (){
              final currentState = context.read<EditProgramBloc>().state;
              if(currentState is EditProgramLoaded){
                context.read<EditProgramBloc>().add(
                    SaveProgramEvent(
                        userId: currentState.userId,
                        controllerId: currentState.controllerId,
                        deviceId: currentState.deviceId,
                        editProgramEntity: currentState.editProgramEntity
                    )
                );
              }
            }
        ),
      ),
      body: BlocConsumer<EditProgramBloc, EditProgramState>(
        builder: (BuildContext context, state) {
          if(state is EditProgramLoading){
            return Container(
              width: double.infinity,
              height: double.infinity,
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/lottie/fetch_data.json',
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.width * 0.8,
                    repeat: true,
                  ),
                  Text("Fetching data...", style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.black),),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: LinearProgressIndicator(
                      minHeight: 6, // optional: thicker bar
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ],
              ),
            );
          }else if(state is EditProgramLoaded){
            return SingleChildScrollView(
              child: Column(
                spacing: 20,
                children: [
                  zoneBox(state),
                  if(state.editProgramEntity.zones.isNotEmpty && state.editProgramEntity.zones[selectedZone].active)
                    ...[
                      valveBox(state),
                      moistureBox(state),
                      levelBox(state),
                    ],
                  adjustPercentBox(state: state),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: DottedBorder(
                      options: RoundedRectDottedBorderOptions(
                        dashPattern: const [8, 4],
                        color: Theme.of(context).colorScheme.outline,
                        strokeWidth: 2,
                        strokeCap: StrokeCap.butt,
                        radius: Radius.circular(16),
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: 10,),
                          ToggleButtons(
                            isSelected: [irrigationDosingOrPrePostMode == 1, irrigationDosingOrPrePostMode == 2],
                            onPressed: (index) {
                              setState(() {
                                irrigationDosingOrPrePostMode = index + 1;
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            selectedColor: Colors.white,
                            fillColor: Theme.of(context).colorScheme.primary,
                            children: const [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 30),
                                child: Text('Irrigation & Dosing', style: TextStyle(fontSize: 16),),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 30),
                                child: Text('Pre Post', style: TextStyle(fontSize: 16)),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomRadioSelection(
                                  title: 'Time',
                                  selected: timeOrQuantity == 1 ? true : false,
                                  onTap: (){
                                    setState(() {
                                      timeOrQuantity = 1;
                                    });
                                  }
                              ),
                              CustomRadioSelection(
                                  title: 'Flow',
                                  selected: timeOrQuantity == 2 ? true : false,
                                  onTap: (){
                                    setState(() {
                                      timeOrQuantity = 2;
                                    });
                                  }
                              ),
                            ],
                          ),
                          CustomCard(
                            horizontalPadding: 0,
                            child: Column(
                              children: [
                                tableHeader(),
                                Divider(),
                                ...List.generate(state.editProgramEntity.zones.length, (index){
                                  ZoneSettingEntity zone = state.editProgramEntity.zones[index];
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: MediaQuery.of(context).size.width * 0.2,
                                            child: Text(
                                              textAlign: TextAlign.center,
                                              zone.zoneNumber,
                                              style: Theme.of(context).textTheme.labelLarge,
                                            ),
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context).size.width * 0.3,
                                            child: timeOrQuantity == 1
                                                ? _timeField(
                                                time: irrigationDosingOrPrePostMode == 1 ? zone.time : zone.preTime, zoneNo: index, mode: irrigationDosingOrPrePostMode == 1 ? 1 :2
                                            ) : _zoneInputField(
                                                context,
                                                label: "",
                                                icon: Icons.timer_outlined,
                                                value: irrigationDosingOrPrePostMode == 1 ? zone.liters : zone.preLiters,
                                                zoneNo: index,
                                                channelIndex: selectedChannel,
                                                mode: irrigationDosingOrPrePostMode == 1 ? 1 : 2
                                            ),
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context).size.width * 0.3,
                                            child: timeOrQuantity == 1
                                                ?  _timeField(time: irrigationDosingOrPrePostMode == 1 ? getChannelTime(zone) : zone.postTime, zoneNo: index, mode: irrigationDosingOrPrePostMode == 1 ? 3 : 4)
                                                : _zoneInputField(
                                                context,
                                                label: "Liters",
                                                icon: Icons.opacity,
                                                value: irrigationDosingOrPrePostMode == 1 ? getChannelLiters(zone) : zone.postLiters,
                                                zoneNo: index,
                                                channelIndex: selectedChannel,
                                                mode: irrigationDosingOrPrePostMode == 1 ? 3 : 4
                                            ),
                                          )
                                        ],
                                      ),
                                      Divider(color: Theme.of(context).colorScheme.outline,)
                                    ],
                                  );
                                }),

                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          }
          return Placeholder();

        },
        listener: (BuildContext context, state) {

        },
      ),
    );
  }

  Future<void> pickTime(BuildContext context, int zoneNo, int mode) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        // Forces 24-hour format
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final String formattedTime = _formatTime(picked);
      print(formattedTime);
      if(irrigationDosingOrPrePostMode == 1 && timeOrQuantity == 1 && mode == 1){
        context.read<EditProgramBloc>().add(
            UpdateTotalTime(
                zoneIndex: zoneNo,
                time: formattedTime
            ));
      }else if(irrigationDosingOrPrePostMode == 2 && timeOrQuantity == 1 && mode == 2){
        context.read<EditProgramBloc>().add(
            UpdatePreTime(
              zoneIndex: zoneNo,
              time: formattedTime,
            ));
      }else if(irrigationDosingOrPrePostMode == 1 && timeOrQuantity == 1 && mode == 3){
        context.read<EditProgramBloc>().add(
            UpdateChannelTime(
                zoneIndex: zoneNo,
                time: formattedTime,
                channelIndex: selectedChannel
            ));
      }else{
        context.read<EditProgramBloc>().add(
            UpdatePostTime(
              zoneIndex: zoneNo,
              time: formattedTime,
            )
        );
      }
    }
  }

  String _formatTime(TimeOfDay time) {
    final String hh = time.hour.toString().padLeft(2, '0');
    final String mm = time.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }


  Widget leafBox({required Widget child}){
    return Container(
      margin: EdgeInsets.all(10),
      height: 40,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), topRight: Radius.circular(15)),
          border: Border.all(width: 1, color: Theme.of(context).colorScheme.outline)
      ),
      child: child,
    );
  }

  Widget _timeField({
    required String time,
    required int zoneNo,
    required int mode,
  }){
    return GestureDetector(
      // onTap: () => pickTime(context, zoneNo, mode),
      onTap: ()async{
        final result = await TimePickerService.show(
            context: context,
            initialTime: time
        );
        if(result != null){
          if(irrigationDosingOrPrePostMode == 1 && timeOrQuantity == 1 && mode == 1){
            context.read<EditProgramBloc>().add(
                UpdateTotalTime(
                    zoneIndex: zoneNo,
                    time: result
                ));
          }else if(irrigationDosingOrPrePostMode == 2 && timeOrQuantity == 1 && mode == 2){
            context.read<EditProgramBloc>().add(
                UpdatePreTime(
                  zoneIndex: zoneNo,
                  time: result,
                ));
          }else if(irrigationDosingOrPrePostMode == 1 && timeOrQuantity == 1 && mode == 3){
            context.read<EditProgramBloc>().add(
                UpdateChannelTime(
                    zoneIndex: zoneNo,
                    time: result,
                    channelIndex: selectedChannel
                ));
          }else{
            context.read<EditProgramBloc>().add(
                UpdatePostTime(
                  zoneIndex: zoneNo,
                  time: result,
                )
            );
          }
        }

      },
      child: leafBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(time, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.black),),
            Text('HH:MM', style: TextStyle(color: Theme.of(context).colorScheme.outline, fontSize: 10, fontWeight: FontWeight.w400),)
          ],
        )
      ),
    );
  }

  Widget _zoneInputField(
      BuildContext context, {
        required String label,
        required IconData icon,
        required String value,
        required int zoneNo,
        required int channelIndex,
        required int mode,
      }) {
    print("value : $value");
    return leafBox(
      child: TinyTextFormField(
        value: value,
        onChanged: (updatedValue) {
          if(irrigationDosingOrPrePostMode == 1 && timeOrQuantity == 2 && mode == 1){
            context.read<EditProgramBloc>().add(
                UpdateTotalLiters(
                    zoneIndex: zoneNo,
                    liters: updatedValue
                )
            );
          }else if(irrigationDosingOrPrePostMode == 2 && timeOrQuantity == 2 && mode == 2){
            context.read<EditProgramBloc>().add(
                UpdatePreLiters(
                    zoneIndex: zoneNo,
                    liters: updatedValue
                )
            );
          }else if(irrigationDosingOrPrePostMode == 1 && timeOrQuantity == 2 && mode == 3){
            context.read<EditProgramBloc>().add(
                UpdateChannelLiters(
                    zoneIndex: zoneNo,
                    channelIndex: selectedChannel,
                    liters: updatedValue
                )
            );
          }else{
            context.read<EditProgramBloc>().add(
                UpdatePostLiters(
                    zoneIndex: zoneNo,
                    liters: updatedValue
                )
            );
          }
        },
        onSubmitted: (newValue) {

        },
      ),
    );
  }

  String getChannelTime(ZoneSettingEntity zone){
    if(selectedChannel == 0){
      return zone.ch1Time;
    }else if(selectedChannel == 1){
      return zone.ch2Time;
    }else if(selectedChannel == 2){
      return zone.ch3Time;
    }else if(selectedChannel == 3){
      return zone.ch4Time;
    }else if(selectedChannel == 4){
      return zone.ch5Time;
    }else{
      return zone.ch6Time;
    }
  }

  String getChannelLiters(ZoneSettingEntity zone){
    if(selectedChannel == 0){
      return zone.ch1Liters;
    }else if(selectedChannel == 1){
      return zone.ch2Liters;
    }else if(selectedChannel == 2){
      return zone.ch3Liters;
    }else if(selectedChannel == 3){
      return zone.ch4Liters;
    }else if(selectedChannel == 4){
      return zone.ch5Liters;
    }else{
      return zone.ch6Liters;
    }
  }

  Widget tableHeader(){
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        spacing: 5,
        children: [
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.2,
              child: headerText('Block Name')
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
            child: headerText(
                irrigationDosingOrPrePostMode == 1 ? 'Water' : 'Pre'
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10,
              mainAxisSize: MainAxisSize.min,
              children: [
                headerText(irrigationDosingOrPrePostMode == 1 ? 'Dosing' : 'Post'),
                if(irrigationDosingOrPrePostMode == 1)
                  PopupMenuButton(
                    itemBuilder: (context){
                      return List.generate(6, (index){
                        return PopupMenuItem(
                          child: Text('F ${index+1}'),
                          onTap: (){
                            setState(() {
                              selectedChannel = index;
                            });
                          },
                        );
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(4),
                            bottomLeft: Radius.circular(10),
                          ),
                          color: Theme.of(context).colorScheme.secondary
                      ),
                      child: Center(
                        child: Text('F ${selectedChannel + 1}', style: Theme.of(context).textTheme.labelLarge,),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget zoneBox(EditProgramLoaded state){
    return CustomCard(
        child:  Column(
          spacing: 20,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'Select Block',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                IconButton(
                    onPressed: (){
                      setState(() {
                        showZone = !showZone;
                      });
                    },
                    icon: Icon(showZone ? Icons.keyboard_arrow_up_outlined : Icons.keyboard_arrow_down_outlined, size: 28, color: Colors.black,)
                ),
                const Spacer(),
                const SizedBox(width: 12),
                _buildActionButton(
                    icon: Icons.touch_app_outlined,
                    color: Colors.lightBlue[50]!,
                    iconName: 'add_icon',
                    onTap: () {
                      context.read<EditProgramBloc>().add(AddZoneEvent());
                    }
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                    icon: Icons.touch_app_outlined,
                    color: Colors.lightBlue[50]!,
                    iconName: 'select_all_icon', onTap: () {  }
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                    icon: Icons.delete_outline,
                    color: Colors.red[50]!,
                    iconName: 'delete_icon', onTap: () { 
                      context.read<EditProgramBloc>().add(DeleteZoneEvent(zoneIndex: selectedZone));
                }
                ),
              ],
            ),
            WrapOrRow(
                open: showZone,
                listOfWidget: [
                  for(var index = 0;index < state.editProgramEntity.zones.length;index++)
                    if(state.editProgramEntity.zones[index].active)
                      _chipWidget(
                        context: context,
                        title: 'BLOCK ${state.editProgramEntity.zones[index].zoneNumber}',
                        selected: selectedZone == index,
                        index: index,
                        onTap: () {
                          setState(() {
                            selectedZone = index;
                          });
                        },
                      )
                ],
            )
          ],
        )
    );
  }

  Widget valveBox(EditProgramLoaded state){
    return CustomCard(
        child: Column(
          children: [
            CardHeader(
                title: 'Select Valves',
                onPressed: (){
                  setState(() {
                    showValve = !showValve;
                  });
                }, open: showValve,
            ),
            WrapOrRow(
                open: showValve,
                listOfWidget: List.generate(state.editProgramEntity.mappedValves.length, (index){
                  bool isSelected = state.editProgramEntity.zones[selectedZone].valves.any((e) => e.serialNo == state.editProgramEntity.mappedValves[index].serialNo);
                  return _chipWidget(
                      context: context,
                      title: 'Valve ${index+1}',
                      selected:  isSelected,
                      color: Theme.of(context).colorScheme.secondary,
                      textColor:Colors.black,
                      index: index,
                      onTap: () {
                        if(!isSelected){
                          if(state.editProgramEntity.zones[selectedZone].valves.length < 4){
                            context.read<EditProgramBloc>().add(AddOrRemoveValveToZoneEvent(zoneIndex: selectedZone, nodeIndex: index, addRemoveEnum: AddRemoveEnum.add));
                          }else{
                            showErrorAlert(context: context, message: '4 valves able to selected per zone');
                          }
                        }else{
                          context.read<EditProgramBloc>().add(AddOrRemoveValveToZoneEvent(zoneIndex: selectedZone, nodeIndex: index, addRemoveEnum: AddRemoveEnum.remove));
                        }

                      }
                  );
                }),
            )
          ],
        )
    );
  }

  Widget moistureBox(EditProgramLoaded state){
    return CustomCard(
        child: Column(
          children: [
            CardHeader(
                title: 'Select Moisture Sensor',
                onPressed: (){
                  setState(() {
                    showMoisture = !showMoisture;
                  });
                }, open: showMoisture,
            ),
            WrapOrRow(
                open: showMoisture,
              listOfWidget: List.generate(state.editProgramEntity.mappedMoistureSensors.length, (index){
                bool isSelected = state.editProgramEntity.zones[selectedZone].moistureSensors.any((e) => e.serialNo == state.editProgramEntity.mappedMoistureSensors[index].serialNo);
                return _chipWidget(
                    context: context,
                    title: 'Moisture Sensor ${index+1}',
                    selected: isSelected,
                    color: Theme.of(context).colorScheme.secondary,
                    textColor:Colors.black,
                    index: index,
                    onTap: () {
                      if(!isSelected){
                        if(state.editProgramEntity.zones[selectedZone].moistureSensors.length < 2){
                          context.read<EditProgramBloc>().add(AddOrRemoveMoistureToZoneEvent(zoneIndex: selectedZone, nodeIndex: index, addRemoveEnum: AddRemoveEnum.add));
                        }else{
                          showErrorAlert(context: context, message: '2 moisture able to selected per zone');
                        }
                      }else{
                        context.read<EditProgramBloc>().add(AddOrRemoveMoistureToZoneEvent(zoneIndex: selectedZone, nodeIndex: index, addRemoveEnum: AddRemoveEnum.remove));
                      }

                    }
                );
              }),
            )
          ],
        )
    );
  }

  Widget levelBox(EditProgramLoaded state){
    return CustomCard(
        child: Column(
          children: [
            CardHeader(
              title: 'Select Level Sensor',
              onPressed: (){
                setState(() {
                  showLevel = !showLevel;
                });
              }, open: showLevel,
            ),
            WrapOrRow(
              open: showLevel,
              listOfWidget: List.generate(state.editProgramEntity.mappedLevelSensors.length, (index){
                bool isSelected = state.editProgramEntity.zones[selectedZone].levelSensors.any((e) => e.serialNo == state.editProgramEntity.mappedLevelSensors[index].serialNo);

                return _chipWidget(
                    context: context,
                    title: 'Level Sensor ${index+1}',
                    selected:  isSelected,
                    color: Theme.of(context).colorScheme.secondary,
                    textColor:Colors.black,
                    index: index,
                    onTap: () {
                      if(!isSelected){
                        if(state.editProgramEntity.zones[selectedZone].levelSensors.length < 2){
                          context.read<EditProgramBloc>().add(AddOrRemoveLevelToZoneEvent(zoneIndex: selectedZone, nodeIndex: index, addRemoveEnum: AddRemoveEnum.add));
                        }else{
                          showErrorAlert(context: context, message: '2 level able to selected per zone');
                        }
                      }else{
                        context.read<EditProgramBloc>().add(AddOrRemoveLevelToZoneEvent(zoneIndex: selectedZone, nodeIndex: index, addRemoveEnum: AddRemoveEnum.remove));
                      }
                    }
                );
              }),
            )
          ],
        )
    );
  }

  Widget adjustPercentBox({required EditProgramLoaded state}){
    return CustomCard(
      child: Column(
        spacing: 10,
        children: [
          CardHeader(
              title: 'Adjust Percentage',
              onPressed: (){
                setState(() {
                  showAdjustPercent = !showAdjustPercent;
                });
              }, open: showAdjustPercent,
          ),
          if(showAdjustPercent)
            ...[
              adjustPercentWidget(
                  context: context,
                  title: 'Timer',
                  value: state.editProgramEntity.timerAdjustPercent,
                  imageName: 'timer_icon',
                  onChanged: (double value) {
                    context.read<EditProgramBloc>().add(UpdateTimerAdjustPercent(value));
                  }
              ),
              adjustPercentWidget(
                  context: context,
                  title: 'Flow',
                  value: state.editProgramEntity.flowAdjustPercent,
                  imageName: 'flow_icon',
                  onChanged: (double value) {
                    context.read<EditProgramBloc>().add(UpdateFlowAdjustPercent(value));
                  }
              ),
              adjustPercentWidget(
                  context: context,
                  title: 'Moisture',
                  value: state.editProgramEntity.moistureAdjustPercent,
                  imageName: 'moisture_icon',
                  onChanged: (double value) {
                    context.read<EditProgramBloc>().add(UpdateMoistureAdjustPercent(value));
                  }
              ),
              adjustPercentWidget(
                  context: context,
                  title: 'Fertilizer',
                  value: state.editProgramEntity.fertilizerAdjustPercent,
                  imageName: 'fertilizer_icon',
                  onChanged: (double value) {
                    context.read<EditProgramBloc>().add(UpdateFertilizerAdjustPercent(value));
                  }
              ),
            ]

        ],
      ),
    );
  }

  Widget headerText(String title){
    return Text(
        title ,
        maxLines: 2,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 16, fontWeight: FontWeight.bold,)
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String iconName,
    required void Function()? onTap
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Image.asset(
            'assets/images/icons/$iconName.png',
          width: 16,
        ),
      ),
    );
  }

  Widget _chipWidget({
    required BuildContext context,
    required String title,
    required int index,
    required bool selected,
    required void Function()? onTap,
    Color? color,
    Color? textColor,
  }){
    return GestureDetector(
      onTap: onTap,
      child: IntrinsicWidth(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
              color: selected ? (color ?? Theme.of(context).colorScheme.primary) : null,
              borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xffCDCDCD))
          ),
          child: Center(
            child: Text(title, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: selected ? (textColor ?? Colors.white) : Colors.black),),
          ),
        ),
      ),
    );
  }

  Widget adjustPercentWidget({
    required BuildContext context,
    required String title,
    required double value,
    required String imageName,
    required void Function(double)? onChanged
  }){
    return SharpRadiusCard(
      child: Row(
        spacing: 10,
        children: [
          Image.asset(
              width: 20,
              'assets/images/icons/$imageName.png'
          ),
          SizedBox(
              width: 80,
              child: Text(title, style: Theme.of(context).textTheme.labelLarge,)
          ),
          Expanded(
            child: Slider(
              padding: EdgeInsets.symmetric(vertical: 0),
              value: value,
              min: 0,
              max: 100,
              // divisions: 20, // Makes it discrete (steps of 10)
              label: value.round().toString(), // Shows on thumb when dragging
              activeColor: Color(0xff2681D3),
              inactiveColor: Color(0xffD9D9D9),
              onChanged: onChanged,
            ),
          ),
          SizedBox(width: 10,),
          Container(
            width: 60,
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
                border: Border.all(color: Theme.of(context).colorScheme.outline)
            ),
            child: Center(child: Text('${value.round()} %', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.black),)),
          )
        ],
      ),
    );
  }
}
