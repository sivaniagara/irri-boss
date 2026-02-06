import 'package:equatable/equatable.dart';
import '../../domain/entities/service_request_entity.dart';

abstract class ServiceRequestState extends Equatable {
  const ServiceRequestState();

  @override
  List<Object?> get props => [];
}

class ServiceRequestInitial extends ServiceRequestState {}

class ServiceRequestLoading extends ServiceRequestState {}

class ServiceRequestLoaded extends ServiceRequestState {
  final List<ServiceRequestEntity> serviceRequests;

  const ServiceRequestLoaded({required this.serviceRequests});

  @override
  List<Object?> get props => [serviceRequests];
}

class ServiceRequestError extends ServiceRequestState {
  final String message;

  const ServiceRequestError({required this.message});

  @override
  List<Object?> get props => [message];
}
