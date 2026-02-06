import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/service_request_repository.dart';
import 'service_request_event.dart';
import 'service_request_state.dart';

class ServiceRequestBloc extends Bloc<ServiceRequestEvent, ServiceRequestState> {
  final ServiceRequestRepository repository;

  ServiceRequestBloc({required this.repository}) : super(ServiceRequestInitial()) {
    on<FetchServiceRequests>((event, emit) async {
      emit(ServiceRequestLoading());
      final result = await repository.getServiceRequests(event.userId);
      result.fold(
        (failure) => emit(ServiceRequestError(message: failure.message)),
        (success) {
          // Show all data from API, but sort by ID descending (newest first)
          final sortedList = List.from(success);
          sortedList.sort((a, b) => b.serviceRequestId.compareTo(a.serviceRequestId));
          emit(ServiceRequestLoaded(serviceRequests: sortedList.cast()));
        },
      );
    });

    on<UpdateServiceRequestEvent>((event, emit) async {
      emit(ServiceRequestLoading());
      final result = await repository.updateServiceRequest(
        dealerId: event.dealerId,
        serviceRequestId: event.serviceRequestId,
        status: event.status,
        remark: event.remark,
        userId: event.userId,
        controllerId: event.controllerId,
        sentSms: event.sentSms,
      );

      result.fold(
        (failure) => emit(ServiceRequestError(message: failure.message)),
        (_) {
          add(FetchServiceRequests(userId: event.dealerId));
        },
      );
    });
  }
}
