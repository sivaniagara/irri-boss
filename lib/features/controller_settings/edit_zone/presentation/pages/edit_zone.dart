import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/alert_dialog.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_material_button.dart';
import 'package:niagara_smart_drip_irrigation/features/controller_settings/edit_zone/domain/entities/node_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/controller_settings/edit_zone/presentation/widgets/selectable_valve_list.dart';
import 'package:niagara_smart_drip_irrigation/features/controller_settings/program_list/presentation/bloc/program_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/controller_settings/program_list/presentation/widgets/list_tile_card.dart';
import 'package:niagara_smart_drip_irrigation/features/controller_settings/utils/controller_settings_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/utils/dashboard_routes.dart';

import '../../../../../core/widgets/app_alerts.dart';
import '../../../../../core/widgets/custom_outlined_button.dart';
import '../../../../../core/widgets/gradiant_background.dart';
import '../bloc/edit_zone_bloc.dart';

enum NodeEntityMode{valve, moistureSensor, levelSensor}

enum ZoneSubmissionStatus {
  idle,
  loading,
  success,
  failure,
}


class EditZonePage extends StatelessWidget {
  const EditZonePage({super.key});


  void showZoneBottomSheet(BuildContext context, List<NodeEntity> listOfNodeEntity) {
    final editZoneBloc = context.read<EditZoneBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return BlocProvider.value(
          value: editZoneBloc,
          child: SelectableNodeList(nodeEntityMode: NodeEntityMode.valve,),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return BlocListener<EditZoneBloc, EditZoneState>(
        listener: (context, state){
          if(state is EditZoneLoaded && state.submissionStatus == ZoneSubmissionStatus.loading){
            showGradientLoadingDialog(context);
          }else if(state is EditZoneLoaded && state.submissionStatus == ZoneSubmissionStatus.failure){
            context.pop();
            showErrorAlert(context: context, message: state.message!);
          }else if(state is EditZoneLoaded && state.submissionStatus == ZoneSubmissionStatus.success){
            context.pop();
            showSuccessAlert(
                context: context,
                message: state.message!,
                onPressed: (){
                  context.pop();
                  context.pop();
                  context.read<ProgramBloc>().add(FetchPrograms(userId: state.userId, controllerId: state.controllerId));
                }
            );
          }
        },
      child: BlocBuilder<EditZoneBloc, EditZoneState>(
          builder: (context, state){
            if(state is EditZoneLoading){
              return const Center(child: CircularProgressIndicator());
            }
            if (state is EditZoneError) {
              return Material(child: Center(child: Text(state.message, style: TextStyle(color: Colors.black),)));
            }
            if(state is EditZoneLoaded){
              return Scaffold(
                appBar: AppBar(
                  title: const Text('EDIT / REST ZONE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                  centerTitle: true,
                  backgroundColor: const Color(0xffC6DDFF),
                ),
                body: GradiantBackground(
                  child: Column(
                    children: [
                      Expanded(
                        child: Column(
                          spacing: 10,
                          children: [
                            zoneTitle(state),
                            Divider(),
                            description(),
                            Divider(),
                            // onTimeOffTime(state),
                            // Divider(),
                            // daysSelection(),
                            const SizedBox(height: 10,),
                            ListTileCard(
                              title: 'Valve',
                              onTap: (){
                                List<NodeEntity> listOfValveNodes = state.zoneNodes.valves;
                                showZoneBottomSheet(context, listOfValveNodes);
                              },
                            ),
                            ListTileCard(
                              title: 'Moisture Sensor',
                              onTap: (){

                              },
                            ),
                            ListTileCard(
                              title: 'Level Sensor',
                              onTap: (){

                              },
                            ),

                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.105,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CustomOutlinedButton(
                                title: 'Cancel',
                                onPressed: (){
                                  context.pop();
                                }
                            ),
                            CustomOutlinedButton(
                                onPressed: (){

                                },
                                title: 'Rest Zone'
                            ),
                            CustomMaterialButton(
                                onPressed: (){
                                  context.read<EditZoneBloc>().add(SubmitZone());
                                },
                                title: 'Submit'
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            }
            return SizedBox();

          }
      )
    );

  }

  Widget zoneTitle(EditZoneState state){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text('Zone Name', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),),
        Text((state as EditZoneLoaded).zoneNodes.zoneNumber, style:  TextStyle(fontSize: 28, fontWeight: FontWeight.w500, color: Colors.black),),
      ],
    );
  }

  Widget description(){
    return Row(
      spacing: 10,
      children: [
        Icon(Icons.warning_amber, color: Colors.black,),
        Expanded(
          child: Text(
            'Please Select The Required Node(s) And Tap APPLY Button In Each Category',
            style:  TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xff414141)),
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  // Widget daysSelection(){
  //   return BlocBuilder<DaySelectionCubit, DaySelectionState>(
  //       builder: (context, state){
  //         return Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //           children: [
  //             ...['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'].map((day){
  //               bool isSelected = state.selectedDays.contains(day);
  //               return GestureDetector(
  //                 onTap: (){
  //                   context.read<DaySelectionCubit>().addAndRemove(day);
  //                 },
  //                 child: Container(
  //                   width: 50,
  //                   padding: EdgeInsets.symmetric(vertical: 20),
  //                   decoration: BoxDecoration(
  //                       borderRadius: BorderRadius.circular(20),
  //                       color: isSelected ? Theme.of(context).primaryColor : Colors.white
  //                   ),
  //                   child: Center(
  //                     child: Text(day, style: TextStyle(color: isSelected ? Colors.white : Colors.black),),
  //                   ),
  //                 ),
  //               );
  //             })
  //           ],
  //         );
  //       }
  //   );
  // }

  Widget timeWidget(String title, String value){
    return Row(
      spacing: 20,
      children: [
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black)),
        GestureDetector(
          onTap: (){

          },
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                color: Colors.white
            ),
            child: Center(
              child: Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),),
            ),
          ),
        ),
      ],
    );
  }

  Widget onTimeOffTime(EditZoneState state){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        timeWidget('ON TIME', '00:00'),
        timeWidget('OFF TIME', '00:00'),
      ],
    );
  }
}
