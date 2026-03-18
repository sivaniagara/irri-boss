import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/utils/irrigation_settings_routes.dart';

import '../../../../core/utils/app_constants.dart';
import '../../../../core/utils/app_images.dart';
import '../../utils/dashboard_routes.dart';
import '../cubit/controller_context_cubit.dart';
import '../pages/dashboard_page.dart';

class DripBottomNavigationBar extends StatefulWidget {
  final int userId;
  final int userType;
  final int modelId;
  DripBottomNavigationBar({super.key, required this.userId, required this.userType, required this.modelId});

  @override
  State<DripBottomNavigationBar> createState() => _DripBottomNavigationBarState();
}

class _DripBottomNavigationBarState extends State<DripBottomNavigationBar> {
  final NotchBottomBarController _controller = NotchBottomBarController(index: 0);
  BottomNavigationOption selectedBottomNavigation = BottomNavigationOption.home;

  @override
  Widget build(BuildContext context) {
    List<BottomBarItem> items = [
      BottomBarItem(
        inActiveItem: Image.asset(AppImages.inActiveHomeIcon,),
        activeItem: Image.asset(AppImages.activeHomeIcon),
        itemLabel: 'Home',
      ),
      BottomBarItem(
        inActiveItem: Image.asset(AppImages.inActiveReportIcon,),
        activeItem: Image.asset(AppImages.activeReportIcon),
        itemLabel: 'Report',
      ),
      BottomBarItem(
        inActiveItem: Image.asset(AppImages.inActiveManualIcon,),
        activeItem: Image.asset(AppImages.activeManualIcon),
        itemLabel: 'Manual',
      ),
      BottomBarItem(
        inActiveItem: Image.asset(AppImages.inActiveSettingIcon,),
        activeItem: Image.asset(AppImages.activeSettingIcon),
        itemLabel: 'Settings',
      ),
      BottomBarItem(
        inActiveItem: Image.asset(AppImages.inActiveSentIcon,),
        activeItem: Image.asset(AppImages.activeSentIcon),
        itemLabel: 'Message',
      ),
    ];

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

        if(index == 0){
          selectedBottomNavigation = BottomNavigationOption.home;
          context.pushReplacement("${DashBoardRoutes.dashboard}?userId=${widget.userId}&userType=${widget.userType}");
        }else if(index == 1){
          selectedBottomNavigation = BottomNavigationOption.report;
          context.pushReplacement("${DashBoardRoutes.report}?userId=${widget.userId}&userType=${widget.userType}",  extra: {
            "userId": controllerContext.userId,
            "controllerId": controllerContext.controllerId,
            "userType": controllerContext.userType,
            "subUserId": controllerContext.subUserId,
            "deviceId": controllerContext.deviceId,
          });
        }else if(index == 2){
          selectedBottomNavigation = BottomNavigationOption.manual;
          context.pushReplacement(
              "${DashBoardRoutes.standalone}?userId=${widget.userId}&userType=${widget.userType}",
              extra: {
                "userId": controllerContext.userId,
                "controllerId": controllerContext.controllerId,
                "userType": controllerContext.userType,
                "subUserId": controllerContext.subUserId,
                "deviceId": controllerContext.deviceId,
              }
          );
        }else if(index == 3){
          selectedBottomNavigation = BottomNavigationOption.setting;
          context.push(IrrigationSettingsRoutes.irrigationSettings);
        }else if(index == 4){
          selectedBottomNavigation = BottomNavigationOption.sentAndReceive;
          context.pushReplacement("${DashBoardRoutes.sentAndReceive}?userId=${widget.userId}&userType=${widget.userType}");
        }
        setState(() {});
      },
      kIconSize: 24.0,
    );
  }
}
