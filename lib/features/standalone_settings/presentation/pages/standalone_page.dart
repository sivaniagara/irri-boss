import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/app_alerts.dart';

import 'package:niagara_smart_drip_irrigation/features/standalone_settings/presentation/bloc/standalone_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/standalone_settings/presentation/bloc/standalone_state.dart';
import 'package:niagara_smart_drip_irrigation/features/standalone_settings/presentation/bloc/standalone_event.dart';
import 'package:niagara_smart_drip_irrigation/features/standalone_settings/presentation/widgets/standalone_header.dart';
import 'package:niagara_smart_drip_irrigation/features/standalone_settings/presentation/widgets/zone_item.dart';

class StandalonePage extends StatefulWidget {
  final Map<String, dynamic> data;

  const StandalonePage({super.key, required this.data});

  @override
  State<StandalonePage> createState() => _StandalonePageState();
}

class _StandalonePageState extends State<StandalonePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final String controllerId = widget.data['controllerId']?.toString() ?? '';
    final String userId = widget.data['userId']?.toString() ?? '';
    final String deviceId = widget.data['deviceId']?.toString() ?? '';
    final String subUserId = widget.data['subUserId']?.toString() ?? '0';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () {
          context.read<StandaloneBloc>().add(
            ViewStandaloneEvent(
              userId: userId,
              controllerId: controllerId,
              subUserId: subUserId,
              deviceId: deviceId,
              successMessage: _selectedIndex == 0
                  ? "Sending View Standalone..."
                  : "Sending View Configuration...",
            ),
          );
        },
        child: const Icon(Icons.visibility_outlined, color: Colors.white),
      ),
      body: Column(
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
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = 0;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedIndex == 0 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _selectedIndex == 0 ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ] : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "STANDALONE",
                          style: TextStyle(
                            color: _selectedIndex == 0 ? Theme.of(context).colorScheme.primary : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = 1;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedIndex == 1 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _selectedIndex == 1 ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ] : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "CONFIGURATION",
                          style: TextStyle(
                            color: _selectedIndex == 1 ? Theme.of(context).colorScheme.primary : Colors.grey,
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

                  return _selectedIndex == 0
                      ? _buildStandaloneContent(context, standaloneData, userId, controllerId, deviceId, subUserId)
                      : _buildConfigurationContent(context, standaloneData, userId, controllerId, deviceId, subUserId);
                } else if (state is StandaloneError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox();
              },
            ),
          ),
          // Bottom Navigation Padding
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildStandaloneContent(BuildContext context, dynamic standaloneData, String userId, String controllerId, String deviceId, String subUserId) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
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
  }

  Widget _buildConfigurationContent(BuildContext context, dynamic standaloneData, String userId, String controllerId, String deviceId, String subUserId) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _buildCard(
          context,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                child: Text(
                  "Config Mode",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(height: 1),
              StandaloneHeader(
                title: "CONFIG MODE",
                isOn: standaloneData.settingValue == "1",
                onChanged: (v) {
                  context.read<StandaloneBloc>().add(ToggleStandalone(
                    userId: userId,
                    controllerId: controllerId,
                    deviceId: deviceId,
                    subUserId: subUserId,
                    menuId: "94",
                    settingsId: "500",
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
                      menuId: "94",
                      settingsId: "500",
                      successMessage: "Configuration mode updated",
                      sendType: StandaloneSendType.mode,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
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
                  menuId: "94",
                  settingsId: "500",
                  successMessage: "Zone configuration saved",
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
        const SizedBox(height: 24),
      ],
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
