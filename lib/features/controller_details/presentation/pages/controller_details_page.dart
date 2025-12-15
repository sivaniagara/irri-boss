import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/di/injection.dart' as di;
import '../../../setserialsettings/domain/usecase/setserial_details_params.dart';
import '../../../setserialsettings/presentation/pages/setserial_page.dart';
import '../../domain/usecase/controller_details_params.dart';
import '../bloc/controller_details_bloc.dart';
import '../bloc/controller_details_bloc_event.dart';
import '../bloc/controller_details_state.dart';

import '../widgets/ctrlDetails_infoRow.dart';
import '../widgets/ctrlDetails_switchRow.dart';
import '../widgets/ctrlDetails_actionbtn.dart';
import '../widgets/ctrldetails_header_section.dart';
import '../widgets/commondropdown.dart';

class ControllerDetailsPage extends StatelessWidget {
  final GetControllerDetailsParams params;

  const ControllerDetailsPage({
    super.key,
    required this.params,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<ControllerDetailsBloc>()
        ..add(GetControllerDetailsEvent(
          userId: params.userId,
          controllerId: params.controllerId,
        )),
      child: BlocBuilder<ControllerDetailsBloc, ControllerDetailsState>(
        builder: (context, state) {
          return _buildBody(context, state);
        },
      ),
    );
  }


  Widget _buildBody(BuildContext context, ControllerDetailsState state) {
    if (state is ControllerDetailsInitial || state is ControllerDetailsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ControllerDetailsError) {
      return Center(
        child: Text(
          "Error: ${state.message}",
          style: const TextStyle(color: Colors.white),
        ),
      );
    }

    if (state is ControllerDetailsLoaded) {
      final controller = state.data;               // ControllerDetailsEntities
      final groupList = state.groupDetails;          // List<GroupDetails>

      TextEditingController simController = TextEditingController(text: controller.simNumber);
      TextEditingController countrycodeController = TextEditingController(text: controller.customerCountryCode);
      TextEditingController devicenameController = TextEditingController(text: controller.deviceName);

      // String selectedCountry = "+${controller.mobileCountryCode}";

      String selectedCountry = "+91";

      return Scaffold(
        backgroundColor: const Color(0xFF0A4D68),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0A4D68),
          centerTitle: true,
          title: const Text(
            "CONTROLLER DETAILS",
            style: TextStyle(color: Colors.white),
          ),
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: ControllerSectionHeader(title: "Controller Details"),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      context.pushNamed(
                        'setSerialPage',
                        extra: SetSerialParams(userId: params.userId, controllerId: params.controllerId,type: 1),
                      );
                    },
                    child: const Center(
                      child: Text("Set Serial"),
                    ),
                  ),
                  SizedBox(width: 20,),
                  GestureDetector(
                    onTap: () {
                      context.pushNamed(
                        'setSerialPage',
                        extra: SetSerialParams(userId: params.userId, controllerId: params.controllerId,type: 2),
                      );
                    },
                    child: const Center(
                      child: Text("Common Calibration"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: controller.deviceId));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Copied to clipboard")),
                  );
                },
                child: ControllerInfoRow(
                  label: "Device ID",
                  value: controller.deviceId,
                ),
              ),
              const SizedBox(height: 16),

                  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Group Name", style: TextStyle(color: Colors.white70)),
                    DropdownButton<String>(
                      dropdownColor: const Color(0xFF0A4D68),
                      value: controller.groupName,
                      items: groupList.map((g) {
                        return DropdownMenuItem(
                          value: g.groupName,
                          child: Text(g.groupName, style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        // Add event if you want update API
                      },
                    ),
                  ],

              ),

              const SizedBox(height: 16),
              TextField(
                controller: devicenameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Device Name",
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white38),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
               const SizedBox(height: 20),
                Row(
                children: [
                  Container(width: 100,
                    child: TextField(
                      controller: countrycodeController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "Country Code",
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white38),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.lightBlueAccent),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: simController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "SIM Number",
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white38),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.lightBlueAccent),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

               ControllerInfoRow(
                label: "Operation Mode",
                valueWidget: IconButton(
                  icon: const Icon(Icons.visibility, color: Colors.white),
                  onPressed: () {},
                ),
              ),

              ControllerInfoRow(
                label: "WiFi Reset",
                valueWidget: IconButton(
                  icon: const Icon(Icons.wifi_protected_setup_sharp, color: Colors.white),
                  onPressed: () {},
                ),
              ),
              //------------------------------------------------
              ControllerSwitchRow(
                title: "INTERNET 4G",
                value: controller.gprsMode == "4",
                onChanged: (val) {
                  context.read<ControllerDetailsBloc>().add(
                    ToggleSwitchEvent(
                       switchName: "gprsMode",
                      isOn: val,
                    ),
                  );
                },
              ),

              ControllerSwitchRow(
                title: "INTERNET 2G/3G & WiFi",
                value: controller.gprsMode != "4",
                onChanged: (val) {
                  context.read<ControllerDetailsBloc>().add(
                    ToggleSwitchEvent(
                       switchName: "gprsMode",
                      isOn: !val,        // reverse logic
                    ),
                  );
                },
              ),

        ControllerSwitchRow(
          title: "DND",
          value: controller.dndStatus == "1",
          onChanged: (val) {
            context.read<ControllerDetailsBloc>().add(
              ToggleSwitchEvent(
                 switchName: "dndStatus",
                isOn: val,
              ),
            );
          },
        ),
              const SizedBox(height: 20),
              ControllerInfoRow(label: "Dealer Name", value: controller.dealerName),
              ControllerInfoRow(label: "Model", value: controller.modelName),
              ControllerInfoRow(label: "Customer Name", value: controller.customerName),
              ControllerInfoRow(label: "Customer Number", value: controller.customerNumber),

              const SizedBox(height: 24),

              ControllerActionButtons(
                buttons: [
                  ControllerButtonData(
                    title: "Submit",
                    color: Colors.blue,
                    onPressed: () {
                      final bloc = context.read<ControllerDetailsBloc>();
                       bloc.add(
                        UpdateControllerEvent(
                          userId: '${params.userId}',
                          controllerId: params.controllerId,
                          countryCode: countrycodeController.text,
                          simNumber: simController.text,
                          deviceName: devicenameController.text,
                          groupId: groupList.firstWhere((g) => g.groupName == controller.groupName).userGroupId,
                          operationMode: controller.operationMode,
                          gprsMode: controller.gprsMode,
                          appSmsMode: controller.appSmsMode,
                          sentSms: "",
                          editType: "0",
                        ),
                      );
                    },
                  ),
                  ControllerButtonData(
                    title: "Replace",
                    color: Colors.orange,
                    onPressed: () {},
                  ),
                  ControllerButtonData(
                    title: "Delete",
                    color: Colors.red,
                    onPressed: () {},
                  ),
                  ControllerButtonData(
                    title: "Cancel",
                    color: Colors.grey,
                    onPressed: () {},
                  ),
                ],
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      );
    }

    return const Scaffold(
      backgroundColor: Color(0xFF0A4D68),
      body: Center(
        child: Text(
          "Unexpected Error",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
