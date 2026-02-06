import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/service_request_bloc.dart';
import '../bloc/service_request_event.dart';
import '../bloc/service_request_state.dart';
import '../../domain/entities/service_request_entity.dart';

class ServiceRequestPage extends StatelessWidget {
  const ServiceRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "SERVICE REQUEST",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Color(0xFF64B5F6)],
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<ServiceRequestBloc, ServiceRequestState>(
            builder: (context, state) {
              if (state is ServiceRequestLoading) {
                return const Center(child: CircularProgressIndicator(color: Colors.blue));
              } else if (state is ServiceRequestLoaded) {
                if (state.serviceRequests.isEmpty) {
                  return const Center(child: Text("No Service Requests Found", style: TextStyle(fontWeight: FontWeight.bold)));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.serviceRequests.length,
                  itemBuilder: (context, index) {
                    final request = state.serviceRequests[index];
                    return _serviceRequestCard(context, request);
                  },
                );
              } else if (state is ServiceRequestError) {
                return Center(child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(state.message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ));
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _serviceRequestCard(BuildContext cardContext, ServiceRequestEntity request) {
    Color statusColor;
    
    switch (request.serviceStatus) {
      case "1":
        statusColor = Colors.orange;
        break;
      case "2":
        statusColor = Colors.blue;
        break;
      case "3":
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    request.userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  height: 32,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: request.serviceStatus,
                      icon: Icon(Icons.arrow_drop_down, color: statusColor, size: 20),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                      onChanged: (String? newValue) {
                        if (newValue != null && newValue != request.serviceStatus) {
                          String smsCode = newValue == "2" ? "SERVICEOK" : (newValue == "3" ? "SERVICEOF" : "");
                          _showUpdateDialog(cardContext, request, newValue, smsCode);
                        }
                      },
                      items: const [
                        DropdownMenuItem(value: "1", child: Text("Open")),
                        DropdownMenuItem(value: "2", child: Text("In-Progress")),
                        DropdownMenuItem(value: "3", child: Text("Closed")),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _infoRow(Icons.phone, "${request.countryCode} ${request.mobileNumber}"),
            const SizedBox(height: 4),
            _infoRow(Icons.devices, request.deviceName),
            const SizedBox(height: 4),
            _infoRow(Icons.qr_code, "QR: ${request.qrCode}"),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    String smsCode = request.serviceStatus == "2" ? "SERVICEOK" : (request.serviceStatus == "3" ? "SERVICEOF" : "");
                    _showUpdateDialog(cardContext, request, request.serviceStatus, smsCode);
                  },
                  icon: const Icon(Icons.edit_note, size: 18),
                  label: const Text("REMARK", style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 4),
            const Text("Description:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text(
              request.serviceDesc,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
            
            // Remark Section
            if (request.inProgRemark.isNotEmpty || request.closedRemark.isNotEmpty) ...[
               const SizedBox(height: 12),
               const Divider(),
               const Text("Remarks:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue)),
               const SizedBox(height: 4),
               if (request.inProgRemark.isNotEmpty) _detailRow("In-Progress", request.inProgRemark),
               if (request.closedRemark.isNotEmpty) _detailRow("Closing", request.closedRemark),
            ],

            if (request.serviceStatus == "2" || request.serviceStatus == "3") ...[
               const SizedBox(height: 12),
               const Divider(),
               const Text("Process Details:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
               const SizedBox(height: 4),
               if (request.inProgUser.isNotEmpty) _detailRow("Handler", request.inProgUser),
               if (request.inProgDate.isNotEmpty) _detailRow("Started", "${request.inProgDate} ${request.inProgTime}"),
               if (request.closedUser.isNotEmpty) _detailRow("Closed By", request.closedUser),
               if (request.closedDate.isNotEmpty) _detailRow("Closed At", "${request.closedDate} ${request.closedTime}"),
            ],

            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${request.date} ${request.time}",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
                Text(
                  "SR ID: ${request.serviceRequestId}",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blue[700]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14, 
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.black54)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12, color: Colors.black87))),
        ],
      ),
    );
  }

  void _showUpdateDialog(BuildContext cardContext, ServiceRequestEntity request, String nextStatus, String smsCode) {
    final remarkController = TextEditingController();
    // Pre-fill existing remark if updating current status
    if (nextStatus == request.serviceStatus) {
      remarkController.text = nextStatus == "2" ? request.inProgRemark : (nextStatus == "3" ? request.closedRemark : "");
    }

    showDialog(
      context: cardContext,
      builder: (dialogContext) => AlertDialog(
        title: Text(nextStatus == "2" ? "In-Progress Details" : (nextStatus == "3" ? "Close Service Request" : "Update Request")),
        content: TextField(
          controller: remarkController,
          decoration: const InputDecoration(hintText: "Enter Remark"),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () {
              cardContext.read<ServiceRequestBloc>().add(UpdateServiceRequestEvent(
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
            child: const Text("SUBMIT"),
          ),
        ],
      ),
    );
  }
}
