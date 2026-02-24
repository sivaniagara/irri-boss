import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/alert_dialog.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/app_alerts.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_switch.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/presentation/cubit/controller_context_cubit.dart';
import '../../../../core/di/injection.dart' as di;
import '../../../../core/services/mqtt/mqtt_manager.dart';
import '../../../../core/services/mqtt/publish_messages.dart';
import '../../../../core/utils/app_images.dart';
import '../../../edit_program/utils/edit_program_routes.dart';
import '../../domain/entities/controller_entity.dart';
import '../../domain/entities/livemessage_entity.dart';
import '../../utils/dashboard_routes.dart';
import '../cubit/dashboard_page_cubit.dart';
import '../widgets/static_progress_circle_with_image.dart';
import 'package:intl/intl.dart';

class Dashboard20 extends StatefulWidget {
  const Dashboard20({super.key});

  @override
  State<Dashboard20> createState() => _Dashboard20State();
}

class _Dashboard20State extends State<Dashboard20> {

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardPageCubit, DashboardState>(
        builder: (context, state){
          if(state is! DashboardGroupsLoaded) return Placeholder();
          ControllerEntity controllerEntity = state.groupControllers[state.selectedGroupId]![state.selectedControllerIndex!];
          LiveMessageEntity liveMessageEntity = state.groupControllers[state.selectedGroupId]![state.selectedControllerIndex!].liveMessage;
          return RefreshIndicator(
            onRefresh: () async {
              context.read<DashboardPageCubit>().getLive(controllerEntity.deviceId);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(), // important
              child: Column(
                spacing: 10,
                children: [
                  const SizedBox(height: 20),
                  if ([11, 27].contains(controllerEntity.modelId))
                    ...pumpDashboard(
                      controllerEntity: controllerEntity,
                      liveMessageEntity: liveMessageEntity,
                    )
                  else
                    ...dripDashboard(
                      controllerEntity: controllerEntity,
                      liveMessageEntity: liveMessageEntity,
                    ),
                ],
              ),
            ),
          );
        },
        listener: (context, state){
          print('listening state :: ${state}');
          if(state is DashboardGroupsLoaded && state.changeFromStatus == ChangeFromStatus.loading){
            showGradientLoadingDialog(context);
          }else if(state is DashboardGroupsLoaded && state.changeFromStatus == ChangeFromStatus.success){
            context.pop();
            showSuccessAlert(
                context: context,
                message: 'Change From command Success'
            );
          }else if(state is DashboardGroupsLoaded && state.changeFromStatus == ChangeFromStatus.failure){
            context.pop();
            showErrorAlert(
                context: context,
                message: state.errorMsg
            );
          }
        });
  }

  Widget mountainWidget(LiveMessageEntity liveMessageEntity){
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: -10,
            right: -10,
            child: Image.asset(
              height: 80,
              AppImages.mountain,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              spacing: 20,
              children: [
                Row(
                  spacing: 5,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.signal_cellular_alt, color: Colors.green),
                        Text(
                          'Good Signal',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.battery_6_bar_rounded, color: Colors.green),
                        Text(
                          'Battery ${liveMessageEntity.batVolt}% | ${getDate(liveMessageEntity.cd)}',
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w400),
                        ),
                      ],
                    )
                  ],
                ),
                Row(
                  spacing: 5,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.circle, color: Colors.green),
                        Text(
                          'Live Sync At : ${liveMessageEntity.cd}, ${liveMessageEntity.ct}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.cloudy_snowing, color: Theme.of(context).colorScheme.primary),
                        Text(
                          overflow: TextOverflow.ellipsis,
                          "25\u00B0 C, Windy",
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> pumpDashboard({required ControllerEntity controllerEntity, required LiveMessageEntity liveMessageEntity}){
    return [
      mountainWidget(liveMessageEntity),
      voltageAndCurrent(controllerEntity: controllerEntity, liveMessageEntity: liveMessageEntity),
      if(controllerEntity.modelId == 27)
        doublePumpWidget(controllerEntity: controllerEntity, liveMessageEntity: liveMessageEntity),
      if([11, 27].contains(controllerEntity.modelId))
        dashboardCard(
          child: Column(
            spacing: 20,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              iconWithHeader(
                title: 'Latest Message',
                iconBackgroundColor: const Color(0xffB4E7FF),
                iconColor: Theme.of(context).colorScheme.primary,
                icon: Icon(Icons.message, color: Theme.of(context).colorScheme.primary),
              ),
              Text(controllerEntity.msgDesc, style: TextStyle(fontSize: 16, color: Color(0xff424242),),),
              Text(controllerEntity.ctrlLatestMsg, style: TextStyle(fontSize: 16, color: Color(0xff424242),),)
            ],
          ),
        ),
      SizedBox(height: 100,)
    ];
  }

  Widget voltageAndCurrent({required ControllerEntity controllerEntity, required LiveMessageEntity liveMessageEntity}){
    return dashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: [
          Row(
            spacing: 10,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Color(0xffFFF5DC),
                ),
                child: Center(
                  child: Image.asset(
                    AppImages.currentIcon,
                    width: 25,
                    height: 25,
                  ),
                ),
              ),
              Text('Current', style: Theme.of(context).textTheme.labelLarge),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: Color(0xffE1EEEE)
                ),
                child: Text('Current : C1 ${liveMessageEntity.rCurrent}A , C2 ${liveMessageEntity.yCurrent}A , C3 ${liveMessageEntity.bCurrent}A', style: Theme.of(context).textTheme.bodySmall,),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              rybWidget(backgroundColor: Color(0xffE21E11), value: liveMessageEntity.rVoltage, phase: 'R Phase'),
              rybWidget(backgroundColor: Color(0xffFEC106), value: liveMessageEntity.yVoltage, phase: 'Y Phase'),
              rybWidget(backgroundColor: Color(0xff6C8DB7), value: liveMessageEntity.bVoltage, phase: 'B Phase'),
            ],
          )
        ],
      ),
    );
  }

  List<Widget> dripDashboard({required ControllerEntity controllerEntity, required LiveMessageEntity liveMessageEntity}){
    return [
      mountainWidget(liveMessageEntity),
      voltageAndCurrent(controllerEntity: controllerEntity, liveMessageEntity: liveMessageEntity),
      dashboardCard(
        child: Column(
          spacing: 20,
          children: [
            Row(
              spacing: 10,
              children: [
                Image.asset(
                  'assets/images/common/motor_${liveMessageEntity.motorOnOff == '1' ? 'g' : 'r'}.png',
                  width: 50,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 5,
                  children: [
                    Row(
                      spacing: 10,
                      children: [
                        Text(
                          'Motor',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(width: 2, color: liveMessageEntity.motorOnOff == '1' ? Colors.green : Colors.red),
                          ),
                          child: Image.asset(
                            'assets/images/icons/switch_${liveMessageEntity.motorOnOff == '1' ? 'on' : 'off'}_icon.png',
                            width: 20,
                          ),
                        )
                      ],
                    ),
                    Text(liveMessageEntity.modeOfOperation, style: Theme.of(context).textTheme.bodySmall)
                  ],
                ),
                const Spacer(),
                Row(
                  spacing: 10,
                  children: [
                    Image.asset(
                      'assets/images/icons/pressure_gauge_icon.png',
                      width: 30,
                    ),
                    Column(
                      spacing: 5,
                      children: [
                        Text('Pressure', style: Theme.of(context).textTheme.labelLarge),
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: "In: ",
                                style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: '${liveMessageEntity.prsIn}   ',
                                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                              ),
                              const TextSpan(
                                text: "Out: ",
                                style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: liveMessageEntity.prsOut,
                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                scheduleTimeCard(
                  title: 'Set Time',
                  value: liveMessageEntity.zoneDuration,
                  titleColor: const Color(0xff2E712A),
                  backgroundColor: const Color(0xff689F39),
                ),
                scheduleTimeCard(
                  title: 'Time Left',
                  value: liveMessageEntity.zoneRemainingTime,
                  titleColor: const Color(0xff347CA6),
                  backgroundColor: const Color(0xff52AED7),
                ),
                GestureDetector(
                  onTap: () {
                    final controllerContext = context.read<ControllerContextCubit>().state as ControllerContextLoaded;
                    context.push(
                        DashBoardRoutes.nodeStatus,
                        extra: {
                          "userId": controllerContext.userId,
                          "controllerId": controllerContext.controllerId,
                          "subuserId": controllerContext.subUserId,
                          "deviceId": controllerContext.deviceId,
                        }
                    );
                  },
                  child: Image.asset(
                    'assets/images/common/valve_with_flow.png',
                    width: 70,
                  ),
                )
              ],
            )
          ],
        ),
      ),
      dashboardCard(
        child: Column(
          spacing: 20,
          children: [
            Row(
              children: [
                iconWithHeader(
                  title: 'Program',
                  subTitle: '12:31 PM',
                  iconBackgroundColor: const Color(0xffB1E4AA),
                  iconColor: Theme.of(context).colorScheme.primary,
                  icon: Image.asset(
                    'assets/images/icons/program_icon.png',
                    width: 20,
                  ),
                ),
                const Spacer(),
                PopupMenuButton(
                  onSelected: (value){
                    final controllerContext = context.read<ControllerContextCubit>().state as ControllerContextLoaded;
                    String payload = 'CHANGEFROM$value';
                    context.read<DashboardPageCubit>().updateChangeFrom(
                        userId: controllerContext.userId,
                        controllerId: controllerContext.controllerId,
                        programId: liveMessageEntity.programName.split('program')[1],
                        deviceId: controllerContext.deviceId,
                        payload: payload
                    );

                  },
                  itemBuilder: (context){
                    return getZoneNumberOfActiveProgram(
                        controllerEntity: controllerEntity,
                        liveMessageEntity: liveMessageEntity
                    ).map((e){
                      return PopupMenuItem<String>(
                        value: e,
                        child: Text('Block $e'),
                      );
                    }).toList();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xff0F8AD0)),
                      color: const Color(0xffE6F7FF),
                    ),
                    child: Row(
                      children: [
                        Text('Block ${liveMessageEntity.zoneNo}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black)),
                        Icon(Icons.keyboard_arrow_down, color: Colors.black)
                      ],
                    ),
                  ),
                )
              ],
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 25,
                children: [
                  ...List.generate(4, (index) {
                    bool programAvailable = controllerEntity.programList.length   >= (index+1);
                    bool programStatus = liveMessageEntity.programName == 'program${index+1}';
                    return GestureDetector(
                      onTap: (){
                        context.push('${EditProgramRoutes.program}?programId=${index+1}');
                      },
                      child: Column(
                        spacing: 10,
                        children: [
                          StaticProgressCircleWithImage(
                            progress: 0.68,
                            size: 70,
                            progressColor: programAvailable ? Theme.of(context).colorScheme.primary : Colors.grey,
                            backgroundColor: Colors.grey.shade300,
                            strokeWidth: 5,
                            edgeIcon: Icons.bolt,
                            iconColor: programAvailable ? Theme.of(context).colorScheme.primary : Colors.grey,
                            iconSize: 15,
                            centerWidget: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset('assets/images/common/sprinkler.png'),
                            ),
                          ),
                          Text(
                            'Program ${index + 1}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          CustomSwitch(
                            value: programStatus,
                            onChanged: (value){
                              context.push(DashBoardRoutes.programCommonSettings
                                  .replaceAll(':settingName', 'Program Common Settings')
                                  .replaceAll(':settingNo', '518'));
                            },
                            disable: !programAvailable,
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
      dashboardCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20,
          children: [
            iconWithHeader(
              title: 'Water Level',
              iconBackgroundColor: const Color(0xffB4E7FF),
              iconColor: Theme.of(context).colorScheme.primary,
              icon: Icon(Icons.cloudy_snowing, color: Theme.of(context).colorScheme.primary),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  'assets/images/common/water_level.png',
                  width: 80,
                ),
                moonCard(
                  moonColor: const Color(0xffD4EAFF),
                  skyColor: const Color(0xffE6F7FF),
                  title: 'Max Level',
                  value: '${liveMessageEntity.wellLevel} Feet',
                ),
                moonCard(
                  moonColor: const Color(0xffD4EAFF),
                  skyColor: const Color(0xffE6F7FF),
                  title: 'Current Level',
                  value: '${liveMessageEntity.wellPercent}%',
                ),
              ],
            )
          ],
        ),
      ),
      SizedBox(height: 100)
    ];
  }

  List<String> getZoneNumberOfActiveProgram({required ControllerEntity controllerEntity, required LiveMessageEntity liveMessageEntity}){
    List<String> zoneNumbers = [];
    for(var program = 0;program < controllerEntity.programList.length;program++){
      if(liveMessageEntity.programName == 'program${program+1}'){
        zoneNumbers = controllerEntity.programList[program].listOfZone.map((e) => e.zoneNumber).toList();
      }
    }
   return zoneNumbers;
  }

  String getDate(String date){
    try{
      return DateFormat("d/MMM/yyyy").format(DateTime(int.parse(date.split('/')[2]), int.parse(date.split('/')[1]), int.parse(date.split('/')[0]))).toUpperCase();
    }catch(e){
      if (kDebugMode) {
        print(e.toString());
      }
      return '---';
    }
  }

  Widget doublePumpWidget({required ControllerEntity controllerEntity, required LiveMessageEntity liveMessageEntity}){
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              spacing: 20,
              children: [
                Row(
                  children: [
                    iconWithHeader(
                      title: 'Motor',
                      iconBackgroundColor: const Color(0xffB1E4AA),
                      iconColor: Theme.of(context).colorScheme.primary,
                      icon: Image.asset(
                        'assets/images/common/motor_icon.png',
                        width: 20,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if(controllerEntity.modelId == 27)
                      ...[
                        Column(
                          spacing: 15,
                          children: [
                            Image.asset(
                              'assets/images/common/motor_g.png',
                              width: 80,
                            ),
                            switches()
                          ],
                        ),
                        Column(
                          spacing: 15,
                          children: [
                            Image.asset(
                              'assets/images/common/motor_r.png',
                              width: 80,
                            ),
                            switches()
                          ],
                        ),
                      ]
                    else
                      ...[
                        Image.asset(
                          'assets/images/common/motor_g.png',
                          width: 80,
                        ),
                        switches()
                      ]

                  ],
                )
              ],
            ),
          ),
          ...stackRadius(),
        ],
      ),
    );
  }

  List<Widget> stackRadius(){
    List<Color> shades = [
      Colors.green.shade400,
      Colors.green.shade600,
      Colors.green.shade800,
    ];
     return  List.generate(3, (index) {
        return Positioned(
          bottom: -50 - ((index + 1) * 5),
          left: -50 - ((index + 1) * 5),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: shades[index],
          ),
        );
      });

  }

  Widget switches() {
    return Row(
      children: [
        Column(
          children: [
            IconButton(
              onPressed: (){

              },
              icon: Icon(Icons.power_settings_new,),
              style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Color(0xff4DB53D))
              ),
            ),
            Text('ON', style: Theme.of(context).textTheme.labelLarge,)
          ],
        ),
        Column(
          children: [
            IconButton(
              onPressed: (){

              },
              icon: Icon(Icons.power_settings_new,),
              style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Color(0xffE9352B))
              ),
            ),
            Text('OFF', style: Theme.of(context).textTheme.labelLarge,)
          ],
        ),
      ],
    );
  }
  
  Widget rybWidget({
    required Color backgroundColor,
    required String value,
    required String phase,
  }){
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: backgroundColor
      ),
      child: Column(
        spacing: 5,
        children: [
          Text('$phase', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),),
          IntrinsicWidth(
            child: Container(
              width: 60,
              height: 0.8,
              color: Colors.white,
            ),
          ),
          Text('$value V', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),),
        ],
      ),
    );
  }

  Widget iconWithHeader({
    required String title,
    String? subTitle,
    required Color iconBackgroundColor,
    required Color iconColor,
    required Widget icon,
  }) {
    return Row(
      spacing: 10,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: iconBackgroundColor,
          ),
          child: icon,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.labelLarge),
            if (subTitle != null) Text(subTitle, style: Theme.of(context).textTheme.bodySmall),
          ],
        )
      ],
    );
  }

  Widget scheduleTimeCard({
    required String title,
    required String value,
    required Color titleColor,
    required Color backgroundColor,
  }) {
    return Container(
      width: 110,
      height: 80,
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(9)),
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(12),
                topLeft: Radius.circular(12),
              ),
              color: titleColor,
            ),
            child: Center(
              child: Text(
                title,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white),
              ),
            ),
          ),
          Center(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          )
        ],
      ),
    );
  }

  Widget moonCard({
    required Color moonColor,
    required Color skyColor,
    required String title,
    required String value,
  }) {
    return Container(
      width: 110,
      height: 80,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: moonColor),
      child: Stack(
        children: [
          Positioned(
            left: -130,
            top: -120,
            child: CircleAvatar(
              radius: 100,
              backgroundColor: skyColor,
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(title, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.black)),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black45),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget dashboardCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(8),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: child,
    );
  }
}