import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/theme/app_themes.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glassy_wrapper.dart';
import '../../../../core/widgets/no_data.dart';
import '../../../set_serial_settings/domain/usecase/set_serial_details_params.dart';
import '../../domain/usecase/controller_details_params.dart';
import '../bloc/controller_details_bloc.dart';
import '../bloc/controller_details_bloc_event.dart';
import '../bloc/controller_details_state.dart';

import '../widgets/ctrlDetails_infoRow.dart';
import '../widgets/ctrlDetails_switchRow.dart';
import '../widgets/ctrlDetails_actionbtn.dart';
import '../widgets/ctrldetails_header_section.dart';

class ControllerDetailsPage extends StatelessWidget {
  final GetControllerDetailsParams params;

  const ControllerDetailsPage({
    super.key,
    required this.params,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ControllerDetailsBloc, ControllerDetailsState>(
      builder: (context, state) {
        return _buildBody(context, state);
      },
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

      return GlassyWrapper(
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text("CONTROLLER DETAILS"),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 16),
                 // ---------- ACTION BUTTONS ----------
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        context.pushNamed(
                          'setSerialPage',
                          extra: SetSerialParams(
                            userId: params.userId,
                            controllerId: params.controllerId,
                            type: 1, deviceId: params.deviceId,
                          ),
                        );
                      },
                      child: const Text("Set Serial"),
                    ),
                    const SizedBox(width: 20),
                    TextButton(
                      onPressed: () {
                        context.pushNamed(
                          'setSerialPage',
                          extra: SetSerialParams(
                            userId: params.userId,
                            controllerId: params.controllerId,
                            type: 2, deviceId: params.deviceId,
                          ),
                        );
                      },
                      child: const Text("Common Calibration"),
                    ),
                  ],
                ),


                // ---------- DEVICE ID ----------
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(
                      ClipboardData(text: controller.deviceId),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Copied to clipboard")),
                    );
                  },
                  child: ControllerInfoRow(
                    label: "Device ID",
                    value: controller.deviceId,
                  ),
                ),


                // ---------- GROUP NAME ----------
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "Group Name",
                            style: TextStyle(
                              fontSize: 16,
                               color: Colors.black,
                            ),
                          ),
                        ),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: controller.groupName,
                            dropdownColor: AppThemes.primaryColor,
                            items: groupList.map((g) {
                              return DropdownMenuItem(
                                value: g.groupName,
                                child: Text(
                                  g.groupName,
                                  style: const TextStyle(color: Colors.black),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ),


                // ---------- DEVICE NAME ----------
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: devicenameController,
                      decoration: const InputDecoration(
                        labelText: "Device Name",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),


                // ---------- COUNTRY CODE + SIM ----------
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 90,
                          child: TextField(
                            controller: countrycodeController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: "Code",
                              border: InputBorder.none,
                            ),
                            style: TextStyle(color: AppThemes.primaryColor),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: simController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: "SIM Number",
                              border: InputBorder.none,
                            ),
                            style: TextStyle(color: AppThemes.primaryColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),


                // ---------- ICON ACTIONS ----------


                // ---------- SWITCHES ----------
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
                        isOn: !val,
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


                // ---------- INFO ----------
                ControllerInfoRow(
                  label: "Operation Mode",
                  valueWidget: IconButton(
                    icon: const Icon(Icons.visibility, color: AppThemes.primaryColor),
                    onPressed: () {},
                  ),
                ),

                ControllerInfoRow(
                  label: "WiFi Reset",
                  valueWidget: IconButton(
                    icon: const Icon(Icons.wifi_protected_setup_sharp,
                        color: AppThemes.primaryColor),
                    onPressed: () {},
                  ),
                ),
                ControllerInfoRow(label: "Dealer Name", value: controller.dealerName),
                ControllerInfoRow(label: "Model", value: controller.modelName),
                ControllerInfoRow(
                    label: "Customer Name", value: controller.customerName),
                ControllerInfoRow(
                    label: "Customer Number",
                    value: controller.customerNumber),

                const SizedBox(height: 24),

                // ---------- ACTION BUTTONS ----------
                ControllerActionButtons(
                  buttons: [
                    ControllerButtonData(
                      title: "Submit",
                      color: Colors.blue,
                      onPressed: () {
                        context.read<ControllerDetailsBloc>().add(
                          UpdateControllerEvent(
                            userId: '${params.userId}',
                            controllerId: params.controllerId,
                            countryCode: countrycodeController.text,
                            simNumber: simController.text,
                            deviceName: devicenameController.text,
                            groupId: groupList
                                .firstWhere((g) =>
                            g.groupName == controller.groupName)
                                .userGroupId,
                            operationMode: controller.operationMode,
                            gprsMode: controller.gprsMode,
                            appSmsMode: controller.appSmsMode,
                            sentSms: "",
                            editType: "0",
                          ),
                        );
                      },
                    ),
                    // ControllerButtonData(
                    //   title: "Replace",
                    //   color: Colors.orange,
                    //   onPressed: () {},
                    // ),
                    // ControllerButtonData(
                    //   title: "Delete",
                    //   color: Colors.red,
                    //   onPressed: () {},
                    // ),
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
        ),
      );

    }

    return  GlassyWrapper(
      child: Scaffold(
         body: Center(
          child: noData,
        ),
      ),
    );
  }
}
