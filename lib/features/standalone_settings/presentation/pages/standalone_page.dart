import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/app_alerts.dart';

import 'package:niagara_smart_drip_irrigation/features/standalone_settings/presentation/bloc/standalone_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/standalone_settings/presentation/bloc/standalone_state.dart';
import 'package:niagara_smart_drip_irrigation/features/standalone_settings/presentation/bloc/standalone_event.dart';
import 'package:niagara_smart_drip_irrigation/features/standalone_settings/presentation/widgets/standalone_header.dart';
import 'package:niagara_smart_drip_irrigation/features/standalone_settings/presentation/widgets/zone_item.dart';
import 'package:niagara_smart_drip_irrigation/features/standalone_settings/utils/standalone_routes.dart';

class StandalonePage extends StatelessWidget {
  final Map<String, dynamic> data;

  const StandalonePage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final String controllerId = data['controllerId']?.toString() ?? '';
    final String userId = data['userId']?.toString() ?? '';
    final String deviceId = data['deviceId']?.toString() ?? '';
    final String subUserId = data['subUserId']?.toString() ?? '0';

    return Container(
      color: const Color(0xffF5F7FA),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Custom Tab Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "STANDALONE",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        context.go(StandaloneRoutes.configuration, extra: data);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        color: Colors.transparent,
                        alignment: Alignment.center,
                        child: const Text(
                          "CONFIGURATION",
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Main Content
          Expanded(
            child: BlocConsumer<StandaloneBloc, StandaloneState>(
              listener: (context, state) {
                if (state is StandaloneSuccess) {
                  showSuccessAlert(context: context, message: state.message);
                } else if (state is StandaloneError) {
                  showErrorAlert(context: context, message: state.message);
                }
              },
              builder: (context, state) {
                if (state is StandaloneLoading) {
                  return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
                } else if (state is StandaloneLoaded || state is StandaloneSuccess) {
                  final standaloneData = (state is StandaloneLoaded)
                      ? (state as StandaloneLoaded).data
                      : (state as StandaloneSuccess).data;

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // Standalone Settings Card
                      _buildCard(
                        context,
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              alignment: Alignment.center,
                              child: Text(
                                standaloneData.programName,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const Divider(height: 1),
                            StandaloneHeader(
                              title: "STANDALONE MODE",
                              isOn: standaloneData.settingValue == "1",
                              onChanged: (v) {
                                context.read<StandaloneBloc>().add(ToggleStandalone(
                                  userId: userId,
                                  controllerId: controllerId,
                                  deviceId: deviceId,
                                  subUserId: subUserId,
                                  menuId: "2",
                                  settingsId: "59",
                                  value: v,
                                ));
                              },
                              onSend: () {
                                context.read<StandaloneBloc>().add(
                                  SendStandaloneConfigEvent(
                                    userId: userId,
                                    controllerId: controllerId,
                                    deviceId: deviceId,
                                    subUserId: subUserId,
                                    menuId: "2",
                                    settingsId: "59",
                                    successMessage: "Settings updated successfully",
                                    sendType: StandaloneSendType.mode,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Zones Card
                      _buildCard(
                        context,
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            ...standaloneData.zones.asMap().entries.map((entry) {
                              return ZoneItem(index: entry.key, zone: entry.value);
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.read<StandaloneBloc>().add(
                              SendStandaloneConfigEvent(
                                userId: userId,
                                controllerId: controllerId,
                                deviceId: deviceId,
                                subUserId: subUserId,
                                menuId: "2",
                                settingsId: "59",
                                successMessage: "Zones configured successfully",
                                sendType: StandaloneSendType.zones,
                              ),
                            );
                          },
                          icon: const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                          label: const Text("SEND ZONES", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Drip Standalone Card
                      _buildCard(
                        context,
                        child: StandaloneHeader(
                          title: "DRIP STANDALONE",
                          isOn: standaloneData.dripSettingValue == "1",
                          onChanged: (v) {
                            context.read<StandaloneBloc>().add(ToggleDripStandalone(
                              userId: userId,
                              controllerId: controllerId,
                              deviceId: deviceId,
                              subUserId: subUserId,
                              menuId: "2",
                              settingsId: "59",
                              value: v,
                            ));
                          },
                          onSend: () {
                            context.read<StandaloneBloc>().add(
                              SendStandaloneConfigEvent(
                                userId: userId,
                                controllerId: controllerId,
                                deviceId: deviceId,
                                subUserId: subUserId,
                                menuId: "2",
                                settingsId: "59",
                                successMessage: "Drip settings updated",
                                sendType: StandaloneSendType.drip,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                } else if (state is StandaloneError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox();
              },
            ),
          ),
          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                    child: Text(
                      "Go Back",
                      style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<StandaloneBloc>().add(
                        ViewStandaloneEvent(
                          userId: userId,
                          controllerId: controllerId,
                          subUserId: subUserId,
                          deviceId: deviceId,
                          successMessage: "Sending View Standalone...",
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text(
                      "VIEW",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      padding: padding ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: child,
      ),
    );
  }
}
