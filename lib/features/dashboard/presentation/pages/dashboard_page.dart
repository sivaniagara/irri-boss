import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glass_effect.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glassy_wrapper.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/injection.dart' as di;
import '../../../../core/services/selected_controller_persistence.dart';
import '../../../../core/utils/app_images.dart';
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
import '../../../mqtt/mqtt_barrel.dart';
import '../../dashboard.dart';

class DashboardPage extends StatelessWidget {
  final int userId, userType;
  const DashboardPage({super.key, required this.userId, required this.userType});

  @override
  Widget build(BuildContext dialogContext) {
    if (userId <= 0) {
      return const Center(child: Text('Invalid user session. Please log in again.'));
    }

    final bloc = di.sl.get<DashboardBloc>();
    _initializeBloc(bloc, dialogContext);

    return BlocProvider.value(
      value: bloc,
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) => _buildContent(context, state),
      ),
    );
  }

  void _initializeBloc(DashboardBloc bloc, BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (bloc.state is! DashboardLoading && bloc.state is! DashboardGroupsLoaded) {
        bloc.add(FetchDashboardGroupsEvent(userId));
      }

      // One-time restore + auto-select when groups are loaded
      bloc.stream
          .where((state) => state is DashboardGroupsLoaded && (state).groups.isNotEmpty)
          .take(1)
          .listen((state) {
        final loadedState = state as DashboardGroupsLoaded;
        _restoreLastSelectionIfPossible(loadedState, bloc);
        _autoSelectGroupIfNeeded(bloc, loadedState);
      });

      await Future.delayed(const Duration(seconds: 5));
      if (!bloc.isClosed) bloc.add(StartPollingEvent());

      final mqttBloc = di.sl.get<MqttBloc>();
      mqttBloc.setProcessingContext(context);
    });
  }

  Widget _buildContent(BuildContext context, DashboardState state) {
    if (state is DashboardLoading) {
      return Scaffold(
          body: const Center(child: CircularProgressIndicator()));
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Image.asset(NiagaraCommonImages.logoSmall),
              ),
            ),
            drawer: userType == 1 ? const AppDrawer() : null,
            body: Center(
                child: Text('Error: ${state.message}', style: TextStyle(color: Colors.white),)
            )
        ),
      );
    }
    if (state is! DashboardGroupsLoaded) {
      return const SizedBox.shrink();
    }

    if (state.groups.isEmpty) {
      return GlassyWrapper(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Container(
              width: 140,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
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
              Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No groups available. Please create a group to get started.',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: (){

                },
                icon: Icon(Icons.add),
                label: Text("Add Group"),
                style: ButtonStyle(
                    side: WidgetStatePropertyAll(BorderSide(color: Colors.white))
                ),
              )
            ],
          ),
        ),
      );
    }

    final bloc = context.read<DashboardBloc>();

    final (selectedGroup, selectedController, controllers) = _getSelectedGroupAndController(state);

    return GlassyWrapper(
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (notification) {
          notification.disallowIndicator();
          return true;
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: _buildAppBar(selectedGroup, selectedController, controllers, state, bloc, context),
          drawer: userType == 1 ? const AppDrawer() : null,
          body: selectedController == null
              ? const Center(child: CircularProgressIndicator())
              : _buildBody(selectedController),
        ),
      ),
    );
  }

  void _autoSelectGroupIfNeeded(DashboardBloc bloc, DashboardGroupsLoaded state) {
    if (state.selectedGroupId == null && state.groups.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!bloc.isClosed) {
          bloc.add(SelectGroupEvent(state.groups[0].userGroupId));
        }
      });
    }
  }

  (GroupDetailsEntity, ControllerEntity?, List<ControllerEntity>)
  _getSelectedGroupAndController(DashboardGroupsLoaded state) {
    // Safe now since we checked state.groups.isEmpty earlier; no throw needed
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
      DashboardBloc bloc,
      BuildContext context,
      ) {
    return AppBar(
      title: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Image.asset(NiagaraCommonImages.logoSmall),
      ),
      bottom: _buildAppBarBottom(selectedGroup, selectedController, controllers, state, bloc, context),
      actions: [
        IconButton(
          onPressed: selectedController?.simNumber != null
              ? () => _launchCall(selectedController!.simNumber)
              : null,
          icon: const Icon(Icons.call, color: Colors.white),
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
      DashboardBloc bloc,
      BuildContext context
      ) {
    return PreferredSize(
      preferredSize: Size(MediaQuery.of(context).size.width, 40),
      child: Container(
        color: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).primaryColor, // Ensure visible background
        child: Row(
          children: [
            _buildGroupSelector(state, selectedGroup, bloc),
            if (state.groups.length > 1) const _Divider(),
            _buildControllerSelector(selectedController, controllers, bloc),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupSelector(DashboardGroupsLoaded state, dynamic selectedGroup, DashboardBloc bloc) {
    if (state.groups.isEmpty) return const SizedBox.shrink();

    if (state.groups.length > 1) {
      return Expanded(
        child: PopupMenuButton<int>(
          icon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                selectedGroup.groupName,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.white),
            ],
          ),
          onSelected: (groupId) => _onGroupSelected(groupId, selectedGroup, state, bloc),
          itemBuilder: (context) => state.groups
              .map((group) => PopupMenuItem<int>(
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
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildControllerSelector(ControllerEntity? selectedController, List<ControllerEntity> controllers, DashboardBloc bloc) {
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
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.white),
            ],
          ),
          onSelected: (index) => bloc.add(SelectControllerEvent(index)),
          itemBuilder: (context) => controllers.isNotEmpty
              ? controllers.asMap().entries.map((entry) => PopupMenuItem<int>(
            value: entry.key,
            child: Text(entry.value.deviceName),
          )).toList()
              : [
            const PopupMenuItem<int>(
              enabled: false,
              child: Text('No controllers available'),
            ),
          ],
        ),
      );
    }
    return Expanded(
      child: Text(
        controllers[0].deviceName,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _onGroupSelected(int groupId, GroupDetailsEntity selectedGroup, DashboardGroupsLoaded state, DashboardBloc bloc) {
    if (bloc.isClosed) return;

    final userId = selectedGroup.userId;  // Adjust if needed to parent userId
    if (!state.groupControllers.containsKey(groupId)) {
      bloc.add(FetchControllersEvent(userId, groupId));
    }
    bloc.add(SelectGroupEvent(groupId));
  }

  static Widget _buildBody(dynamic selectedController) {
    return RefreshIndicator(
      onRefresh: () => _refreshLiveData(selectedController),
      child: LayoutBuilder(
        builder: (context, constraints) => _buildScaledContent(context, constraints, selectedController),
      ),
    );
  }

  static Future<void> _refreshLiveData(dynamic selectedController) async {
    final mqttBloc = di.sl<MqttBloc>();
    final deviceId = selectedController.deviceId;
    final publishMessage = jsonEncode(PublishMessageHelper.requestLive);
    mqttBloc.add(PublishMqttEvent(deviceId: deviceId, message: publishMessage));
    if (kDebugMode) {
      print("Live message from server : ${selectedController.liveMessage}");
    }
  }

  static Widget _buildScaledContent(BuildContext context, BoxConstraints constraints, ControllerEntity controller) {
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
            child: GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
                mainAxisAlignment: MainAxisAlignment.spaceAround, // Center vertically
                mainAxisSize: MainAxisSize.max,
                children: [
                  SyncSection(
                    liveSync: controller.livesyncTime,
                    smsSync: controller.msgDesc,
                    model: controller.modelId,
                  ),
                  SizedBox(height: scale(8)),
                  GlassCard(
                    child: CtrlDisplay(
                      signal: controller.liveMessage.signal,
                      battery: controller.liveMessage.batVolt,
                      l1display:controller.liveMessage.liveDisplay1,
                      l2display: controller.liveMessage.liveDisplay2,
                    ),
                  ),
                  SizedBox(height: scale(8)),
                  GestureDetector(
                    onTap: () {
                      context.push(DashBoardRoutes.ctrlLivePage, extra: controller.liveMessage);
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
                    data: {"userId" : controller.userId, "subUserId" : 0, "controllerId" : controller.userDeviceId},
                  ),
                ],
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

  void _restoreLastSelectionIfPossible(DashboardGroupsLoaded state, DashboardBloc bloc) {
    final persistence = di.sl<SelectedControllerPersistence>();
    final savedDeviceId = persistence.deviceId;
    final savedGroupId = persistence.groupId;

    if (savedDeviceId == null || savedGroupId == null) return;

    // Find and select the saved controller
    final controllers = state.groupControllers[savedGroupId];
    if (controllers != null) {
      final index = controllers.indexWhere((c) => c.deviceId == savedDeviceId);
      if (index != -1) {
        bloc.add(SelectGroupEvent(savedGroupId));
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!bloc.isClosed) {
            bloc.add(SelectControllerEvent(index));
          }
        });
        return;
      }
    }

    // Fallback: just select the group
    bloc.add(SelectGroupEvent(savedGroupId));
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext dialogContext) {
    return Container(width: 1, height: 20, color: Colors.white54);
  }
}