import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/dealer_dashboard/domain/usecases/get_selected_customers.dart';

import '../../domain/entities/dealer_customer_entity.dart';
import '../../domain/usecases/get_dealer_customer_details.dart';
import '../../domain/usecases/get_shared_device_usecase.dart';
import '../../domain/entities/shared_devices_entity.dart';

abstract class DealerListState extends Equatable {
  const DealerListState();

  @override
  List<Object> get props => [];
}

class DealerListInitial extends DealerListState {}

class ListLoading extends DealerListState {}

class CustomersLoaded extends DealerListState {
  final List<DealerCustomerEntity> customers;

  const CustomersLoaded({required this.customers});

  @override
  List<Object> get props => [customers];
}

class SharedLoaded extends DealerListState {
  final List<SharedDevicesEntity> shared;

  const SharedLoaded({required this.shared});

  @override
  List<Object> get props => [shared];
}

class ListError extends DealerListState {
  final String message;

  const ListError({required this.message});

  @override
  List<Object> get props => [message];
}

class DealerListCubit extends Cubit<DealerListState> {
  final GetDealerCustomerDetails getDealerCustomerDetails;
  final GetSelectedCustomerDetails getSelectedCustomerDetails;
  final GetSharedDevicesUsecase getSharedDevicesUsecase;

  DealerListCubit({
    required this.getDealerCustomerDetails,
    required this.getSelectedCustomerDetails,
    required this.getSharedDevicesUsecase,
  }) : super(DealerListInitial());

  Future<void> fetchDealerCustomers(String userId) async {
    emit(ListLoading());
    final failureOrData = await getDealerCustomerDetails(userId);
    failureOrData.fold(
          (failure) => emit(const ListError(message: 'Failed to fetch customer details')),
          (data) => emit(CustomersLoaded(customers: data)),
    );
  }

  Future<void> fetchSelectedCustomers(String userId) async {
    emit(ListLoading());
    final failureOrData = await getSelectedCustomerDetails(userId);
    failureOrData.fold(
          (failure) => emit(const ListError(message: 'Failed to fetch customer details')),
          (data) => emit(CustomersLoaded(customers: data)),
    );
  }

  Future<void> fetchSharedDevices(String userId) async {
    emit(ListLoading());
    final failureOrData = await getSharedDevicesUsecase(GetSharedDevicesParams(userId: userId));
    failureOrData.fold(
          (failure) => emit(const ListError(message: 'Failed to fetch shared devices')),
          (data) => emit(SharedLoaded(shared: data)),
    );
  }
}