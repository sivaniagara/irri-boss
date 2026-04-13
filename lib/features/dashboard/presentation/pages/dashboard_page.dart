import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/services/mqtt/mqtt_manager.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_app_bar.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glassy_wrapper.dart';
import 'package:niagara_smart_drip_irrigation/features/auth/auth.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/presentation/cubit/controller_context_cubit.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/presentation/cubit/dashboard_page_cubit.dart';
import 'package:niagara_smart_drip_irrigation/features/fault_msg/utils/faultmsg_routes.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/di/injection.dart' as di;
import '../../../../core/services/mqtt/publish_messages.dart';
import '../../../../core/theme/app_themes.dart';
import '../../../../core/utils/app_constants.dart';
import '../../../../core/utils/app_images.dart';
import '../../../reports/power_reports/utils/Power_routes.dart';
import '../../../sendrev_msg/presentation/bloc/sendrev_bloc.dart';
import '../../../side_drawer/groups/presentation/widgets/app_drawer.dart';
import '../../utils/dashboard_routes.dart';

import '../../domain/entities/controller_entity.dart';
import '../../domain/entities/group_entity.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';


enum BottomNavigationOption{home, report, manual, setting, sentAndReceive, faultMsgMsgPage}

extension BottomNavivigationOptionExtension on BottomNavigationOption{
  String title(){
    switch (this){
      case BottomNavigationOption.home:
        return 'Home';
      case BottomNavigationOption.report:
        return 'Report';
      case BottomNavigationOption.manual:
        return 'Manual';
      case BottomNavigationOption.setting:
        return 'Setting';
      case BottomNavigationOption.sentAndReceive:
        return 'Sent And Receive';
      case BottomNavigationOption.faultMsgMsgPage:
        return 'Fault MSG';
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
  final NotchBottomBarController _controller =
      NotchBottomBarController(index: 0);
  Timer? _liveTimer;

  @override
  void initState() {
    super.initState();
    // Logic removed from here to prevent ProviderNotFoundError
  }

  void _startLiveSync(DashboardPageCubit cubit) {
    if (_liveTimer != null) return; // Ensure only one timer runs

    _liveTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted && selectedBottomNavigation == BottomNavigationOption.home) {
        final state = cubit.state;
        if (state is DashboardGroupsLoaded) {
          final groupId = state.selectedGroupId;
          final controllerIndex = state.selectedControllerIndex;
          if (groupId != null && controllerIndex != null) {
            final controllers = state.groupControllers[groupId] ?? [];
            if (controllerIndex < controllers.length) {
              cubit.getLive(controllers[controllerIndex].deviceId);
            }
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _liveTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final queryParams = GoRouterState.of(context).uri.queryParameters;
    final authState = context.read<AuthBloc>().state;
    
    int userId = 0;
    int userType = 1;

    // Source of truth priority: Query Params -> AuthBloc -> widget.userData
    if (queryParams.containsKey('userId') && queryParams['userId'] != null) {
      userId = int.parse(queryParams['userId']!);
      userType = int.parse(queryParams['userType']!);
    } else if (authState is Authenticated) {
      userId = authState.user.userDetails.id;
      userType = authState.user.userDetails.userType;
    } else {
      userId = int.parse(widget.userData['userId']?.toString() ?? '0');
      userType = int.parse(widget.userData['userType']?.toString() ?? '1');
    }

    final groupId = queryParams['groupId'];

    if (userId <= 0) {
      return const Center(
          child: Text('Invalid user session. Please log in again.'));
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<DashboardPageCubit>()),
        BlocProvider(create: (_) => sl<SendrevBloc>()),
      ],
      child: Builder(
        builder: (context) {
          final cubit = context.read<DashboardPageCubit>();

          // Start the sync timer using the cubit instance from this context
          _startLiveSync(cubit);

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
      )
  {
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
        child: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (state is DashboardError) {
      return GlassyWrapper(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Container(
              width: 100,
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
              width: 100,
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

    // Identify if the current route is one that should show the shell (Appbar/Nav)
    final String currentPath = GoRouterState.of(context).uri.path;
    
    // Define the 5 main tabs that should show the shell's AppBar
    final bool isDashboard = currentPath == DashBoardRoutes.dashboard;
    final bool isReport = currentPath == DashBoardRoutes.report;
    final bool isStandalone = currentPath == DashBoardRoutes.standalone;
    final bool isSettings = currentPath == DashBoardRoutes.settings;
    final bool isSentAndReceive = currentPath == DashBoardRoutes.sentAndReceive;

    // Specific tabs for Standalone Pump models that should also show their "title" AppBar but NOT the dashboard's special AppBar
    final bool isFaultMsg = currentPath == FaultMsgPageRoutes.FaultMsgMsgPage;
    final bool isPowerGraph =
        currentPath == PowerGraphPageRoutes.PowerGraphPage;

    // Determine if we are on a main tab
    final bool isMainTab = isDashboard ||
        isReport ||
        isStandalone ||
        isSettings ||
        isSentAndReceive ||
        isFaultMsg ||
        isPowerGraph;

    return BlocListener<DashboardPageCubit, DashboardState>(
      listener: (context, state) {
        if(state is DashboardGroupsLoaded){
          if(state.selectedGroupId != null){
            print("state.selectedGroupId => ${state.selectedGroupId}");
            print("state.selectedControllerIndex => ${state.selectedControllerIndex}");
            print("state.groupControllers[state.selectedGroupId] => ${state.groupControllers[state.selectedGroupId]}");
            print("state.groupControllers => ${state.groupControllers.keys}");
            if(state.groupControllers[state.selectedGroupId] != null && state.groupControllers[state.selectedGroupId]!.isNotEmpty){
              final selectedController = state.groupControllers[state.selectedGroupId]![state.selectedControllerIndex!];
              print("controllerId = > ${selectedController.userDeviceId}");
              print("deviceId = > ${selectedController.deviceId}");
              print("modelId = > ${selectedController.modelId}");

            }
          }
        }
        if (state is DashboardGroupsLoaded &&
            state.groupControllers.isNotEmpty &&
            context.read<ControllerContextCubit>().state
                is! ControllerContextLoaded) {
          final firstController = state.groupControllers.values.first.first;
          final authState = context.read<AuthBloc>().state as Authenticated;

          context.read<ControllerContextCubit>().setContext(
                userId: authState.user.userDetails.id.toString(),
                controllerId: firstController.userDeviceId.toString(),
                userType: authState.user.userDetails.userType.toString(),
                subUserId: '0',
                deviceId: firstController.deviceId,
                modelId: firstController.modelId,
              );
        }
      },
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: isMainTab
            ? _buildBottomNavigationBar(
                userId, userType, selectedController?.modelId ?? 4)
            : null,
        // Logic: ONLY show the shell's AppBar if we are on a main tab.
        // Sub-pages (like PumpSettingsMenu, SumpSettings) should have NO AppBar from this shell.
        appBar: !isMainTab
            ? null
            : (selectedBottomNavigation == BottomNavigationOption.home &&
                    isDashboard)
                ? _buildAppBar(
                    selectedGroup,
                    selectedController,
                    controllers,
                    loadedState,
                    cubit,
                    context,
                    userId,
                    userType,
                  )
                : (selectedBottomNavigation ==
                            BottomNavigationOption.sentAndReceive &&
                        isSentAndReceive)
                    ? null // Sent and Receive has its own or we hide it
                    : CustomAppBar(
                        title: selectedBottomNavigation.title(),
                      ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        drawer: userType == 1
            ? AppDrawer(
                userData: widget.userData,
              )
            : null,
        body: selectedController == null
            ? const Center(child: CircularProgressIndicator())
            : widget.child,
      ),
    );
  }

  Widget getBottomNavigationForDrip(int userId, int userType) {
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
      bottomBarItems: [
        BottomBarItem(
          inActiveItem: Image.asset(
            AppImages.inActiveHomeIcon,
          ),
          activeItem: Image.asset(AppImages.activeHomeIcon),
          itemLabel: 'Home',
        ),
        BottomBarItem(
          inActiveItem: Image.asset(
            AppImages.inActiveReportIcon,
          ),
          activeItem: Image.asset(AppImages.activeReportIcon),
          itemLabel: 'Report',
        ),
        BottomBarItem(
          inActiveItem: Image.asset(
            AppImages.inActiveManualIcon,
          ),
          activeItem: Image.asset(AppImages.activeManualIcon),
          itemLabel: 'Manual',
        ),
        BottomBarItem(
          inActiveItem: Image.asset(
            AppImages.inActiveSettingIcon,
          ),
          activeItem: Image.asset(AppImages.activeSettingIcon),
          itemLabel: 'Settings',
        ),
        BottomBarItem(
          inActiveItem: Image.asset(
            AppImages.inActiveSentIcon,
          ),
          activeItem: Image.asset(AppImages.activeSentIcon),
          itemLabel: 'Message',
        ),
      ],
      onTap: (index) {
        if (index == 0) {
          selectedBottomNavigation = BottomNavigationOption.home;
          context.pushReplacement(
              "${DashBoardRoutes.dashboard}?userId=$userId&userType=$userType");
        } else if (index == 1) {
          selectedBottomNavigation = BottomNavigationOption.report;
          final controllerContext = context.read<ControllerContextCubit>().state
              as ControllerContextLoaded;
          print(
              "controllerContext.userId:${controllerContext.userId},controllerContext.controllerId:${controllerContext.controllerId},");
          context.pushReplacement(
              "${DashBoardRoutes.report}?userId=$userId&userType=$userType",
              extra: {
                "userId": controllerContext.userId,
                "controllerId": controllerContext.controllerId,
                "userType": controllerContext.userType,
                "subUserId": controllerContext.subUserId,
                "deviceId": controllerContext.deviceId,
              });
        } else if (index == 2) {
          selectedBottomNavigation = BottomNavigationOption.manual;
          final controllerContext = context.read<ControllerContextCubit>().state
              as ControllerContextLoaded;
          context.pushReplacement(
              "${DashBoardRoutes.standalone}?userId=$userId&userType=$userType",
              extra: {
                "userId": controllerContext.userId,
                "controllerId": controllerContext.controllerId,
                "userType": controllerContext.userType,
                "subUserId": controllerContext.subUserId,
                "deviceId": controllerContext.deviceId,
              });
        } else if (index == 3) {
          selectedBottomNavigation = BottomNavigationOption.setting;
          context.pushReplacement(
              "${DashBoardRoutes.settings}?userId=$userId&userType=$userType");
        } else if (index == 4) {
          selectedBottomNavigation = BottomNavigationOption.sentAndReceive;
          context.pushReplacement(
              "${DashBoardRoutes.sentAndReceive}?userId=$userId&userType=$userType");
        }
        setState(() {});
      },
      kIconSize: 24.0,
    );
  }

  Widget getBottomNavigationForPump(int userId, int userType) {
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
      bottomBarItems: [
        BottomBarItem(
          inActiveItem: Image.asset(
            AppImages.inActiveHomeIcon,
          ),
          activeItem: Image.asset(AppImages.activeHomeIcon),
          itemLabel: 'Home',
        ),
        BottomBarItem(
          inActiveItem: Image.asset(
            AppImages.inActiveReportIcon,
          ),
          activeItem: Image.asset(AppImages.activeReportIcon),
          itemLabel: 'Power',
        ),
        BottomBarItem(
          inActiveItem: Image.asset(
            AppImages.inActiveManualIcon,
          ),
          activeItem: Image.asset(AppImages.activeManualIcon),
          itemLabel: 'Fault Msg',
        ),
        BottomBarItem(
          inActiveItem: Image.asset(
            AppImages.inActiveSettingIcon,
          ),
          activeItem: Image.asset(AppImages.activeSettingIcon),
          itemLabel: 'Settings',
        ),
        BottomBarItem(
          inActiveItem: Image.asset(
            AppImages.inActiveSentIcon,
          ),
          activeItem: Image.asset(AppImages.activeSentIcon),
          itemLabel: 'Message',
        ),
      ],
      onTap: (index) {
        if (index == 0) {
          selectedBottomNavigation = BottomNavigationOption.home;
          context.pushReplacement(
              "${DashBoardRoutes.dashboard}?userId=$userId&userType=$userType");
        } else if (index == 1) {
          selectedBottomNavigation = BottomNavigationOption.report;
          final controllerContext = context.read<ControllerContextCubit>().state
              as ControllerContextLoaded;
          print(
              "controllerContext.userId:${controllerContext.userId},controllerContext.controllerId:${controllerContext.controllerId},");
          context.pushReplacement(
              "${PowerGraphPageRoutes.PowerGraphPage}?userId=$userId&userType=$userType",
              extra: {
                "userId": controllerContext.userId,
                "controllerId": controllerContext.controllerId,
                "userType": controllerContext.userType,
                "subUserId": controllerContext.subUserId,
                "deviceId": controllerContext.deviceId,
                "modelId": controllerContext.modelId,
              });
        } else if (index == 2) {
          selectedBottomNavigation = BottomNavigationOption.faultMsgMsgPage;
          final controllerContext = context.read<ControllerContextCubit>().state
              as ControllerContextLoaded;
          context.pushReplacement(
              "${FaultMsgPageRoutes.FaultMsgMsgPage}?userId=$userId&userType=$userType",
              extra: {
                "userId": controllerContext.userId,
                "controllerId": controllerContext.controllerId,
                "userType": controllerContext.userType,
                "subUserId": controllerContext.subUserId,
                "deviceId": controllerContext.deviceId,
              });
        } else if (index == 3) {
          selectedBottomNavigation = BottomNavigationOption.setting;
          context.pushReplacement(
              "${DashBoardRoutes.settings}?userId=$userId&userType=$userType");
        } else if (index == 4) {
          selectedBottomNavigation = BottomNavigationOption.sentAndReceive;
          context.pushReplacement(
              "${DashBoardRoutes.sentAndReceive}?userId=$userId&userType=$userType");
        }
        setState(() {});
      },
      kIconSize: 24.0,
    );
  }

  Widget _buildBottomNavigationBar(int userId, int userType, int modelId) {
    if (AppConstants.isIrrigationLive(modelId)) {
      return getBottomNavigationForDrip(userId, userType);
    } else {
      return getBottomNavigationForPump(userId, userType);
    }
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
    final selectedController =
        controllers.isNotEmpty ? controllers[effectiveIndex] : null;

    return (selectedGroup, selectedController, controllers);
  }

  PreferredSizeWidget? _buildProperAppBar(
    String location,
    GroupDetailsEntity selectedGroup,
    ControllerEntity? selectedController,
    List<ControllerEntity> controllers,
    DashboardGroupsLoaded state,
    DashboardPageCubit cubit,
    BuildContext context,
    int userId,
    int userType,
  ) {
    if (location == DashBoardRoutes.dashboard) {
      return _buildAppBar(selectedGroup, selectedController, controllers, state,
          cubit, context, userId, userType);
    }

    String? title;
    if (location == DashBoardRoutes.report)
      title = "Report";
    else if (location == DashBoardRoutes.standalone)
      title = "Manual";
    else if (location == DashBoardRoutes.settings)
      title = "Setting";
    else if (location == DashBoardRoutes.sentAndReceive)
      title = "Sent And Receive";
    else if (location == FaultMsgPageRoutes.FaultMsgMsgPage)
      title = "Fault MSG";

    if (title != null) {
      return AppBar(
        title: Text(title,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      );
    }

    return null;
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
        width: 100,
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
        color: Theme.of(context).appBarTheme.backgroundColor ??
            Theme.of(context).primaryColor,
        child: Row(
          children: [
            _buildGroupSelector(state, selectedGroup, cubit, userId, context),

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
          onSelected: (groupId) async{
            print("groupId change ");
            print(groupId);
            print(userId);
            (int, int, String) result = await cubit.selectGroup(groupId, userId, GoRouterState.of(context));
            // final selectedGroup = state.groupControllers[state.selectedGroupId]![state.selectedControllerIndex!];
            // print("selectedGroup  => ${selectedGroup.userDeviceId}");
            context.read<ControllerContextCubit>().updateController(
                modelId: result.$1,
                controllerId: result.$2.toString(),
                deviceId: result.$3
            );
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
          print("controller change ");
          print(index);
          print(controllers[index].userDeviceId);
          print(controllers[index].deviceId);
          cubit.selectController(index);
          context.read<ControllerContextCubit>().updateController(
                controllerId: controllers[index].userDeviceId.toString(),
                deviceId: controllers[index].deviceId,
                modelId: controllers[index].modelId,
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
