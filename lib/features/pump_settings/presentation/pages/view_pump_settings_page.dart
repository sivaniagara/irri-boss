import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glass_effect.dart';
import '../../../../core/di/injection.dart' as di;
import '../../../../core/services/mqtt/app_message_dispatcher.dart';
import '../../../../core/widgets/glassy_wrapper.dart';
import '../../utils/pump_settings_dispatcher.dart';
import '../cubit/view_pump_settings_cubit.dart';
import '../widgets/setting_list_tile.dart';

class ViewPumpSettingsPage extends StatelessWidget {
  final String deviceId;
  final int userId;
  final int subuserId;
  final int controllerId;

  const ViewPumpSettingsPage({
    super.key,
    required this.deviceId,
    required this.userId,
    required this.subuserId,
    required this.controllerId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = ViewPumpSettingsCubit();
        final dispatcher = PumpSettingsDispatcher(cubit);
        di.sl<AppMessageDispatcher>().pumpSettings = dispatcher;

        cubit.loadSettingLabels(userId, subuserId, controllerId);

        return cubit;
      },
      child: _ViewPumpSettingsView(
        deviceId: deviceId,
        userId: userId,
        controllerId: controllerId,
        subuserId: subuserId,
      ),
    );
  }
}

class _ViewPumpSettingsView extends StatelessWidget {
  final String deviceId;
  final int userId;
  final int subuserId;
  final int controllerId;

  const _ViewPumpSettingsView({
    required this.deviceId,
    required this.userId,
    required this.subuserId,
    required this.controllerId,
  });

  @override
  Widget build(BuildContext context) {
    return GlassyWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("View Settings"),
        ),
        body: BlocBuilder<ViewPumpSettingsCubit, ViewPumpSettingsState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text("Loading settings..."),
                  ],
                ),
              );
            }

            if (state.errorMessage != null || state.settingsJson == null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text("Controller is not responding", style: const TextStyle(color: Colors.red)),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.read<ViewPumpSettingsCubit>().requestSettings(
                        deviceId,
                        userId,
                        controllerId,
                        subuserId,
                      ),
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              );
            }

            if (state.settingLabels == null || state.settingLabels!.isEmpty) {
              return const Center(child: Text("No templates available"));
            }

            final excludedIds = {508, 509, 510, 512};
            final filteredLabels = state.settingLabels!
                .where((template) => !excludedIds.contains(template['menuSettingId']))
                .toList();

            if (filteredLabels.isEmpty) {
              return const Center(child: Text("No available templates"));
            }

            final List<String> allValues = state.settingsJson!.split(',');

            final List<int> templateSettingCounts = [];
            for (final template in filteredLabels) {
              final int menuId = int.tryParse(template['menuSettingId'].toString()) ?? 0;
              Map<String, dynamic> config;

              if (menuId == 507) {
                config = {
                  "setting": [
                    {
                      "NAME": "Signal & Connection Status",
                      "SETS": [
                        {"SN": 1, "TT": "Signal Strength"},
                        {"SN": 2, "TT": "Mqtt Connection"},
                        {"SN": 3, "TT": "Data connection"},
                        {"SN": 4, "TT": "Communication Mode"},
                      ]
                    },
                    {
                      "NAME": "WIFI Settings",
                      "SETS": [
                        {"SN": 1, "TT": "WIFI SSID"},
                        {"SN": 2, "TT": "WIFI PASSWORD"},
                        {"SN": 3, "TT": "WLAN IP"},
                        {"SN": 4, "TT": "WLAN PORT NUMBER"},
                      ]
                    },
                    {
                      "NAME": "Mobile / APN Settings",
                      "SETS": [
                        {"SN": 1, "TT": "MY WIFI SSID"},
                        {"SN": 2, "TT": "MY WIFI PASSWORD"},
                        {"SN": 3, "TT": "MY WIFI IP"},
                        {"SN": 4, "TT": "MY WIFI PORT NUMBER"},
                        {"SN": 5, "TT": "APN"},
                      ]
                    },
                  ]
                };
              } else {
                try {
                  config = jsonDecode(template['templateJson']) as Map<String, dynamic>;
                } catch (e) {
                  templateSettingCounts.add(0);
                  continue;
                }
              }

              int visibleCount = 0;
              for (final section in config['setting']) {
                final List<dynamic> sets = section['SETS'] ?? [];
                for (final set in sets) {
                  final String rawTitle = (set['TT']?.toString() ?? '').trim();
                  if (rawTitle.isEmpty) continue;

                  bool skip = false;
                  if (menuId == 505) {
                    final int? tid = int.tryParse(section['TID']?.toString() ?? '');
                    final int? sn = int.tryParse(set['SN']?.toString() ?? '');

                    if (tid == 1 && sn != null && [3, 4].contains(sn)) skip = true;
                    if (tid == 2 && sn != null && [1, 2].contains(sn)) skip = true;
                  }

                  if (!skip) visibleCount++;
                }
              }
              templateSettingCounts.add(visibleCount);
            }

            final List<int> cumulativeOffsets = [];
            int offset = 0;
            for (int count in templateSettingCounts) {
              cumulativeOffsets.add(offset);
              offset += count;
            }

            int selectedIndex = 0;

            return StatefulBuilder(
              builder: (context, setStateLocal) {
                final int startOffset = cumulativeOffsets[selectedIndex];
                final int settingsCount = templateSettingCounts[selectedIndex];

                final List<String> templateValues = settingsCount > 0
                    ? allValues.sublist(startOffset, startOffset + settingsCount)
                    : <String>[];

                final selectedTemplate = filteredLabels[selectedIndex];
                final int currentMenuSettingId =
                    int.tryParse(selectedTemplate['menuSettingId'].toString()) ?? 0;

                late Map<String, dynamic> templateConfig;

                // Use static config for 507, otherwise parse from JSON
                if (currentMenuSettingId == 507) {
                  templateConfig = {
                    "setting": [
                      {
                        "NAME": "Signal & Connection Status",
                        "SETS": [
                          {"SN": 1, "TT": "Signal Strength"},
                          {"SN": 2, "TT": "Mqtt Connection"},
                          {"SN": 3, "TT": "Data connection"},
                          {"SN": 4, "TT": "Communication Mode"},
                        ]
                      },
                      {
                        "NAME": "WIFI Settings",
                        "SETS": [
                          {"SN": 1, "TT": "WIFI SSID"},
                          {"SN": 2, "TT": "WIFI PASSWORD"},
                          {"SN": 3, "TT": "WLAN IP"},
                          {"SN": 4, "TT": "WLAN PORT NUMBER"},
                        ]
                      },
                      {
                        "NAME": "Mobile / APN Settings",
                        "SETS": [
                          {"SN": 1, "TT": "MY WIFI SSID"},
                          {"SN": 2, "TT": "MY WIFI PASSWORD"},
                          {"SN": 3, "TT": "MY WIFI IP"},
                          {"SN": 4, "TT": "MY WIFI PORT NUMBER"},
                          {"SN": 5, "TT": "APN"},
                        ]
                      },
                    ]
                  };
                } else {
                  try {
                    templateConfig = jsonDecode(selectedTemplate['templateJson'])
                    as Map<String, dynamic>;
                  } catch (e) {
                    return const Center(child: Text("Invalid template configuration"));
                  }
                }

                final List<Map<String, dynamic>> visibleSettings = [];
                int valueIndex = 0;

                for (final section in templateConfig['setting']) {
                  final List<dynamic> sets = section['SETS'];

                  for (final set in sets) {
                    final String rawTitle = set['TT'];
                    if (rawTitle.isEmpty) continue;

                    if (currentMenuSettingId == 505) {
                      final int tid = section['TID'];
                      final int sn = set['SN'];

                      if (tid == 1 && [3, 4].contains(sn)) continue;
                      if (tid == 2 && [1, 2].contains(sn)) continue;
                    }

                    visibleSettings.add({
                      'setting': set,
                      'valueIndex': valueIndex++,
                      'sectionTitle': section['NAME'],
                    });
                  }
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: DropdownButton<int>(
                        isExpanded: true,
                        value: selectedIndex,
                        hint: const Text("Select Configuration Template"),
                        items: filteredLabels.asMap().entries.map((e) {
                          return DropdownMenuItem(
                            value: e.key,
                            child: Text(
                              e.value['menuItem'] ?? 'Template ${e.key + 1}',
                              style: const TextStyle(color: Colors.black),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setStateLocal(() => selectedIndex = value);
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: visibleSettings.isEmpty
                          ? const Center(child: Text("No settings to display"))
                          : RefreshIndicator(
                        onRefresh: () async {
                          context.read<ViewPumpSettingsCubit>().requestSettings(
                            deviceId,
                            userId,
                            controllerId,
                            subuserId,
                          );
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: visibleSettings.length,
                          itemBuilder: (context, index) {
                            final visibleSetting = visibleSettings[index];
                            final setting = visibleSetting['setting'] as Map<String, dynamic>;
                            final int valueIndex = visibleSetting['valueIndex'] as int;
                            final String sectionTitle = visibleSetting['sectionTitle'];

                            final String value = templateValues[valueIndex];

                            if (index == 0 || visibleSettings[index - 1]['sectionTitle'] != sectionTitle) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                    const EdgeInsets.fromLTRB(0, 16, 0, 8),
                                    child: Text(
                                      sectionTitle,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                  _buildDedicativeWidget(context, setting, value),
                                ],
                              );
                            }

                            return _buildDedicativeWidget(context, setting, value);
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildDedicativeWidget(BuildContext context, Map<String, dynamic> data, String value) {
    Widget trailing = Text(value, style: Theme.of(context).textTheme.bodyMedium,);
    switch(data['WT']) {
      case 2:
        trailing = Switch(
            value: value.toString() == '1',
            onChanged: null
        );
    }

    if(data['TT'].contains(";")) {
      return GlassCard(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            for(int i = 0; i < data['TT'].split(';').length; i++)
              SettingListTile(
                title: data['TT'].split(';')[i],
                trailing: Text(value.split(data['WT'] == 7 ? ':' : ';')[i], style: Theme.of(context).textTheme.bodyMedium,),
              )
          ],
        ),
      );
    }

    return GlassCard(
      margin: EdgeInsets.symmetric(vertical: 3),
      padding: EdgeInsets.zero,
      child: SettingListTile(
        title: data['TT'],
        trailing: trailing,
      ),
    );
  }
}