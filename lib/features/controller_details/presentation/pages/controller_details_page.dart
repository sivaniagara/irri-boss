import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/theme/app_themes.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/no_data.dart';
import '../../data/models/controller_details_model.dart';
import '../../domain/entities/controller_details_entities.dart';
import '../../domain/usecase/controller_details_params.dart';
import '../bloc/controller_details_bloc.dart';
import '../bloc/controller_details_bloc_event.dart';
import '../bloc/controller_details_state.dart';

class ControllerDetailsPage extends StatefulWidget {
  final GetControllerDetailsParams params;

  const ControllerDetailsPage({
    super.key,
    required this.params,
  });

  @override
  State<ControllerDetailsPage> createState() => _ControllerDetailsPageState();
}

class _ControllerDetailsPageState extends State<ControllerDetailsPage> {
  late TextEditingController devicenameController;
  late TextEditingController simController;
  late TextEditingController countrycodeController;
  String? selectedGroupName;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    devicenameController = TextEditingController();
    simController = TextEditingController();
    countrycodeController = TextEditingController();
  }

  @override
  void dispose() {
    devicenameController.dispose();
    simController.dispose();
    countrycodeController.dispose();
    super.dispose();
  }

  void _initializeControllers(ControllerDetailsEntities data) {
    if (!_isInitialized) {
      devicenameController.text = data.deviceName;
      simController.text = data.simNumber;
      countrycodeController.text = data.customerCountryCode;
      selectedGroupName = data.groupName;
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemes.scaffoldBackGround,
      appBar: const CustomAppBar(title: "CONTROLLER DETAILS"),
      body: BlocListener<ControllerDetailsBloc, ControllerDetailsState>(
        listener: (context, state) {
          if (state is UpdateControllerSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Controller details updated successfully"),
                backgroundColor: Colors.green,
              ),
            );
            context.pop();
          } else if (state is ControllerDetailsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<ControllerDetailsBloc, ControllerDetailsState>(
          builder: (context, state) {
            if (state is ControllerDetailsInitial || state is ControllerDetailsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ControllerDetailsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.red),
                    const SizedBox(height: 16),
                    Text("Error: ${state.message}", style: const TextStyle(color: Colors.black87)),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ControllerDetailsBloc>().add(
                          GetControllerDetailsEvent(
                            userId: widget.params.userId,
                            controllerId: widget.params.controllerId,
                            deviceId: widget.params.deviceId,
                          ),
                        );
                      },
                      child: const Text("Retry"),
                    )
                  ],
                ),
              );
            }

            if (state is ControllerDetailsLoaded) {
              final data = state.data;
              final groupList = state.groupDetails;

              _initializeControllers(data);

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("DEVICE IDENTIFICATION"),
                    const SizedBox(height: 10),
                    _buildInfoCard(
                      label: "Device ID",
                      value: data.deviceId,
                      icon: Icons.fingerprint,
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: data.deviceId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Device ID copied to clipboard")),
                        );
                      },
                    ),
                    _buildDropdownCard(
                      label: "Group Name",
                      value: selectedGroupName ?? data.groupName,
                      items: groupList.map((g) => g.groupName).toList(),
                      icon: Icons.group_work_outlined,
                      onChanged: (val) {
                        setState(() {
                          selectedGroupName = val;
                        });
                      },
                    ),
                    _buildTextFieldCard(
                      label: "Device Name",
                      controller: devicenameController,
                      icon: Icons.edit_outlined,
                    ),
                    
                    const SizedBox(height: 20),
                    _buildSectionTitle("CONNECTIVITY & COMMUNICATION"),
                    const SizedBox(height: 10),
                    _buildPhoneInputCard(
                      countryCodeCtrl: countrycodeController,
                      simNumberCtrl: simController,
                    ),
                    _buildSwitchCard(
                      title: "INTERNET 4G",
                      value: data.gprsMode == "5",
                      onChanged: (val) {
                        context.read<ControllerDetailsBloc>().add(
                          ToggleSwitchEvent(switchName: "gprsMode", isOn: val),
                        );
                      },
                    ),
                    _buildSwitchCard(
                      title: "DND (Do Not Disturb)",
                      value: data.dndStatus == "1",
                      onChanged: (val) {
                        context.read<ControllerDetailsBloc>().add(
                          ToggleSwitchEvent(switchName: "dndStatus", isOn: val),
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                    _buildSectionTitle("SYSTEM INFORMATION"),
                    const SizedBox(height: 10),
                    _buildReadOnlyInfoCard("Dealer Name", data.dealerName, Icons.person_outline),
                    _buildReadOnlyInfoCard("Model", data.modelName, Icons.model_training),
                    _buildReadOnlyInfoCard("Customer Name", data.customerName, Icons.account_circle_outlined),
                    _buildReadOnlyInfoCard("Customer Number", data.customerNumber, Icons.phone_android),

                    const SizedBox(height: 30),
                    _buildActionButtons(context, data, groupList),
                    const SizedBox(height: 40),
                  ],
                ),
              );
            }

            if (state is UpdateControllerSuccess) {
              return const Center(child: CircularProgressIndicator());
            }

            return Center(child: noDataNew);
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String label, required String value, required IconData icon, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _cardDecoration(),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppThemes.primaryColor, size: 20),
        title: Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.bold)),
        trailing: onTap != null ? const Icon(Icons.copy, size: 14, color: Colors.grey) : null,
      ),
    );
  }

  Widget _buildReadOnlyInfoCard(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Icon(icon, color: AppThemes.primaryColor, size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldCard({required String label, required TextEditingController controller, required IconData icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _cardDecoration(),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
          prefixIcon: Icon(icon, color: AppThemes.primaryColor, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDropdownCard({required String label, required String value, required List<String> items, required IconData icon, required Function(String?) onChanged}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _cardDecoration(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: items.contains(value) ? value : null,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: AppThemes.primaryColor, size: 20),
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneInputCard({required TextEditingController countryCodeCtrl, required TextEditingController simNumberCtrl}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _cardDecoration(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.sim_card_outlined, color: AppThemes.primaryColor, size: 20),
            const SizedBox(width: 16),
            SizedBox(
              width: 50,
              child: TextFormField(
                controller: countryCodeCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Code",
                  labelStyle: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: simNumberCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "SIM Number",
                  labelStyle: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchCard({required String title, required bool value, required ValueChanged<bool> onChanged}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _cardDecoration(),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeColor: AppThemes.primaryColor,
        title: Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(15), topRight: Radius.circular(15)),
      border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
    );
  }

  Widget _buildActionButtons(BuildContext context, ControllerDetailsEntities data, List<GroupDetails> groupList) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              if (groupList.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Unable to find group details. Please try again.")),
                );
                return;
              }

              final selectedGroup = groupList.firstWhere(
                (g) => g.groupName == (selectedGroupName ?? data.groupName),
                orElse: () => groupList.first,
              );

              context.read<ControllerDetailsBloc>().add(
                UpdateControllerEvent(
                  userId: '${widget.params.userId}',
                  controllerId: widget.params.controllerId,
                  countryCode: countrycodeController.text,
                  simNumber: simController.text,
                  deviceName: devicenameController.text,
                  groupId: selectedGroup.userGroupId,
                  operationMode: data.operationMode,
                  gprsMode: data.gprsMode,
                  appSmsMode: data.appSmsMode,
                  sentSms: "",
                  editType: "0",
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemes.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("SAVE CHANGES", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () => context.pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppThemes.primaryColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("CANCEL", style: TextStyle(fontWeight: FontWeight.bold, color: AppThemes.primaryColor)),
          ),
        ),
      ],
    );
  }
}
