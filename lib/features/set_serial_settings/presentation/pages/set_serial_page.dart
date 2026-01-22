import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/core/theme/app_themes.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glassy_wrapper.dart';
import '../../../../../core/di/injection.dart' as di;

import '../../../../core/services/mqtt/mqtt_service.dart';
import '../../../../core/widgets/no_data.dart';
import '../bloc/set_serial_bloc.dart';
import '../bloc/set_serial_bloc_event.dart';
import '../bloc/set_serial_state.dart';

class SerialSetCalibrationPage extends StatelessWidget {
  final int userId;
  final int controllerId;
  final int type;
  final String deviceId;

  const SerialSetCalibrationPage({
    super.key,
    required this.userId,
    required this.controllerId,
    required this.type,
    required this.deviceId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<SetSerialBloc>()
        ..add(LoadSerialEvent(userId: 153, controllerId: 938)),
      child:  GlassyWrapper(
        child: Scaffold(
             appBar: AppBar(
               title:  Text(type == 1 ? "SerialSet" : "Common Calibration"),
            ),

            body: BlocConsumer<SetSerialBloc, SetSerialState>(

              listener: (context, state) {
                if (state is SendSerialSuccess ||
                    state is ResetSerialSuccess ||
                    state is ViewSerialSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.toString())),
                  );
                }

                if (state is SendSerialError ||
                    state is ResetSerialError ||
                    state is ViewSerialError ||
                    state is LoadSerialError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.toString())),
                  );
                }
              },

              builder: (context, state) {
                print('state:$state');
                /// ---------- LOADING ----------


                if (state is SetSerialLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                /// ---------- LIST DATA ----------
                if (state is SerialDataLoaded) {
                  if (state.nodeList.isEmpty) {
                    return Center(
                      child: noData,
                    );
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          itemCount: state.nodeList.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10), // space between cards
                          itemBuilder: (context, index) {
                            final node = state.nodeList[index];

                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              child: Container(
                                constraints: const BoxConstraints(minHeight: 70), // row height
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    /// QR CODE
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        node.qrCode ?? "",
                                        style: const TextStyle(
                                          color: AppThemes.primaryColor,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),

                                    /// SERIAL
                                    Expanded(
                                      flex: 2,
                                      child: Center(
                                        child: Text(
                                          node.serialNo ?? "",
                                          style: const TextStyle(
                                            color: AppThemes.primaryColor,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),

                                    /// INPUT (ONLY TYPE != 1)
                                    if (type != 1)
                                      Expanded(
                                        flex: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          child: TextField(
                                            decoration: const InputDecoration(
                                              hintText: "value",
                                              isDense: true,
                                              contentPadding: EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 10,
                                              ),
                                              enabledBorder: UnderlineInputBorder(
                                                borderSide:
                                                BorderSide(color: AppThemes.primaryColor),
                                              ),
                                              focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: AppThemes.primaryColor,
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                            style: const TextStyle(
                                                color: AppThemes.primaryColor),
                                            cursorColor: AppThemes.primaryColor,
                                          ),
                                        ),
                                      ),

                                    /// VIEW
                                    IconButton(
                                      icon: const Icon(Icons.visibility,
                                          color: AppThemes.primaryColor),
                                      iconSize: 26,
                                      padding: const EdgeInsets.all(8),
                                      onPressed: () {
                                        context.read<SetSerialBloc>().add(
                                          ViewSerialEvent(
                                            userId: userId,
                                            controllerId: controllerId,
                                            sentSms: node.qrCode,
                                          ),
                                        );
                                      },
                                    ),

                                    /// SEND
                                    IconButton(
                                      icon: const Icon(Icons.send,
                                          color: AppThemes.primaryColor),
                                      iconSize: 26,
                                      padding: const EdgeInsets.all(8),
                                      onPressed: () {
                                        context.read<SetSerialBloc>().add(
                                          SendSerialEvent(
                                            userId: userId,
                                            controllerId: controllerId,
                                            sentSms: node.qrCode,
                                            sendList: [
                                              {
                                                "QRCode": node.qrCode,
                                                "serialNo": node.serialNo,
                                                "nodeId": node.nodeId,
                                              }
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// ---------- CANCEL BUTTON ----------
                      if (type == 1)
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    minimumSize: const Size(0, 54), // <-- IMPORTANT
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    final mqtt = di.sl.get<MqttService>();
                                    mqtt.publish(
                                      deviceId,
                                      jsonEncode({"sentSms": "#CLEARSERIAL"}),
                                    );
                                   },
                                  child: const Text(
                                    "Clear Serial Set",
                                    style: TextStyle(fontSize: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),

                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppThemes.primaryColor,
                                    minimumSize: const Size(0, 54), // <-- IMPORTANT
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    final mqtt = di.sl.get<MqttService>();
                                    mqtt.publish(
                                      deviceId,
                                      jsonEncode({"sentSms": "#SETSERIAL"}),
                                    );
                                   },
                                  child: const Text(
                                    "SETSERIAL",
                                    style: TextStyle(fontSize: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )

                    ],
                  );
                }
                 /// ---------- DEFAULT ----------
                return const Center(
                  child: Text(
                    "Loading...",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ),
      ),

    );
  }
}
