import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/dealer_dashboard/domain/usecases/get_selected_customers.dart';

import '../../domain/entities/dealer_customer_entity.dart';
import '../../domain/usecases/get_dealer_customer_details.dart';
abstract class DealerCustomerState extends Equatable {
  const DealerCustomerState();

  @override
  List<Object> get props => [];
}

class DealerCustomerInitial extends DealerCustomerState {}

class DealerCustomerLoading extends DealerCustomerState {}

class DealerCustomerLoaded extends DealerCustomerState {
  final List<DealerCustomerEntity> customers;

  const DealerCustomerLoaded({required this.customers});

  @override
  List<Object> get props => [customers];
}

class DealerCustomerError extends DealerCustomerState {
  final String message;

  const DealerCustomerError({required this.message});

  @override
  List<Object> get props => [message];
}


class DealerCustomerCubit extends Cubit<DealerCustomerState> {
  final GetDealerCustomerDetails getDealerCustomerDetails;
  final GetSelectedCustomerDetails getSelectedCustomerDetails;

  DealerCustomerCubit({required this.getDealerCustomerDetails, required this.getSelectedCustomerDetails}) : super(DealerCustomerInitial());

  Future<void> fetchDealerCustomers(String userId) async {
    emit(DealerCustomerLoading());
    final failureOrData = await getDealerCustomerDetails(userId);
    failureOrData.fold(
      (failure) => emit(const DealerCustomerError(message: 'Failed to fetch customer details')),
      (data) => emit(DealerCustomerLoaded(customers: data)),
    );
  }

  Future<void> fetchSelectedCustomers(String userId) async {
    emit(DealerCustomerLoading());
    final failureOrData = await getSelectedCustomerDetails(userId);
    failureOrData.fold(
          (failure) => emit(const DealerCustomerError(message: 'Failed to fetch customer details')),
          (data) => emit(DealerCustomerLoaded(customers: data)),
    );
  }
}
