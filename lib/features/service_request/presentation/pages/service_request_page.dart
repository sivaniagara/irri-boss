import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_themes.dart';
import '../../../../core/utils/app_images.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../bloc/service_request_bloc.dart';
import '../bloc/service_request_event.dart';
import '../bloc/service_request_state.dart';
import '../../domain/entities/service_request_entity.dart';

class ServiceRequestPage extends StatelessWidget {
  const ServiceRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemes.scaffoldBackGround,
      appBar: const CustomAppBar(
        title: "Service Request",
      ),
      body: SafeArea(
        child: BlocBuilder<ServiceRequestBloc, ServiceRequestState>(
          builder: (context, state) {
            if (state is ServiceRequestLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ServiceRequestLoaded) {
              if (state.serviceRequests.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.support_agent_rounded, size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text(
                        "No pending requests",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black38),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                physics: const BouncingScrollPhysics(),
                itemCount: state.serviceRequests.length,
                itemBuilder: (context, index) {
                  final request = state.serviceRequests[index];
                  return _premiumServiceCard(context, request);
                },
              );
            } else if (state is ServiceRequestError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _premiumServiceCard(BuildContext context, ServiceRequestEntity request) {
    Color statusColor;
    String statusLabel;
    
    switch (request.serviceStatus) {
      case "1":
        statusColor = Colors.orange;
        statusLabel = "OPEN";
        break;
      case "2":
        statusColor = Colors.blue;
        statusLabel = "IN PROGRESS";
        break;
      case "3":
        statusColor = Colors.green;
        statusLabel = "CLOSED";
        break;
      default:
        statusColor = Colors.grey;
        statusLabel = "UNKNOWN";
    }

    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(25), topRight: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(topRight: Radius.circular(25)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: statusColor.withOpacity(0.2), blurRadius: 4)],
                  ),
                  child: Image.asset(AppImages.communicationNodeIcon, width: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.userName,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black87),
                      ),
                      Text(
                        "Ticket ID: #${request.serviceRequestId}",
                        style: TextStyle(fontSize: 11, color: theme.primaryColor, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                _statusDropdown(context, request, statusColor, statusLabel),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _iconDetail(context, Icons.phone_android_rounded, "${request.countryCode} ${request.mobileNumber}"),
                const SizedBox(height: 10),
                _iconDetail(context, Icons.settings_remote_rounded, request.deviceName),
                const SizedBox(height: 10),
                _iconDetail(context, Icons.qr_code_2_rounded, "UID: ${request.qrCode}"),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(height: 1),
                ),
                
                const Text("ISSUE DESCRIPTION", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Colors.black38, letterSpacing: 1)),
                const SizedBox(height: 8),
                Text(
                  request.serviceDesc,
                  style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.4, fontWeight: FontWeight.w500),
                ),

                if (request.inProgRemark.isNotEmpty || request.closedRemark.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xffF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("OFFICIAL REMARKS", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: AppThemes.primaryColor)),
                        const SizedBox(height: 8),
                        if (request.inProgRemark.isNotEmpty) _remarkItem("Processing", request.inProgRemark),
                        if (request.closedRemark.isNotEmpty) _remarkItem("Resolution", request.closedRemark),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "REPORTED ON",
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.grey.shade400),
                        ),
                        Text(
                          "${request.date} @ ${request.time}",
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        String smsCode = request.serviceStatus == "2" ? "SERVICEOK" : (request.serviceStatus == "3" ? "SERVICEOF" : "");
                        _showUpdateDialog(context, request, request.serviceStatus, smsCode);
                      },
                      icon: const Icon(Icons.rate_review_rounded, size: 16),
                      label: const Text("ADD REMARK", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // History Expansion (Footer)
          if (request.serviceStatus != "1")
          _expansionHistory(context, request),
        ],
      ),
    );
  }

  Widget _statusDropdown(BuildContext context, ServiceRequestEntity request, Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: request.serviceStatus,
          icon: Icon(Icons.expand_more_rounded, color: color, size: 18),
          style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 10),
          onChanged: (String? newValue) {
            if (newValue != null && newValue != request.serviceStatus) {
              String smsCode = newValue == "2" ? "SERVICEOK" : (newValue == "3" ? "SERVICEOF" : "");
              _showUpdateDialog(context, request, newValue, smsCode);
            }
          },
          items: const [
            DropdownMenuItem(value: "1", child: Text("OPEN")),
            DropdownMenuItem(value: "2", child: Text("IN PROGRESS")),
            DropdownMenuItem(value: "3", child: Text("CLOSED")),
          ],
        ),
      ),
    );
  }

  Widget _iconDetail(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppThemes.primaryColor.withOpacity(0.7)),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
      ],
    );
  }

  Widget _remarkItem(String label, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black45)),
          Expanded(child: Text(content, style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _expansionHistory(BuildContext context, ServiceRequestEntity request) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(25)),
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Column(
        children: [
          if (request.inProgUser.isNotEmpty) _historyRow("Handled by", request.inProgUser, Icons.person_outline),
          if (request.closedUser.isNotEmpty) _historyRow("Closed by", request.closedUser, Icons.check_circle_outline),
        ],
      ),
    );
  }

  Widget _historyRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 12, color: Colors.black26),
          const SizedBox(width: 6),
          Text("$label: ", style: const TextStyle(fontSize: 10, color: Colors.black38, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  void _showUpdateDialog(BuildContext context, ServiceRequestEntity request, String nextStatus, String smsCode) {
    final remarkController = TextEditingController();
    if (nextStatus == request.serviceStatus) {
      remarkController.text = nextStatus == "2" ? request.inProgRemark : (nextStatus == "3" ? request.closedRemark : "");
    }

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nextStatus == "2" ? "Move to Processing" : (nextStatus == "3" ? "Resolve Request" : "Update Support Info"),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              const Text("Provide an official remark for this update.", style: TextStyle(fontSize: 13, color: Colors.black45)),
              const SizedBox(height: 20),
              TextField(
                controller: remarkController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Enter details here...",
                  filled: true,
                  fillColor: const Color(0xffF3F4F6),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text("DISCARD", style: TextStyle(color: Colors.black45, fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<ServiceRequestBloc>().add(UpdateServiceRequestEvent(
                          dealerId: request.dealerId.toString(),
                          serviceRequestId: request.serviceRequestId.toString(),
                          status: nextStatus,
                          remark: remarkController.text,
                          userId: request.userId.toString(),
                          controllerId: request.userDeviceId.toString(),
                          sentSms: smsCode,
                        ));
                        Navigator.pop(dialogContext);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppThemes.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text("UPDATE STATUS", style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
