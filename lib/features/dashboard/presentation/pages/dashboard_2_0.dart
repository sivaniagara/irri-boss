import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/alert_dialog.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/app_alerts.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_switch.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/presentation/cubit/controller_context_cubit.dart';
import 'package:readmore/readmore.dart';
import '../../../../core/services/ble/ble_cubit.dart';
import '../../../../core/services/ble/ble_status_banner.dart';
import '../../../../core/utils/app_images.dart';
import '../../../../core/utils/route_constants.dart';
import '../../../../core/utils/safe_parser.dart';
import '../../../controller_details/domain/usecase/controller_details_params.dart';
import '../../../edit_program/utils/edit_program_routes.dart';
import '../../domain/entities/controller_entity.dart';
import '../../domain/entities/livemessage_entity.dart';
import '../../utils/dashboard_routes.dart';
import '../cubit/dashboard_page_cubit.dart';
import '../widgets/static_progress_circle_with_image.dart';
import 'package:intl/intl.dart';

import 'package:niagara_smart_drip_irrigation/core/utils/log.dart';

// ---------------------------------------------------------------------------
// Animated glow button — wraps any child icon with a pulsing halo when active
// ---------------------------------------------------------------------------
class GlowButton extends StatefulWidget {
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onPressed;
  final Widget icon;
  final String label;

  const GlowButton({
    super.key,
    required this.isActive,
    required this.activeColor,
    required this.inactiveColor,
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  State<GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<GlowButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(GlowButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.repeat(reverse: true);
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isActive ? widget.activeColor : widget.inactiveColor;

    return Column(
      children: [
        AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: widget.isActive
                    ? [
                  BoxShadow(
                    color: widget.activeColor
                        .withOpacity(_glowAnimation.value * 0.6),
                    blurRadius: 14 * _glowAnimation.value,
                    spreadRadius: 4 * _glowAnimation.value,
                  ),
                ]
                    : [],
              ),
              child: child,
            );
          },
          child: IconButton(
            onPressed: widget.onPressed,
            icon: widget.icon,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(color),
            ),
          ),
        ),
        Text(
          widget.label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: color,
          ),
        ),
      ],
    );
  }
}
// ---------------------------------------------------------------------------
List<int> wlcModel = [45];
class Dashboard20 extends StatefulWidget {
  const Dashboard20({super.key});

  @override
  State<Dashboard20> createState() => _Dashboard20State();
}

class _Dashboard20State extends State<Dashboard20> {
  List<int> pumpModel = [4, 11, 27];

  int _lastModelId = -1; // -1 = not yet seen any model

  /// Called every time the selected controller changes (modelId differs).
  /// Safe to call from build via addPostFrameCallback.
  void _onModelChanged(BuildContext context, int newModelId) {
    final wasWlc = wlcModel.contains(_lastModelId);
    final isWlc  = wlcModel.contains(newModelId);

    // If we switched AWAY from a WLC model → disconnect BLE immediately.
    if (wasWlc && !isWlc) {
      context.read<BleCubit>().disconnect();
      kdebugmode('Model changed away from WLC ($_lastModelId → $newModelId): BLE disconnected');
    }

    _lastModelId = newModelId;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardPageCubit, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DashboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message,
                      style: const TextStyle(fontSize: 16)),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Retry'),
                  )
                ],
              ),
            );
          }

          if (state is! DashboardGroupsLoaded) return const SizedBox.shrink();

          final groupId = state.selectedGroupId;
          final controllerIndex = state.selectedControllerIndex;

          if (groupId == null ||
              controllerIndex == null ||
              state.groupControllers[groupId] == null ||
              state.groupControllers[groupId]!.isEmpty) {
            return const Center(child: Text("No Controllers Found"));
          }

          ControllerEntity controllerEntity =
          state.groupControllers[groupId]![controllerIndex];

          // Detect model change and handle BLE disconnect outside the build frame.
          if (_lastModelId != controllerEntity.modelId) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _onModelChanged(context, controllerEntity.modelId);
            });
          }

          LiveMessageEntity liveMessageEntity = controllerEntity.liveMessage;

          // ── WLC model: gate everything behind BLE + live data ────────────
          if (wlcModel.contains(controllerEntity.modelId)) {
            return BlocBuilder<BleCubit, BleState>(
              builder: (context, bleState) {
                final bool bleConnected = bleState is BleConnected &&
                    bleState.deviceId == controllerEntity.deviceId;
                final bool hasLiveData = liveMessageEntity.cd.isNotEmpty;

                // Show pump dashboard only once BLE is connected AND live data
                // has arrived through the BLE → dispatcher → cubit pipeline.
                if (bleConnected && hasLiveData) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      context
                          .read<DashboardPageCubit>()
                          .getLive(controllerEntity.deviceId, controllerEntity.modelId);
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        spacing: 10,
                        children: [
                          const SizedBox(height: 20),
                          BleStatusBanner(deviceId: controllerEntity.deviceId),
                          ...pumpDashboard(
                            controllerEntity: controllerEntity,
                            liveMessageEntity: liveMessageEntity,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Otherwise show the BLE scanning / connecting / error screen.
                return _WlcBleScreen(
                  deviceId: controllerEntity.deviceId,
                  bleState: bleState,
                );
              },
            );
          }

          // ── Non-WLC models: unchanged flow ────────────────────────────────
          return RefreshIndicator(
            onRefresh: () async {
              context
                  .read<DashboardPageCubit>()
                  .getLive(controllerEntity.deviceId, controllerEntity.modelId);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                spacing: 10,
                children: [
                  const SizedBox(height: 20),
                  if (pumpModel.contains(controllerEntity.modelId))
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
        listener: (context, state) {
          if (state is DashboardGroupsLoaded &&
              state.changeFromStatus == ChangeFromStatus.loading) {
            showGradientLoadingDialog(context);
          } else if (state is DashboardGroupsLoaded &&
              state.changeFromStatus == ChangeFromStatus.success) {
            context.pop();
            showSuccessAlert(
                context: context,
                message: 'Change From command Success');
          } else if (state is DashboardGroupsLoaded &&
              state.changeFromStatus == ChangeFromStatus.failure) {
            context.pop();
            showErrorAlert(context: context, message: state.errorMsg);
          } else if (state is DashboardGroupsLoaded &&
              state.controlMotorStatus == ControlMotorStatus.loading) {
            showGradientLoadingDialog(context);
          } else if (state is DashboardGroupsLoaded &&
              state.controlMotorStatus == ControlMotorStatus.success) {
            context.pop();
            showSuccessAlert(
                context: context, message: 'Motor command Send Success');
          } else if (state is DashboardGroupsLoaded &&
              state.controlMotorStatus == ControlMotorStatus.failure) {
            context.pop();
            showErrorAlert(context: context, message: state.errorMsg);
          }
        },
        listenWhen: (previous, current) {
          if (previous is DashboardGroupsLoaded &&
              current is DashboardGroupsLoaded) {
            bool statusChanged =
                previous.controlMotorStatus != current.controlMotorStatus ||
                    previous.changeFromStatus != current.changeFromStatus;
            return statusChanged;
          }
          return true;
        }
    );
  }

  Widget mountainWidget(ControllerEntity controllerEntity,
      LiveMessageEntity liveMessageEntity) {
    String syncTime = liveMessageEntity.ct;
    String syncDate = liveMessageEntity.cd;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: -10,
            right: -10,
            child: Image.asset(height: 80, AppImages.mountain),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              spacing: 15,
              children: [
                Row(
                  spacing: 5,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.signal_cellular_alt,
                            color: Colors.green),
                        Text(
                          '${liveMessageEntity.signal}%',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.battery_6_bar_rounded,
                            color: Colors.green),
                        Text(
                          'Battery ${SafeParser.parseDouble(liveMessageEntity.batVolt).toStringAsFixed(0)}% | ${getDate(liveData: liveMessageEntity)}',
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(fontWeight: FontWeight.w400),
                        ),
                      ],
                    )
                  ],
                ),
                Row(
                  spacing: 5,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.circle,
                                  color: Colors.green, size: 10),
                              const SizedBox(width: 4),
                              Text(
                                'Live Sync : $syncDate, $syncTime',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.circle,
                                  color: Colors.orange, size: 10),
                              const SizedBox(width: 4),
                              Text(
                                'SMS Sync : ${_formatTime12H(controllerEntity.smsSyncTime)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.cloudy_snowing,
                            color: Theme.of(context).colorScheme.primary),
                        Text(
                          overflow: TextOverflow.ellipsis,
                          "25\u00B0 C, Windy",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
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

  List<Widget> pumpDashboard(
      {required ControllerEntity controllerEntity,
        required LiveMessageEntity liveMessageEntity}) {
    return [
      mountainWidget(controllerEntity, liveMessageEntity),
      voltageAndCurrent(
          controllerEntity: controllerEntity,
          liveMessageEntity: liveMessageEntity),
      doublePumpWidget(
          controllerEntity: controllerEntity,
          liveMessageEntity: liveMessageEntity),
      dashboardCard(
        child: Column(
          spacing: 20,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            iconWithHeader(
              title: 'Latest Message',
              iconBackgroundColor: const Color(0xffB4E7FF),
              iconColor: Theme.of(context).colorScheme.primary,
              icon: Icon(Icons.message,
                  color: Theme.of(context).colorScheme.primary),
            ),
            Text(
              controllerEntity.msgDesc,
              style: const TextStyle(fontSize: 16, color: Color(0xff424242)),
            ),
            ReadMoreText(
              controllerEntity.ctrlLatestMsg,
              trimLines: 2,
              trimMode: TrimMode.Line,
              trimCollapsedText: ' Show more',
              trimExpandedText: ' Show less',
              style: const TextStyle(fontSize: 16, color: Color(0xff424242)),
              moreStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor),
              lessStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor),
            )
          ],
        ),
      ),
      const SizedBox(height: 100)
    ];
  }

  Widget voltageAndCurrent(
      {required ControllerEntity controllerEntity,
        required LiveMessageEntity liveMessageEntity}) {
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
                  color: const Color(0xffFFF5DC),
                ),
                child: Center(
                  child: Image.asset(AppImages.currentIcon,
                      width: 25, height: 25),
                ),
              ),
              Text('Voltage & Current',
                  style: Theme.of(context).textTheme.labelLarge),
              const Spacer(),
              InkWell(
                onTap: () {
                  if (pumpModel.contains(controllerEntity.modelId)) {
                    context.push(
                      RouteConstants.ctrlDetailsPage,
                      extra: GetControllerDetailsParams(
                        userId: controllerEntity.userId,
                        controllerId: controllerEntity.userDeviceId,
                        deviceId: controllerEntity.deviceId,
                      ),
                    );
                  } else {
                    context.push(DashBoardRoutes.ctrlLivePage,
                        extra: controllerEntity);
                  }
                },
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xffE6F2FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        pumpModel.contains(controllerEntity.modelId)
                            ? Icons.info_outline
                            : Icons.developer_board,
                        size: 20,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        pumpModel.contains(controllerEntity.modelId)
                            ? "Details"
                            : "Controller Live",
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              rybWidget(
                  backgroundColor: const Color(0xffE21E11),
                  value: liveMessageEntity.rVoltage,
                  phase: 'R Phase'),
              rybWidget(
                  backgroundColor: const Color(0xffFEC106),
                  value: liveMessageEntity.yVoltage,
                  phase: 'Y Phase'),
              rybWidget(
                  backgroundColor: const Color(0xff6C8DB7),
                  value: liveMessageEntity.bVoltage,
                  phase: 'B Phase'),
            ],
          ),
          Center(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xffE1EEEE)),
              child: Center(
                child: Text(
                  'Current : C1 ${liveMessageEntity.rCurrent}A , C2 ${liveMessageEntity.yCurrent}A , C3 ${liveMessageEntity.bCurrent}A',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  List<Widget> dripDashboard(
      {required ControllerEntity controllerEntity,
        required LiveMessageEntity liveMessageEntity}) {
    return [
      mountainWidget(controllerEntity, liveMessageEntity),
      voltageAndCurrent(
          controllerEntity: controllerEntity,
          liveMessageEntity: liveMessageEntity),
      dashboardCard(
        child: Column(
          spacing: 20,
          children: [
            Row(
              children: [
                Column(
                  children: [
                    Image.asset(
                      liveMessageEntity.motorOnOff == '1'
                          ? 'assets/images/common/motor_running.gif'
                          : 'assets/images/common/motor_r.png',
                      width: 60,
                    ),
                    Text(
                      'Motor',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: liveMessageEntity.motorOnOff == '1'
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 5,
                  children: [
                    Row(
                      spacing: 10,
                      children: [
                        // ── Glow OFF button ──────────────────────────────────
                        GlowButton(
                          isActive: liveMessageEntity.motorOnOff != '1',
                          activeColor: Colors.red,
                          inactiveColor: Colors.red.shade200,
                          label: 'OFF',
                          icon: const Icon(Icons.power_settings_new,
                              color: Colors.white),
                          onPressed: () {
                            kdebugmode("call motor off");
                            final controllerContext = context
                                .read<ControllerContextCubit>()
                                .state as ControllerContextLoaded;
                            context.read<DashboardPageCubit>().controlMotorStatus(
                                userId: controllerContext.userId,
                                controllerId: controllerContext.controllerId,
                                programId: SafeParser.getProgramId(
                                    liveMessageEntity.programName),
                                deviceId: controllerContext.deviceId,
                                payload: 'MTROF,');
                          },
                        ),
                        // ── Glow ON button ───────────────────────────────────
                        GlowButton(
                          isActive: liveMessageEntity.motorOnOff == '1',
                          activeColor: Colors.green,
                          inactiveColor: Colors.green.shade200,
                          label: 'ON',
                          icon: const Icon(Icons.power_settings_new,
                              color: Colors.white),
                          onPressed: () {
                            kdebugmode("call motor on");
                            final controllerContext = context
                                .read<ControllerContextCubit>()
                                .state as ControllerContextLoaded;
                            context.read<DashboardPageCubit>().controlMotorStatus(
                                userId: controllerContext.userId,
                                controllerId: controllerContext.controllerId,
                                programId: SafeParser.getProgramId(
                                    liveMessageEntity.programName),
                                deviceId: controllerContext.deviceId,
                                payload: 'MTRON,');
                          },
                        ),
                      ],
                    ),
                    Text(
                        '${liveMessageEntity.modeOfOperation} | Block ${liveMessageEntity.zoneNo}',
                        style: Theme.of(context).textTheme.bodySmall)
                  ],
                ),
                const Spacer(),
                Row(
                  spacing: 10,
                  children: [
                    Image.asset('assets/images/icons/pressure_gauge_icon.png',
                        width: 30),
                    Column(
                      spacing: 5,
                      children: [
                        Text('Pressure',
                            style: Theme.of(context).textTheme.labelLarge),
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                  text: "In: ",
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text: '${liveMessageEntity.prsIn}   ',
                                  style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold)),
                              const TextSpan(
                                  text: "Out: ",
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text: liveMessageEntity.prsOut,
                                  style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold)),
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
                  value: controllerEntity.liveMessage.motorOnOff == "1"
                      ? liveMessageEntity.zoneDuration
                      : "00:00:00",
                  titleColor: const Color(0xff2E712A),
                  backgroundColor: const Color(0xff689F39),
                ),
                scheduleTimeCard(
                  title: 'Time Left',
                  value: controllerEntity.liveMessage.motorOnOff == "1"
                      ? liveMessageEntity.zoneRemainingTime
                      : "00:00:00",
                  titleColor: const Color(0xff347CA6),
                  backgroundColor: const Color(0xff52AED7),
                ),
                GestureDetector(
                  onTap: () {
                    final controllerContext = context
                        .read<ControllerContextCubit>()
                        .state as ControllerContextLoaded;
                    context.push(DashBoardRoutes.nodeStatus, extra: {
                      "userId": controllerContext.userId,
                      "controllerId": controllerContext.controllerId,
                      "subuserId": controllerContext.subUserId,
                      "deviceId": controllerContext.deviceId,
                      "motorStatus": controllerEntity.motorStatus,
                    });
                  },
                  child: controllerEntity.liveMessage.motorOnOff == "1"
                      ? Image.asset('assets/images/common/valve_running.gif',
                      width: 70, fit: BoxFit.contain)
                      : Image.asset('assets/images/common/valve_off.png',
                      width: 70, fit: BoxFit.contain),
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
                  iconBackgroundColor: const Color(0xffB1E4AA),
                  iconColor: Theme.of(context).colorScheme.primary,
                  icon: Image.asset('assets/images/icons/program_icon.png',
                      width: 20),
                ),
                IconButton(
                    onPressed: () {
                      final controllerContext = context
                          .read<ControllerContextCubit>()
                          .state as ControllerContextLoaded;
                      context.push(DashBoardRoutes.programPreview,
                          extra: controllerContext.deviceId);
                    },
                    icon: const Icon(Icons.visibility_sharp,
                        color: Colors.black)),
                const Spacer(),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    final controllerContext = context
                        .read<ControllerContextCubit>()
                        .state as ControllerContextLoaded;
                    context.read<DashboardPageCubit>().updateChangeFrom(
                        userId: controllerContext.userId,
                        controllerId: controllerContext.controllerId,
                        programId: SafeParser.getProgramId(
                            liveMessageEntity.programName),
                        deviceId: controllerContext.deviceId,
                        payload: 'CHANGEFROM$value');
                  },
                  constraints: const BoxConstraints(maxHeight: 200),
                  itemBuilder: (context) {
                    return getZoneNumberOfActiveProgram(
                        controllerEntity: controllerEntity,
                        liveMessageEntity: liveMessageEntity)
                        .map((e) => PopupMenuItem<String>(
                        value: e, child: Text('Block $e')))
                        .toList();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border:
                      Border.all(color: const Color(0xff0F8AD0)),
                      color: const Color(0xffE6F7FF),
                    ),
                    child: Row(
                      children: [
                        Text('Block ${liveMessageEntity.zoneNo}',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black)),
                        const Icon(Icons.keyboard_arrow_down,
                            color: Colors.black)
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
                    bool programAvailable =
                        controllerEntity.programList.length >= (index + 1);
                    bool programStatus =
                        SafeParser.getProgramId(liveMessageEntity.programName) ==
                            '${index + 1}';
                    return GestureDetector(
                      onTap: () {
                        context.push(
                            '${EditProgramRoutes.program}?programId=${index + 1}');
                      },
                      child: Column(
                        spacing: 10,
                        children: [
                          StaticProgressCircleWithImage(
                            progress: programStatus
                                ? (SafeParser.parseDouble(
                                liveMessageEntity.programPercentage) /
                                100)
                                : 0.0,
                            size: 70,
                            progressColor: programAvailable
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey,
                            backgroundColor: Colors.grey.shade300,
                            strokeWidth: 5,
                            edgeWidget: programStatus
                                ? Text(
                              '${liveMessageEntity.programPercentage}%',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 8,
                                  color: Colors.blue),
                            )
                                : null,
                            edgeIcon: Icons.bolt,
                            iconColor: programAvailable
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey,
                            iconSize: 15,
                            centerWidget: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                  'assets/images/common/sprinkler.png'),
                            ),
                          ),
                          Text('Program ${index + 1}',
                              style: Theme.of(context).textTheme.bodySmall),
                          CustomSwitch(
                            value: programStatus,
                            onChanged: (value) {
                              context.push(DashBoardRoutes.programCommonSettings
                                  .replaceAll(':settingName',
                                  'Program Common Settings')
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
      if (liveMessageEntity.wellPercent != "00" &&
          liveMessageEntity.wellPercent != "0")
        dashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              iconWithHeader(
                title: 'Water Level',
                iconBackgroundColor: const Color(0xffB4E7FF),
                iconColor: Theme.of(context).colorScheme.primary,
                icon: Icon(Icons.cloudy_snowing,
                    color: Theme.of(context).colorScheme.primary),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/images/common/water_level.png',
                      width: 80),
                  moonCard(
                    moonColor: const Color(0xffD4EAFF),
                    skyColor: const Color(0xffE6F7FF),
                    title: 'Max Level',
                    value:
                    '${SafeParser.parseDouble(liveMessageEntity.wellLevel).toStringAsFixed(1)} Feet',
                  ),
                  moonCard(
                    moonColor: const Color(0xffD4EAFF),
                    skyColor: const Color(0xffE6F7FF),
                    title: 'Current Level',
                    value:
                    '${SafeParser.parseDouble(liveMessageEntity.wellPercent).toStringAsFixed(0)}%',
                  ),
                ],
              )
            ],
          ),
        ),
      dashboardCard(
        child: Column(
          spacing: 20,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            iconWithHeader(
              title: 'Latest Message',
              iconBackgroundColor: const Color(0xffB4E7FF),
              iconColor: Theme.of(context).colorScheme.primary,
              icon: Icon(Icons.message,
                  color: Theme.of(context).colorScheme.primary),
            ),
            Text(controllerEntity.msgDesc,
                style: const TextStyle(
                    fontSize: 16, color: Color(0xff424242))),
            ReadMoreText(
              controllerEntity.ctrlLatestMsg,
              trimLines: 2,
              trimMode: TrimMode.Line,
              trimCollapsedText: ' Show more',
              trimExpandedText: ' Show less',
              style:
              const TextStyle(fontSize: 16, color: Color(0xff424242)),
              moreStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor),
              lessStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor),
            )
          ],
        ),
      ),
      const SizedBox(height: 100)
    ];
  }

  List<String> getZoneNumberOfActiveProgram(
      {required ControllerEntity controllerEntity,
        required LiveMessageEntity liveMessageEntity}) {
    List<String> zoneNumbers = [];
    final activeProgramId =
    SafeParser.getProgramId(liveMessageEntity.programName);
    for (var program = 0;
    program < controllerEntity.programList.length;
    program++) {
      final programId =
      controllerEntity.programList[program].programId.toString();
      if (activeProgramId == programId) {
        zoneNumbers = controllerEntity.programList[program].listOfZone
            .map((e) => e.zoneNumber)
            .toList();
      }
    }
    return zoneNumbers;
  }

  String _formatTime12H(String? time) {
    if (time == null ||
        time.isEmpty ||
        time == '--' ||
        time == '00:00:00') {
      return time ?? '--';
    }
    try {
      List<String> parts = time.trim().split(' ');
      String timePart = parts.length > 1 ? parts[1] : parts[0];
      String datePart = parts.length > 1 ? parts[0] : "";
      final timeSegments = timePart.split(':');
      if (timeSegments.length < 2) return time;
      int hour = int.parse(timeSegments[0]);
      int minute = int.parse(timeSegments[1]);
      String period = hour >= 12 ? 'PM' : 'AM';
      int h12 = hour % 12;
      if (h12 == 0) h12 = 12;
      String formattedTime =
          "${h12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period";
      return datePart.isNotEmpty ? "$datePart $formattedTime" : formattedTime;
    } catch (e) {
      return time;
    }
  }

  String getDate({required LiveMessageEntity liveData}) {
    try {
      if (liveData.cd.isEmpty) return '---';
      return DateFormat("d/MMM/yyyy")
          .format(DateTime(
          int.parse(liveData.cd.split('/')[2]),
          int.parse(liveData.cd.split('/')[1]),
          int.parse(liveData.cd.split('/')[0])))
          .toUpperCase();
    } catch (e) {
      if (kDebugMode) {
        kdebugmode(e.toString());
      }
      return '---';
    }
  }

  Widget doublePumpWidget(
      {required ControllerEntity controllerEntity,
        required LiveMessageEntity liveMessageEntity}) {
    final bool isMotorOn = liveMessageEntity.motor2OnOff == '1' ||
        (controllerEntity.modelId == 27 &&
            liveMessageEntity.valveOnOff == '1');
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
                      iconBackgroundColor: isMotorOn
                          ? const Color(0xffB1E4AA)
                          : const Color(0xffFFCDD2),
                      iconColor: isMotorOn ? Colors.green : Colors.red,
                      titleColor: isMotorOn ? Colors.green : Colors.red,
                      icon: Image.asset(
                        'assets/images/common/motor_icon.png',
                        width: 20,
                        color: isMotorOn ? Colors.green : Colors.red,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (controllerEntity.modelId == 27)
                      ...[
                        Column(
                          spacing: 15,
                          children: [
                            Image.asset(
                              liveMessageEntity.motorOnOff == '1'
                                  ? 'assets/images/common/motor_running.gif'
                                  : 'assets/images/common/motor_r.png',
                              width: 80,
                            ),
                            switches(
                                liveMessageEntity: liveMessageEntity,
                                motorNo: 1)
                          ],
                        ),
                        Column(
                          spacing: 15,
                          children: [
                            Image.asset(
                              liveMessageEntity.motor2OnOff == '1'
                                  ? 'assets/images/common/motor_running.gif'
                                  : 'assets/images/common/motor_r.png',
                              width: 80,
                            ),
                            switches(
                                liveMessageEntity: liveMessageEntity,
                                motorNo: 2)
                          ],
                        ),
                      ]
                    else
                      ...[
                        Image.asset(
                          liveMessageEntity.motorOnOff == '1'
                              ? 'assets/images/common/motor_running.gif'
                              : 'assets/images/common/motor_r.png',
                          width: 80,
                        ),
                        switches(
                            liveMessageEntity: liveMessageEntity, motorNo: 1)
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

  List<Widget> stackRadius() {
    List<Color> shades = [
      Colors.green.shade400,
      Colors.green.shade600,
      Colors.green.shade800,
    ];
    return List.generate(3, (index) {
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

  // switches() now uses GlowButton — motor1 glows green when ON, red when OFF
  Widget switches(
      {required LiveMessageEntity liveMessageEntity, required int motorNo}) {
    kdebugmode("Call switches");
    kdebugmode("deviceid:$liveMessageEntity");

    final bool isOn = motorNo == 2
        ? liveMessageEntity.motor2OnOff == '1'
        : liveMessageEntity.motorOnOff == '1';

    return Row(
      children: [
        // ── Glow ON button ─────────────────────────────────────────────────
        GlowButton(
          isActive: isOn,
          activeColor: const Color(0xff4DB53D),
          inactiveColor: Colors.green.shade200,
          label: 'ON',
          icon: const Icon(Icons.power_settings_new),
          onPressed: () {
            final controllerContext = context
                .read<ControllerContextCubit>()
                .state as ControllerContextLoaded;
            final payload =
            motorNo == 2 ? 'MOTOR2ON,' : 'MOTOR1ON,';
            context.read<DashboardPageCubit>().controlMotorStatus(
                userId: controllerContext.userId,
                controllerId: controllerContext.controllerId,
                programId: SafeParser.getProgramId(
                    liveMessageEntity.programName),
                deviceId: controllerContext.deviceId,
                payload: payload);
          },
        ),
        // ── Glow OFF button ────────────────────────────────────────────────
        GlowButton(
          isActive: !isOn,
          activeColor: const Color(0xffE9352B),
          inactiveColor: Colors.red.shade200,
          label: 'OFF',
          icon: const Icon(Icons.power_settings_new),
          onPressed: () {
            final controllerContext = context
                .read<ControllerContextCubit>()
                .state as ControllerContextLoaded;
            context.read<DashboardPageCubit>().controlMotorStatus(
                userId: controllerContext.userId,
                controllerId: controllerContext.controllerId,
                programId: SafeParser.getProgramId(
                    liveMessageEntity.programName),
                deviceId: controllerContext.deviceId,
                payload: 'MTROF,');
          },
        ),
      ],
    );
  }

  Widget rybWidget({
    required Color backgroundColor,
    required String value,
    required String phase,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), color: backgroundColor),
      child: Column(
        spacing: 5,
        children: [
          Text(phase,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 14)),
          IntrinsicWidth(
              child: Container(width: 60, height: 0.8, color: Colors.white)),
          Text('$value V',
              style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
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
    Color? titleColor,
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
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: titleColor)),
            if (subTitle != null)
              Text(subTitle, style: Theme.of(context).textTheme.bodySmall),
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
      decoration:
      BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(9)),
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
              child: Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          Center(
            child: Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
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
      decoration:
      BoxDecoration(borderRadius: BorderRadius.circular(10), color: moonColor),
      child: Stack(
        children: [
          Positioned(
            left: -130,
            top: -120,
            child: CircleAvatar(radius: 100, backgroundColor: skyColor),
          ),
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 14)),
                Text(value,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black45)),
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

// ---------------------------------------------------------------------------
// WLC BLE scanning / connecting / error / reconnect screen
// Shown for modelId == 4 until BLE is connected AND first live packet arrives.
// ---------------------------------------------------------------------------
class _WlcBleScreen extends StatefulWidget {
  final String deviceId;
  final BleState bleState;

  const _WlcBleScreen({
    required this.deviceId,
    required this.bleState,
  });

  @override
  State<_WlcBleScreen> createState() => _WlcBleScreenState();
}

class _WlcBleScreenState extends State<_WlcBleScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Auto-trigger connect when screen first appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bleState = context.read<BleCubit>().state;
      if (bleState is BleIdle ||
          bleState is BleDisconnected ||
          bleState is BleError) {
        context.read<BleCubit>().connect(widget.deviceId);
      }
    });
  }

  @override
  void didUpdateWidget(_WlcBleScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAnimation(widget.bleState);
  }

  void _syncAnimation(BleState state) {
    if (state is BleScanning || state is BleConnecting) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BleState state = widget.bleState;
    _syncAnimation(state);

    final bool isBusy = state is BleScanning || state is BleConnecting;
    final bool isError = state is BleError;

    // ── Visual config per state ──────────────────────────────────────────────
    final Color primaryColor = isError
        ? const Color(0xffC62828)
        : isBusy
        ? const Color(0xff1565C0)
        : const Color(0xff424242);

    final IconData stateIcon = isError
        ? Icons.bluetooth_disabled
        : isBusy
        ? Icons.bluetooth_searching
        : Icons.bluetooth;

    final String title = state is BleScanning
        ? 'Scanning for Device'
        : state is BleConnecting
        ? 'Connecting…'
        : state is BleError
        ? 'Connection Failed'
        : 'Bluetooth Disconnected';

    final String subtitle = state is BleScanning
        ? 'Looking for NIA_${widget.deviceId}'
        : state is BleConnecting
        ? 'Establishing BLE connection…'
        : state is BleError
        ? (state as BleError).message
        : 'Device is not connected via Bluetooth.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Animated BLE icon ────────────────────────────────────────────
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: isBusy ? _pulseAnimation.value : 1.0,
                  child: child,
                );
              },
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withOpacity(0.1),
                  border: Border.all(color: primaryColor.withOpacity(0.4), width: 2),
                ),
                child: Center(
                  child: Icon(stateIcon, size: 56, color: primaryColor),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ── Status title ─────────────────────────────────────────────────
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),

            const SizedBox(height: 10),

            // ── Subtitle / error message ──────────────────────────────────────
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 12),

            // ── Device ID chip ────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.memory, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Text(
                    'Device: ${widget.deviceId}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // ── Spinner or action button ──────────────────────────────────────
            if (isBusy)
              Column(
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state is BleScanning
                        ? 'This may take up to 15 seconds…'
                        : 'Please keep the device nearby',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              )
            else
              ElevatedButton.icon(
                onPressed: () =>
                    context.read<BleCubit>().connect(widget.deviceId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isError
                      ? const Color(0xffC62828)
                      : const Color(0xff1565C0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                icon: Icon(isError ? Icons.refresh : Icons.bluetooth),
                label: Text(
                  isError ? 'Retry Connection' : 'Connect',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
      ),
    );
  }
}