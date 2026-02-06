import 'package:equatable/equatable.dart';

abstract class ServiceRequestEvent extends Equatable {
  const ServiceRequestEvent();

  @override
  List<Object?> get props => [];
}

class FetchServiceRequests extends ServiceRequestEvent {
  final String userId;

  const FetchServiceRequests({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class UpdateServiceRequestEvent extends ServiceRequestEvent {
  final String dealerId;
  final String serviceRequestId;
  final String status;
  final String remark;
  final String userId;
  final String controllerId;
  final String sentSms;

  const UpdateServiceRequestEvent({
    required this.dealerId,
    required this.serviceRequestId,
    required this.status,
    required this.remark,
    required this.userId,
    required this.controllerId,
    required this.sentSms,
  });

  @override
  List<Object?> get props => [dealerId, serviceRequestId, status, remark, userId, controllerId, sentSms];
}
