import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_material_button.dart';
import 'package:niagara_smart_drip_irrigation/features/controller_settings/program_list/presentation/widgets/list_tile_card.dart';

import '../../../../../core/widgets/custom_outlined_button.dart';
import '../../../../../core/widgets/gradiant_background.dart';
import '../../../program_list/presentation/cubit/day_selection_cubit.dart';
import '../bloc/edit_zone_bloc.dart';

class EditZone extends StatelessWidget {
  const EditZone({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditZoneBloc, EditZoneState>(
        builder: (context, state){
          if(state is EditZoneLoading){
            return const Center(child: CircularProgressIndicator());
          }
          if (state is EditZoneError) {
            return Center(child: Text(state.message));
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
                          zoneTitle(),
                          Divider(),
                          description(),
                          Divider(),
                          onTimeOffTime(),
                          Divider(),
                          daysSelection(),
                          const SizedBox(height: 10,),
                          ListTileCard(
                            title: 'Valve',
                            onTap: (){

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
    );

  }

  Widget zoneTitle(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text('Zone Name', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),),
        Text('ZONE001', style:  TextStyle(fontSize: 28, fontWeight: FontWeight.w500, color: Colors.black),),
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

  Widget daysSelection(){
    return BlocBuilder<DaySelectionCubit, DaySelectionState>(
        builder: (context, state){
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ...['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'].map((day){
                bool isSelected = state.selectedDays.contains(day);
                return GestureDetector(
                  onTap: (){
                    context.read<DaySelectionCubit>().addAndRemove(day);
                  },
                  child: Container(
                    width: 50,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: isSelected ? Theme.of(context).primaryColor : Colors.white
                    ),
                    child: Center(
                      child: Text(day, style: TextStyle(color: isSelected ? Colors.white : Colors.black),),
                    ),
                  ),
                );
              })
            ],
          );
        }
    );
  }

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

  Widget onTimeOffTime(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        timeWidget('ON TIME', '00:00'),
        timeWidget('OFF TIME', '00:00'),
      ],
    );
  }
}
