import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/power_reports/utils/Power_routes.dart';

import '../../../../core/utils/app_constants.dart';
import '../../../../core/utils/app_images.dart';
import '../../../fault_msg/utils/faultmsg_routes.dart';
import '../../../pump_settings/utils/pump_settings_page_routes.dart';
import '../../utils/dashboard_routes.dart';
import '../cubit/controller_context_cubit.dart';
import '../pages/dashboard_page.dart';

class PumpBottomNavigationBar extends StatefulWidget {
  final int userId;
  final int userType;
  final int modelId;
  PumpBottomNavigationBar({super.key, required this.userId, required this.userType, required this.modelId});

  @override
  State<PumpBottomNavigationBar> createState() => _PumpBottomNavigationBarState();
}

class _PumpBottomNavigationBarState extends State<PumpBottomNavigationBar> {
  final NotchBottomBarController _controller = NotchBottomBarController(index: 0);

  @override
  Widget build(BuildContext context) {
    bool isDoublePumpLive = AppConstants.isDoublePumpLive(widget.modelId);

    List<BottomBarItem> items = [];
    
    if (isDoublePumpLive) {
      // Double Pump: Pump Setting, Power Graph, Sent & Receive, Sump Setting, Fault MSG
      items = [
        BottomBarItem(
          inActiveItem: Image.asset(AppImages.inActiveSettingIcon),
          activeItem: Image.asset(AppImages.activeSettingIcon),
          itemLabel: 'Pump Setting',
        ),
        BottomBarItem(
          inActiveItem: Image.asset(AppImages.inActiveReportIcon),
          activeItem: Image.asset(AppImages.activeReportIcon),
          itemLabel: 'Power Graph',
        ),
        BottomBarItem(
          inActiveItem: Image.asset(AppImages.inActiveSentIcon),
          activeItem: Image.asset(AppImages.activeSentIcon),
          itemLabel: 'Sent & Receive',
        ),
        BottomBarItem(
          inActiveItem: Image.asset(AppImages.inActiveSettingIcon),
          activeItem: Image.asset(AppImages.activeSettingIcon),
          itemLabel: 'Sump Setting',
        ),
        BottomBarItem(
          inActiveItem: Image.asset(AppImages.activefaultmsgicon),
          activeItem: Image.asset(AppImages.inActivefaultmsgicon),
          itemLabel: 'Fault MSG',
        ),
      ];
    } else {
      // Single Pump: Pump Setting, Power Graph, Sent & Receive, Fault MSG
      items = [
        BottomBarItem(
          inActiveItem: Image.asset(AppImages.inActiveSettingIcon),
          activeItem: Image.asset(AppImages.activeSettingIcon),
          itemLabel: 'Pump Setting',
        ),
        BottomBarItem(
          inActiveItem: Image.asset(AppImages.inActiveReportIcon),
          activeItem: Image.asset(AppImages.activeReportIcon),
          itemLabel: 'Power Graph',
        ),
        BottomBarItem(
          inActiveItem: Image.asset(AppImages.inActiveSentIcon),
          activeItem: Image.asset(AppImages.activeSentIcon),
          itemLabel: 'message',
        ),
        BottomBarItem(
          inActiveItem: Image.asset(AppImages.activefaultmsgicon),
          activeItem: Image.asset(AppImages.inActivefaultmsgicon),
          itemLabel: 'Fault MSG',
        ),
      ];
    }

    return AnimatedNotchBottomBar(
      notchBottomBarController: _controller,
      color: Colors.white,
      showLabel: true,
      textOverflow: TextOverflow.visible,
      maxLine: 1,
      shadowElevation: 5,
      kBottomRadius: 28.0,
      notchColor: Colors.white,
      removeMargins: true,
      showShadow: false,
      durationInMilliSeconds: 300,
      itemLabelStyle: const TextStyle(fontSize: 10, color: Colors.black),
      bottomBarItems: items,
      onTap: (index) {
        final state = context.read<ControllerContextCubit>().state;
        if (state is! ControllerContextLoaded) return;
        final controllerContext = state;
        
        if (isDoublePumpLive) {
          // Double Pump (0: Pump Setting, 1: Power Graph, 2: Sent & Receive, 3: Sump Setting, 4: Fault MSG)
          if(index == 0){
            context.push(PumpSettingsPageRoutes.pumpSettingMenuList, extra: {
              "userId": int.parse(controllerContext.userId),
              "subUserId": int.parse(controllerContext.subUserId),
              "controllerId": int.parse(controllerContext.controllerId),
              "deviceId": controllerContext.deviceId,
              "modelId": widget.modelId,
            });
          } else if(index == 1){
            context.push(PowerGraphPageRoutes.PowerGraphPage, extra: {
              "userId": int.parse(controllerContext.userId),
              "controllerId": int.parse(controllerContext.controllerId),
              "userType": controllerContext.userType,
              "subUserId": int.parse(controllerContext.subUserId),
              "deviceId": controllerContext.deviceId,
            });
          } else if(index == 2){
            context.pushReplacement("${DashBoardRoutes.sentAndReceive}?userId=${widget.userId}&userType=${widget.userType}");
          } else if(index == 3){
            // Sump Setting - IrrigationSettingsEnum.sump.settingId is 523
            context.push(PumpSettingsPageRoutes.pumpSettingsPage, extra: {
              "userId": int.parse(controllerContext.userId),
              "subUserId": int.parse(controllerContext.subUserId),
              "controllerId": int.parse(controllerContext.controllerId),
              "deviceId": controllerContext.deviceId,
              "modelId": widget.modelId,
              "menuId": 523,
              "menuName": "Sump Setting",
            });
          } else if (index == 4) {
            context.push(FaultMsgPageRoutes.FaultMsgMsgPage, extra: {
              "userId": int.parse(controllerContext.userId),
              "subuserId": int.parse(controllerContext.subUserId),
              "controllerId": int.parse(controllerContext.controllerId),
            });
          }
        } else {
          // Single Pump (0: Pump Setting, 1: Power Graph, 2: Sent & Receive, 3: Fault MSG)
          if(index == 0){
            context.push(PumpSettingsPageRoutes.pumpSettingMenuList, extra: {
              "userId": int.parse(controllerContext.userId),
              "subUserId": int.parse(controllerContext.subUserId),
              "controllerId": int.parse(controllerContext.controllerId),
              "deviceId": controllerContext.deviceId,
              "modelId": widget.modelId,
            });
          } else if(index == 1){
            context.push(PowerGraphPageRoutes.PowerGraphPage, extra: {
              "userId": int.parse(controllerContext.userId),
              "controllerId": int.parse(controllerContext.controllerId),
              "userType": controllerContext.userType,
              "subUserId": int.parse(controllerContext.subUserId),
              "deviceId": controllerContext.deviceId,
            });
          } else if(index == 2){
            context.pushReplacement("${DashBoardRoutes.sentAndReceive}?userId=${widget.userId}&userType=${widget.userType}");
          } else if (index == 3) {
            context.push(FaultMsgPageRoutes.FaultMsgMsgPage, extra: {
              "userId": int.parse(controllerContext.userId),
              "subuserId": int.parse(controllerContext.subUserId),
              "controllerId": int.parse(controllerContext.controllerId),
            });
          }
        }
        setState(() {});
      },
      kIconSize: 24.0,
    );
  }
}
