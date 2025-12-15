import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/di/injection.dart' as di;

import '../bloc/setserial_bloc.dart';
import '../bloc/setserial_bloc_event.dart';
import '../bloc/setserial_state.dart';

class SerialSetCalibrationPage extends StatelessWidget {
  final int userId;
  final int controllerId;
  final int type;

  const SerialSetCalibrationPage({
    super.key,
    required this.userId,
    required this.controllerId,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<SetSerialBloc>()
        ..add(LoadSerialEvent(userId: 153, controllerId: 938)),
      child:  Scaffold(
        backgroundColor: const Color(0xFF0A4D68),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0A4D68),
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
                  return const Center(
                    child: Text(
                      "No Nodes Available",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  );
                }
        
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: state.nodeList.length,
                        itemBuilder: (context, index) {
                          print(state.nodeList);
                          final node = state.nodeList[index];
        
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                            ),
        
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                /// QR CODE
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    node.qrCode ?? "",
                                    style: const TextStyle(
                                      color: Colors.white,
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
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                type == 1 ? SizedBox() :  Expanded(
                                  flex: 2,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: "Enter value",
                                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      // Bottom border when not focused
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white),
                                      ),
                                      // Bottom border when focused
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white, width: 2),
                                      ),
                                    ),
                                    style: TextStyle(color: Colors.white), // Text color
                                    cursorColor: Colors.white, // Cursor color
                                  ),
                                ),
        
                                /// VIEW ICON
                                IconButton(
                                  icon: const Icon(Icons.visibility,
                                      color: Colors.white),
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
        
                                /// SEND ICON
                                IconButton(
                                  icon: const Icon(Icons.send,
                                      color: Colors.white),
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
                          );
                        },
                      ),
                    ),
        
                    const SizedBox(height: 15),
        
                    /// ---------- CANCEL BUTTON ----------
                   type == 1 ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Clear Serial Set",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ) : SizedBox(),
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

    );
  }
}
