import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_app_bar.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_material_button.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/gradiant_background.dart';
import 'package:niagara_smart_drip_irrigation/features/water_fertilizer_settings/presentation/enums/zone_set_update_status_enum.dart';

import '../../../../core/widgets/alert_dialog.dart';
import '../../../../core/widgets/app_alerts.dart';
import '../../domain/entities/zone_water_fertilizer_entity.dart';
import '../bloc/water_fertilizer_setting_bloc.dart';


class ListOfZoneInZoneSet extends StatefulWidget {
  const ListOfZoneInZoneSet({super.key});

  @override
  State<ListOfZoneInZoneSet> createState() => _ListOfZoneInZoneSetState();
}

class _ListOfZoneInZoneSetState extends State<ListOfZoneInZoneSet> {
  int irrigationDosingOrPrePostMode = 1;
  int timeOrQuantity = 1;
  int channel = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WaterFertilizerSettingBloc, WaterFertilizerSettingState>(
        builder: (context, state){
          if (state is WaterFertilizerSettingLoading) {
            return const Center(child: CircularProgressIndicator());
          }else if(state is WaterFertilizerSettingLoaded){
            return Scaffold(
              appBar: CustomAppBar(
                  title: 'Zone Set ${state.zoneSetId!}'
              ),
              body: GradiantBackground(
                  child: SingleChildScrollView(
                    child: Column(
                      // spacing: 10,
                      children: [
                        ToggleButtons(
                          isSelected: [irrigationDosingOrPrePostMode == 1, irrigationDosingOrPrePostMode == 2],
                          onPressed: (index) {
                            setState(() {
                              irrigationDosingOrPrePostMode = index + 1;
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          selectedColor: Colors.white,
                          fillColor: Theme.of(context).primaryColor,
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
                        SizedBox(height: 10,),
                        ToggleButtons(
                          isSelected: [timeOrQuantity == 1, timeOrQuantity == 2],
                          onPressed: (index) {
                            setState(() {
                              timeOrQuantity = index + 1;
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          selectedColor: Colors.white,
                          fillColor: Theme.of(context).primaryColor,
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 30),
                              child: Text('Time', style: TextStyle(fontSize: 16)),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 30),
                              child: Text('Flow', style: TextStyle(fontSize: 16)),
                            ),
                          ],
                        ),
                        SizedBox(height: 10,),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColorLight,
                              borderRadius: BorderRadius.circular(8)
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 120,
                                child: Center(child: headerText('Zone')),
                              ),
                              SizedBox(
                                width: 120,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    headerText(irrigationDosingOrPrePostMode == 1 ? 'Water' : 'Pre'),
                                    headerText('(${timeOrQuantity == 1 ? 'Time' : 'Liters'})'),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 120,
                                child: Row(
                                  spacing: 10,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Column(
                                      children: [
                                        headerText(irrigationDosingOrPrePostMode == 1 ? 'Channel' : 'Post'),
                                        headerText('(${timeOrQuantity == 1 ? 'Time' : 'Liters'})'),
                                      ],
                                    ),
                                    if(irrigationDosingOrPrePostMode == 1)
                                      PopupMenuButton(
                                        itemBuilder: (context){
                                          return List.generate(6, (index){
                                            return PopupMenuItem(
                                              child: Text('CH ${index+1}'),
                                              onTap: (){
                                                setState(() {
                                                  channel = index + 1;
                                                });
                                              },
                                            );
                                          });
                                        },
                                        child: Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              color: Theme.of(context).primaryColor
                                          ),
                                          child: Center(
                                            child: Text('CH ${channel}', style: TextStyle(color: Colors.white),),
                                          ),
                                        ),
                                      )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...List.generate(state.programZoneSetEntity.listOfZoneSet.first.listOfZoneWaterFertilizer.length, (index){
                          var zone = state.programZoneSetEntity.listOfZoneSet.first.listOfZoneWaterFertilizer[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.water_drop,
                                          size: 20,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        zone.zoneNumber,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            if(timeOrQuantity == 1)
                                              Expanded(
                                                  child: _timeField(time: irrigationDosingOrPrePostMode == 1 ? zone.time : zone.preTime, zoneNo: index, mode: irrigationDosingOrPrePostMode == 1 ? 1 :2)
                                              )
                                            else
                                              Expanded(
                                                child: _zoneInputField(
                                                    context,
                                                    label: "Time (min)",
                                                    icon: Icons.timer_outlined,
                                                    value: irrigationDosingOrPrePostMode == 1 ? zone.liters : zone.preLiters,
                                                    keyValue: '${zone.zoneNumber} - ${irrigationDosingOrPrePostMode == 1 ? 'water' : 'pre'}',
                                                    zoneNo: index,
                                                    channelIndex: channel,
                                                    mode: irrigationDosingOrPrePostMode == 1 ? 1 : 2
                                                ),
                                              ),
                                            const SizedBox(width: 12),
                                            if(timeOrQuantity == 1)
                                              Expanded(
                                                  child: _timeField(time: irrigationDosingOrPrePostMode == 1 ? getChannelTime(zone) : zone.postTime, zoneNo: index, mode: irrigationDosingOrPrePostMode == 1 ? 3 : 4)
                                              )
                                            else
                                              Expanded(
                                                child: _zoneInputField(
                                                    context,
                                                    label: "Liters",
                                                    icon: Icons.opacity,
                                                    value: irrigationDosingOrPrePostMode == 1 ? getChannelLiters(zone) : zone.postLiters,
                                                    keyValue: '${zone.zoneNumber} - ${irrigationDosingOrPrePostMode == 1 ? 'channel()' : 'post'}',
                                                    zoneNo: index,
                                                    channelIndex: channel,
                                                    mode: irrigationDosingOrPrePostMode == 1 ? 3 : 4
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        SizedBox(height: 20,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(width: 100,),
                            CustomMaterialButton(
                                onPressed: (){
                                  context.read<WaterFertilizerSettingBloc>().add(
                                      UpdateZoneSetSettingEvent(
                                          channelNo: channel,
                                          irrigationDosingOrPrePost: irrigationDosingOrPrePostMode,
                                          mode: irrigationDosingOrPrePostMode == 1 ? 1 : 2,
                                          method: timeOrQuantity
                                      )
                                  );
                                },
                                title: 'Send'
                            ),
                            CustomMaterialButton(
                                onPressed: (){
                                  context.read<WaterFertilizerSettingBloc>().add(
                                      UpdateZoneSetSettingEvent(
                                          channelNo: channel,
                                          irrigationDosingOrPrePost: irrigationDosingOrPrePostMode,
                                          mode: irrigationDosingOrPrePostMode == 1 ? 3 : 4,
                                          method: timeOrQuantity
                                      )
                                  );
                                },
                                title: 'Send'
                            ),
                          ],
                        )
                      ],
                    ),
                  )
              ),
            );
          }else{
            return Placeholder();
          }
        },
        listener: (context, state){
          if(state is WaterFertilizerSettingLoaded && state.zoneSetUpdateStatusEnum == ZoneSetUpdateStatusEnum.loading){
            showGradientLoadingDialog(context);
          }else if(state is WaterFertilizerSettingLoaded && state.zoneSetUpdateStatusEnum == ZoneSetUpdateStatusEnum.failure){
            context.pop();
            showErrorAlert(context: context, message: state.zoneSetUpdateStatusEnum.message);
          }else if(state is WaterFertilizerSettingLoaded && state.zoneSetUpdateStatusEnum == ZoneSetUpdateStatusEnum.success){
            context.pop();
            showSuccessAlert(
                context: context,
                message: state.zoneSetUpdateStatusEnum.message,
                onPressed: (){
                  context.pop();
                }
            );
          }
        }
    );
  }

  Widget headerText(String title){
    return Text(title , style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold));
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
        context.read<WaterFertilizerSettingBloc>().add(
            UpdateTotalTime(
                zoneNo: zoneNo,
                time: formattedTime
            ));
      }else if(irrigationDosingOrPrePostMode == 2 && timeOrQuantity == 1 && mode == 2){
        context.read<WaterFertilizerSettingBloc>().add(
            UpdatePreTime(
                zoneNo: zoneNo,
                time: formattedTime,
            ));
      }else if(irrigationDosingOrPrePostMode == 1 && timeOrQuantity == 1 && mode == 3){
        context.read<WaterFertilizerSettingBloc>().add(
            UpdateChannelTime(
                zoneNo: zoneNo,
                time: formattedTime,
                channelIndex: channel
            ));
      }else{
        context.read<WaterFertilizerSettingBloc>().add(
            UpdatePostTime(
              zoneNo: zoneNo,
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

  Widget _timeField({
    required String time,
    required int zoneNo,
    required int mode,
  }){
    return GestureDetector(
      onTap: () => pickTime(context, zoneNo, mode),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), topRight: Radius.circular(15)),
            border: Border.all(width: 1)
        ),
        child: Center(
            child: Text(time)
        ),
      ),
    );
  }

  Widget _zoneInputField(
      BuildContext context, {
        required String label,
        required IconData icon,
        required String value,
        required String keyValue,
        required int zoneNo,
        required int channelIndex,
        required int mode,
      }) {
    return TextFormField(
      key: UniqueKey(),
      initialValue: value,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        // prefixIcon: Icon(icon, size: 18),
        // labelText: label,
        filled: true,
        // labelStyle: TextStyle(color: Colors.black),
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
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
      onFieldSubmitted: (updatedValue){
        if(irrigationDosingOrPrePostMode == 1 && timeOrQuantity == 2 && mode == 1){
          context.read<WaterFertilizerSettingBloc>().add(
              UpdateTotalLiters(
                  zoneNo: zoneNo,
                  liters: updatedValue
              )
          );
        }else if(irrigationDosingOrPrePostMode == 2 && timeOrQuantity == 2 && mode == 2){
          context.read<WaterFertilizerSettingBloc>().add(
              UpdatePreLiters(
                  zoneNo: zoneNo,
                  liters: updatedValue
              )
          );
        }else if(irrigationDosingOrPrePostMode == 1 && timeOrQuantity == 2 && mode == 3){
          context.read<WaterFertilizerSettingBloc>().add(
              UpdateChannelLiters(
                  zoneNo: zoneNo,
                  channelIndex: channelIndex,
                  liters: updatedValue
              )
          );
        }else{
          context.read<WaterFertilizerSettingBloc>().add(
              UpdatePostLiters(
                  zoneNo: zoneNo,
                  liters: updatedValue
              )
          );
        }
      },
      onChanged: (value){

      },
    );
  }

  String getChannelTime(ZoneWaterFertilizerEntity zone){
    if(channel == 1){
      return zone.ch1Time;
    }else if(channel == 2){
      return zone.ch2Time;
    }else if(channel == 3){
      return zone.ch3Time;
    }else if(channel == 4){
      return zone.ch4Time;
    }else if(channel == 5){
      return zone.ch5Time;
    }else{
      return zone.ch6Time;
    }
  }

  String getChannelLiters(ZoneWaterFertilizerEntity zone){
    if(channel == 1){
      return zone.ch1Liters;
    }else if(channel == 2){
      return zone.ch2Liters;
    }else if(channel == 3){
      return zone.ch3Liters;
    }else if(channel == 4){
      return zone.ch4Liters;
    }else if(channel == 5){
      return zone.ch5Liters;
    }else{
      return zone.ch6Liters;
    }
  }

}







