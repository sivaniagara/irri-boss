import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/services/mqtt/mqtt_manager.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glass_effect.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glassy_wrapper.dart';
import 'package:niagara_smart_drip_irrigation/features/auth/auth.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/presentation/cubit/controller_context_cubit.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/presentation/cubit/dashboard_page_cubit.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/injection.dart' as di;
import '../../../../core/services/mqtt/publish_messages.dart';
import '../../../../core/theme/app_themes.dart';
import '../../../../core/utils/app_images.dart';
import '../../../controller_details/domain/usecase/controller_details_params.dart';
import '../../../program_settings/utils/program_settings_routes.dart';
import '../../../side_drawer/groups/presentation/widgets/app_drawer.dart';
import '../../utils/dashboard_routes.dart';
import '../widgets/actions_section.dart';
import '../widgets/ctrl_display.dart';
import '../widgets/latestmsg_section.dart';
import '../widgets/motor_valve_section.dart';
import '../widgets/pressure_section.dart';
import '../widgets/ryb_section.dart';
import '../widgets/sync_section.dart';
import '../widgets/timer_section.dart';
import '../../dashboard.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final queryParams = GoRouterState.of(context).uri.queryParameters;
    print("Query parameters :: ${GoRouterState.of(context).uri.queryParameters}");
    final userId = int.parse(queryParams['userId']!);
    final userType = int.parse(queryParams['userType']!);
    final groupId = queryParams['groupId'];

    if (userId <= 0) {
      return const Center(child: Text('Invalid user session. Please log in again.'));
    }

    return BlocProvider(
      create: (_) => di.sl<DashboardPageCubit>(),
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
        await cubit.getGroups(userId, GoRouterState.of(context));
      }

      // Listen once for groups loaded to auto-select group
      context.read<DashboardPageCubit>().stream
          .where((state) => state is DashboardGroupsLoaded && (state).groups.isNotEmpty)
          .take(1)
          .listen((state) {
        final loadedState = state as DashboardGroupsLoaded;
        _autoSelectGroupIfNeeded(cubit, loadedState, groupId, userId);
      });
    });
  }

  void _autoSelectGroupIfNeeded(
      DashboardPageCubit cubit,
      DashboardGroupsLoaded state,
      String? groupIdParam,
      int userId,
      ) {
    if (state.selectedGroupId == null && state.groups.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final targetGroupId = groupIdParam != null ? int.tryParse(groupIdParam) : null;
        final groupIdToSelect = targetGroupId ?? state.groups[0].userGroupId;
        cubit.selectGroup(groupIdToSelect, userId);
      });
    }
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
              child: Image.asset(NiagaraCommonImages.logoSmall),
            ),
          ),
          drawer: userType == 1 ? const AppDrawer() : null,
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
              child: Image.asset(NiagaraCommonImages.logoSmall),
            ),
          ),
          drawer: userType == 1 ? const AppDrawer() : null,
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

    final (selectedGroup, selectedController, controllers) =
    _getSelectedGroupAndController(loadedState);

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
            subUserId: '0',
          );
        }
      },
      child: GlassyWrapper(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: _buildAppBar(
            selectedGroup,
            selectedController,
            controllers,
            loadedState,
            cubit,
            context,
            userId,
            userType,
          ),
          drawer: userType == 1 ? const AppDrawer() : null,
          body: selectedController == null
              ? const Center(child: CircularProgressIndicator())
              : _buildBody(selectedController, userId, userType),
        ),
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
    final selectedController =
    controllers.isNotEmpty ? controllers[effectiveIndex] : null;

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
        child: Image.asset(NiagaraCommonImages.logoSmall),
      ),
      bottom: _buildAppBarBottom(
          selectedGroup, selectedController, controllers, state, cubit, context, userId),
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
            color: selectedController?.ctrlStatusFlag == '1'
                ? Colors.green
                : Colors.red,
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
    return PreferredSize(
      preferredSize: Size(MediaQuery.of(context).size.width, 40),
      child: Container(
        color: Theme.of(context).appBarTheme.backgroundColor ??
            Theme.of(context).primaryColor,
        child: Row(
          children: [
            _buildGroupSelector(state, selectedGroup, cubit, userId),
            if (state.groups.length > 1) const _Divider(),
            _buildControllerSelector(
                selectedController, controllers, cubit, context),
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
      ) {
    if (state.groups.length > 1) {
      return Expanded(
        child: PopupMenuButton<int>(
          icon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                selectedGroup.groupName,
                style: const TextStyle(
                    color: AppThemes.primaryColor, fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.arrow_drop_down, color: AppThemes.primaryColor),
            ],
          ),
          onSelected: (groupId) => cubit.selectGroup(groupId, userId),
          itemBuilder: (context) => state.groups.map((group) => PopupMenuItem<int>(
            value: group.userGroupId,
            child: Text(group.groupName),
          ))
              .toList(),
        ),
      );
    }

    return Expanded(
      child: Text(
        state.groups[0].groupName,
        style: const TextStyle(
            color: AppThemes.primaryColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildControllerSelector(
      ControllerEntity? selectedController,
      List<ControllerEntity> controllers,
      DashboardPageCubit cubit,
      BuildContext context,
      ) {
    if (controllers.isEmpty) return const SizedBox.shrink();

    if (controllers.length > 1) {
      return Expanded(
        child: PopupMenuButton<int>(
          enabled: controllers.isNotEmpty,
          icon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                selectedController?.deviceName ?? 'Select controller',
                style: const TextStyle(
                    color: AppThemes.primaryColor, fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.arrow_drop_down, color: AppThemes.primaryColor),
            ],
          ),
          onSelected: (index) {
            cubit.selectController(index);

            context.read<ControllerContextCubit>().updateController(
              controllerId: controllers[index].userDeviceId.toString(),
            );
          },
          itemBuilder: (context) => controllers.asMap().entries.map((entry) {
            return PopupMenuItem<int>(
              value: entry.key,
              child: Text(entry.value.deviceName),
            );
          }).toList(),
        ),
      );
    }

    return Expanded(
      child: Text(
        controllers[0].deviceName,
        style: const TextStyle(
            color: AppThemes.primaryColor, fontWeight: FontWeight.bold),
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
                  ),
                );
              },
              child: GlassyWrapper(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SyncSection(
                        liveSync: controller.livesyncTime,
                        smsSync: controller.livesyncTime,
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
                      SizedBox(height: scale(8)),
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
                      SizedBox(height: scale(8)),
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
                          "userId": controller.userId,
                          "subUserId": 0,
                          "controllerId": controller.userDeviceId,
                          "deviceId": controller.deviceId
                        },
                      ),
                    ],
                  ),
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