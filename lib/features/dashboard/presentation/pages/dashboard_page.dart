import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/services/mqtt/mqtt_manager.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_app_bar.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glass_effect.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glassy_wrapper.dart';
import 'package:niagara_smart_drip_irrigation/features/auth/auth.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/presentation/cubit/controller_context_cubit.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/presentation/cubit/dashboard_page_cubit.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/di/injection.dart' as di;
import '../../../../core/services/mqtt/publish_messages.dart';
import '../../../../core/theme/app_themes.dart';
import '../../../../core/utils/app_images.dart';
import '../../../controller_details/domain/usecase/controller_details_params.dart';
import '../../../program_settings/utils/program_settings_routes.dart';
import '../../../side_drawer/groups/presentation/widgets/app_drawer.dart';
import '../../utils/dashboard_routes.dart';
import '../helper/get_sms_sync.dart';
import '../widgets/actions_section.dart';
import '../widgets/ctrl_display.dart';
import '../widgets/latestmsg_section.dart';
import '../widgets/motor_valve_section.dart';
import '../widgets/pressure_section.dart';
import '../widgets/ryb_section.dart';
import '../widgets/sync_section.dart';
import '../widgets/timer_section.dart';
import '../../dashboard.dart';
import 'dashboard_2_0.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';


enum BottomNavigationOption{home, report, setting, sentAndReceive ,Manual}

extension BottomNavivigationOptionExtension on BottomNavigationOption{
  String title(){
    switch (this){
      case BottomNavigationOption.home:
        return 'Home';
      case BottomNavigationOption.report:
        return 'Report';
      case BottomNavigationOption.setting:
        return 'Setting';
      case BottomNavigationOption.sentAndReceive:
        return 'Sent And Receive';
      case BottomNavigationOption.Manual:
        return 'Manual';
    }
  }
}

class DashboardPage extends StatefulWidget {
  final Widget? child;
  final Map<String, dynamic> userData;
  const DashboardPage({super.key, this.child, required this.userData});

  @override
  State<DashboardPage> createState() => _DashboardPageState();

  static Future<void> _refreshLiveData(ControllerEntity controller) async {
    final mqttManager = di.sl.get<MqttManager>();
    final deviceId = controller.deviceId;
    final publishMessage = jsonEncode(PublishMessageHelper.requestLive);
    mqttManager.publish(deviceId, publishMessage);

    if (kDebugMode) {
      print("Live message requested for device: $deviceId");
    }
  }
}

const int fakeGroupId = 0;

class _DashboardPageState extends State<DashboardPage> {
  BottomNavigationOption selectedBottomNavigation = BottomNavigationOption.home;
  final NotchBottomBarController _controller = NotchBottomBarController(index: 0);

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final queryParams = GoRouterState.of(context).uri.queryParameters;
    late int userId;
    late int userType;
    if (queryParams.containsKey('userId') && queryParams['userId'] != null) {
      userId = int.parse(queryParams['userId']!);
      userType = int.parse(queryParams['userType']!);
    } else {
      userId = int.parse(widget.userData['userId']!);
      userType = int.parse(widget.userData['userType']!);
    }

    final groupId = queryParams['groupId'];

    if (userId <= 0) {
      return const Center(child: Text('Invalid user session. Please log in again.'));
    }

    return BlocProvider(
      create: (_) => sl<DashboardPageCubit>(),
      child: Builder(
        builder: (context) {
          final cubit = context.read<DashboardPageCubit>();

          _initializeCubit(cubit, context, userId, userType, groupId);

          return BlocBuilder<DashboardPageCubit, DashboardState>(
            builder: (context, state) =>
                _buildContent(context, state, userId, userType, cubit),
          );
        },
      ),
    );
  }

  void _initializeCubit(
      DashboardPageCubit cubit,
      BuildContext context,
      int userId,
      int userType,
      String? groupId,
      ) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (cubit.state is! DashboardLoading && cubit.state is! DashboardGroupsLoaded) {
        await cubit.getGroups(userId, GoRouterState.of(context), userType);
      }

      context.read<DashboardPageCubit>().stream
          .where((state) => state is DashboardGroupsLoaded && (state).groups.isNotEmpty)
          .take(1)
          .listen((state) {
        final loadedState = state as DashboardGroupsLoaded;
        _autoSelectGroupIfNeeded(cubit, loadedState, groupId, userId, context);
      });
    });
  }

  void _autoSelectGroupIfNeeded(
      DashboardPageCubit cubit,
      DashboardGroupsLoaded state,
      String? groupIdParam,
      int userId,
      BuildContext context,
      ) {
    if (state.selectedGroupId == null && state.groups.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final targetGroupId = groupIdParam != null ? int.tryParse(groupIdParam) : null;
        final groupIdToSelect = targetGroupId ?? state.groups[0].userGroupId;
        cubit.selectGroup(groupIdToSelect, userId, GoRouterState.of(context));
      });
    }
  }

  bool _isFakeGroupMode(DashboardGroupsLoaded state) {
    return state.groups.length == 1 && state.groups.first.userGroupId == fakeGroupId;
  }

  Widget _buildContent(
      BuildContext context,
      DashboardState state,
      int userId,
      int userType,
      DashboardPageCubit cubit,
      ) {
    if (state is DashboardLoading) {
      return GlassyWrapper(
        child: Scaffold(
          body: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (state is DashboardError) {
      return GlassyWrapper(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Container(
              width: 140,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: Image.asset(AppImages.logoSmall),
            ),
          ),
          drawer: userType == 1 ? AppDrawer(userData: {"userId": userId, "userType": userType}) : null,
          body: Center(
            child: Text(
              'Error: ${state.message}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }

    if (state is! DashboardGroupsLoaded) {
      return const SizedBox.shrink();
    }

    final loadedState = state;

    if (loadedState.groups.isEmpty) {
      return GlassyWrapper(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Container(
              width: 140,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: Image.asset(AppImages.logoSmall),
            ),
          ),
          drawer: userType == 1 ? AppDrawer(userData: {"userId": userId, "userType": userType}) : null,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No groups available. Please create a group to get started.',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text("Add Group"),
                style: const ButtonStyle(
                  side: WidgetStatePropertyAll(BorderSide(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final (selectedGroup, selectedController, controllers) = _getSelectedGroupAndController(loadedState);

    return BlocListener<DashboardPageCubit, DashboardState>(
      listener: (context, state) {
        if (state is DashboardGroupsLoaded &&
            state.groupControllers.isNotEmpty &&
            context.read<ControllerContextCubit>().state is! ControllerContextLoaded) {
          final firstController = state.groupControllers.values.first.first;
          final authState = context.read<AuthBloc>().state as Authenticated;

          context.read<ControllerContextCubit>().setContext(
            userId: authState.user.userDetails.id.toString(),
            controllerId: firstController.userDeviceId.toString(),
            userType: authState.user.userDetails.userType.toString(),
            subUserId: '0', deviceId: firstController.deviceId,
          );
        }
      },
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: AnimatedNotchBottomBar(
          /// Provide NotchBottomBarController
          notchBottomBarController: _controller,
          color: Colors.white,
          showLabel: true,
          textOverflow: TextOverflow.visible,
          maxLine: 1,
          shadowElevation: 5,
          kBottomRadius: 28.0,

          // notchShader: const SweepGradient(
          //   startAngle: 0,
          //   endAngle: pi / 2,
          //   colors: [Colors.red, Colors.green, Colors.orange],
          //   tileMode: TileMode.mirror,
          // ).createShader(Rect.fromCircle(center: Offset.zero, radius: 8.0)),
          notchColor: Colors.white,

          /// restart app if you change removeMargins
          removeMargins: true,
          showShadow: false,
          durationInMilliSeconds: 300,

          itemLabelStyle: const TextStyle(fontSize: 10, color: Colors.black),

          // elevation: 1,
          bottomBarItems: [
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
              inActiveItem: Image.asset(AppImages.inActiveReportIcon,),
              activeItem: Image.asset(AppImages.activeReportIcon),
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
          ],
          onTap: (index) {
            if(index == 0){
              selectedBottomNavigation = BottomNavigationOption.home;
              context.pushReplacement("${DashBoardRoutes.dashboard}?userId=$userId&userType=$userType");
            }else if(index == 1){
              selectedBottomNavigation = BottomNavigationOption.report;
              context.pushReplacement("${DashBoardRoutes.report}?userId=$userId&userType=$userType");
            }else if(index == 2){
              selectedBottomNavigation = BottomNavigationOption.setting;
              context.pushReplacement("${DashBoardRoutes.settings}?userId=$userId&userType=$userType");
            }else if(index == 3){
              selectedBottomNavigation = BottomNavigationOption.sentAndReceive;
              context.pushReplacement("${DashBoardRoutes.sentAndReceive}?userId=$userId&userType=$userType");
            }
            setState(() {});
            log('current selected index $index');
            // _pageController.jumpToPage(index);
          },
          kIconSize: 24.0,
        ),
        appBar: selectedBottomNavigation == BottomNavigationOption.home ? _buildAppBar(
          selectedGroup,
          selectedController,
          controllers,
          loadedState,
          cubit,
          context,
          userId,
          userType,
        ) : CustomAppBar(title: selectedBottomNavigation.title()),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        // drawer: userType == 1 ?),
        drawer: userType == 1 ? AppDrawer(userData: widget.userData,) : null,
        body: selectedController == null
            ? const Center(child: CircularProgressIndicator())
            : widget.child
            // : _buildBody(selectedController, userId, userType),
      ),
    );
  }

  (GroupDetailsEntity, ControllerEntity?, List<ControllerEntity>)
  _getSelectedGroupAndController(DashboardGroupsLoaded state) {
    final selectedGroup = state.groups.firstWhere(
          (group) => group.userGroupId == state.selectedGroupId,
      orElse: () => state.groups[0],
    );

    final controllers = state.groupControllers[state.selectedGroupId] ?? [];
    final effectiveIndex = controllers.isNotEmpty
        ? (state.selectedControllerIndex ?? 0).clamp(0, controllers.length - 1)
        : -1;
    final selectedController = controllers.isNotEmpty ? controllers[effectiveIndex] : null;

    return (selectedGroup, selectedController, controllers);
  }

  PreferredSizeWidget _buildAppBar(
      GroupDetailsEntity selectedGroup,
      ControllerEntity? selectedController,
      List<ControllerEntity> controllers,
      DashboardGroupsLoaded state,
      DashboardPageCubit cubit,
      BuildContext context,
      int userId,
      int userType,
      ) {
    return AppBar(
      title: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Image.asset(AppImages.logoSmall),
      ),
      bottom: _buildAppBarBottom(
        selectedGroup,
        selectedController,
        controllers,
        state,
        cubit,
        context,
        userId,
      ),
      actions: [
        IconButton(
          onPressed: selectedController?.simNumber != null
              ? () => _launchCall(selectedController!.simNumber)
              : null,
          icon: const Icon(Icons.call, color: AppThemes.primaryColor),
        ),
        IconButton(
          onPressed: null,
          icon: Icon(
            Icons.circle,
            color: selectedController?.ctrlStatusFlag == '1' ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  PreferredSize _buildAppBarBottom(
      GroupDetailsEntity selectedGroup,
      ControllerEntity? selectedController,
      List<ControllerEntity> controllers,
      DashboardGroupsLoaded state,
      DashboardPageCubit cubit,
      BuildContext context,
      int userId,
      ) {
    final bool fakeMode = _isFakeGroupMode(state);

    return PreferredSize(
      preferredSize: const Size.fromHeight(48),
      child: Container(
        color: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).primaryColor,
        child: Row(
          children: [
            _buildGroupSelector(state, selectedGroup, cubit, userId, context),

            // Divider only when we have both group selector AND controller selector
            if (!fakeMode && state.groups.length > 1) const _Divider(),

            Expanded(
              child: _buildControllerSelector(
                selectedController,
                controllers,
                cubit,
                context,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupSelector(
      DashboardGroupsLoaded state,
      GroupDetailsEntity selectedGroup,
      DashboardPageCubit cubit,
      int userId,
      BuildContext context,
      ) {
    if (_isFakeGroupMode(state)) {
      // Dealer/special mode - static title, no dropdown
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            selectedGroup.groupName,
            style: const TextStyle(
              color: AppThemes.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    // Normal user flow
    if (state.groups.length > 1) {
      return Expanded(
        child: PopupMenuButton<int>(
          icon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                selectedGroup.groupName,
                style: const TextStyle(
                  color: AppThemes.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: AppThemes.primaryColor),
            ],
          ),
          onSelected: (groupId) {
            cubit.selectGroup(groupId, userId, GoRouterState.of(context));
            context.read<ControllerContextCubit>().toInitial();
          },
          itemBuilder: (context) => state.groups.map((group) {
            return PopupMenuItem<int>(
              value: group.userGroupId,
              child: Text(group.groupName),
            );
          }).toList(),
        ),
      );
    }

    // Single real group - just show name
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          state.groups[0].groupName,
          style: const TextStyle(
            color: AppThemes.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildControllerSelector(
      ControllerEntity? selectedController,
      List<ControllerEntity> controllers,
      DashboardPageCubit cubit,
      BuildContext context,
      ) {
    if (controllers.isEmpty) {
      return const SizedBox.shrink();
    }

    if (controllers.length > 1) {
      return PopupMenuButton<int>(
        enabled: controllers.isNotEmpty,
        icon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedController?.deviceName ?? 'Select controller',
              style: const TextStyle(
                color: AppThemes.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: AppThemes.primaryColor),
          ],
        ),
        onSelected: (index) {
          cubit.selectController(index);
          context.read<ControllerContextCubit>().updateController(
            controllerId: controllers[index].userDeviceId.toString(),
            deviceId: controllers[index].deviceId,
          );
        },
        itemBuilder: (context) => controllers.asMap().entries.map((entry) {
          return PopupMenuItem<int>(
            value: entry.key,
            child: Text(entry.value.deviceName),
          );
        }).toList(),
      );
    }

    // Single controller
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        controllers[0].deviceName,
        style: const TextStyle(
          color: AppThemes.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildBody(ControllerEntity controller, int userId, int userType) {
    return RefreshIndicator(
      onRefresh: () => _refreshLiveData(controller),
      child: LayoutBuilder(
        builder: (context, constraints) =>
            _buildScaledContent(context, constraints, controller, userId, userType),
      ),
    );
  }

  static Future<void> _refreshLiveData(ControllerEntity controller) async {
    final mqttManager = di.sl.get<MqttManager>();
    final deviceId = controller.deviceId;
    final publishMessage = jsonEncode(PublishMessageHelper.requestLive);
    mqttManager.publish(deviceId, publishMessage);

    if (kDebugMode) {
      print("Live message requested for device: $deviceId");
    }
  }

  Widget _buildScaledContent(
      BuildContext context,
      BoxConstraints constraints,
      ControllerEntity controller,
      int userId,
      int userType,
      ) {
    final width = constraints.maxWidth;
    final modelCheck = ([1, 5].contains(controller.modelId)) ? 300 : 120;
    double scale(double size) => size * (width / modelCheck);
    final router = GoRouterState.of(context);
    print(router.extra != null && (router.extra as Map<String, dynamic>)['name'] != null
        && (router.extra as Map<String, dynamic>)['name'] != DashBoardRoutes.dashboard);
    if(userType == 2) {
      userId = router.extra != null && (router.extra as Map<String, dynamic>)['name'] != null
          && (router.extra as Map<String, dynamic>)['name'] != DashBoardRoutes.dashboard
          ? int.parse((router.uri.queryParameters as Map<String, dynamic>)['dealerId']) : userId;
    }
    print(userId);

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: EdgeInsets.all(scale(2)),
            child: GestureDetector(
              onTap: () {
                context.pushNamed(
                  'ctrlDetailsPage',
                  extra: GetControllerDetailsParams(
                    userId: controller.userId,
                    controllerId: controller.userDeviceId,
                    deviceId: controller.deviceId,
                  ),
                );
              },
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.all(2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(height: scale(2)),
                    SyncSection(
                      liveSync: "${controller.livesyncTime}\n${controller.livesyncDate}",
                      smsSync: getSmsSync(controller.ctrlLatestMsg),
                      model: controller.modelId,
                      deviceId: controller.deviceId,
                    ),
                    SizedBox(height: scale(5)),
                    GlassCard(
                      child: CtrlDisplay(
                        signal: controller.liveMessage.signal,
                        battery: controller.liveMessage.batVolt,
                        l1display: controller.liveMessage.liveDisplay1,
                        l2display: controller.liveMessage.liveDisplay2,
                      ),
                    ),
                    SizedBox(height: scale(5)),
                    GestureDetector(
                      onTap: () {
                        context.push(
                          '${DashBoardRoutes.dashboard}${ProgramSettingsRoutes.program}',
                          extra: {
                            "userId": '$userId',
                            "controllerId": controller.userDeviceId.toString()
                          },
                        );
                      },
                      child: RYBSection(
                        r: controller.liveMessage.rVoltage,
                        y: controller.liveMessage.yVoltage,
                        b: controller.liveMessage.bVoltage,
                        c1: controller.liveMessage.rCurrent,
                        c2: controller.liveMessage.yCurrent,
                        c3: controller.liveMessage.bCurrent,
                      ),
                    ),
                    SizedBox(height: scale(5)),
                    MotorValveSection(
                      motorOn: controller.liveMessage.motorOnOff,
                      motorOn2: controller.liveMessage.valveOnOff,
                      valveOn: controller.liveMessage.valveOnOff,
                      model: controller.modelId,
                      userData: {
                        "userId": userId,
                        "controllerId": controller.userDeviceId,
                        "subUserId": 0,
                        "deviceId": controller.deviceId
                      },
                    ),
                    SizedBox(height: scale(5)),
                    if ([1, 5].contains(controller.modelId)) ...[
                      PressureSection(
                        prsIn: controller.liveMessage.prsIn,
                        prsOut: controller.liveMessage.prsOut,
                        activeZone: controller.zoneNo,
                        fertlizer: '',
                      ),
                      SizedBox(height: scale(8)),
                      TimerSection(
                        setTime: controller.setFlow,
                        remainingTime: controller.remFlow,
                      ),
                      SizedBox(height: scale(8)),
                    ],
                    LatestMsgSection(
                      msg: ([1, 5].contains(controller.modelId))
                          ? controller.msgDesc
                          : "${controller.msgDesc}\n${controller.ctrlLatestMsg}",
                    ),
                    SizedBox(height: scale(8)),
                    ActionsSection(
                      model: controller.modelId,
                      data: {
                        "userId": userId,
                        "subUserId": userType == 1 ? 0 : userId,
                        "controllerId": controller.userDeviceId,
                        "deviceId": controller.deviceId
                      },
                    ),
                    SizedBox(height: scale(3)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _launchCall(String phoneNumber) async {
    final Uri url = Uri.parse('tel:$phoneNumber');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching call: $e');
    }
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 20, color: Colors.white54);
  }
}