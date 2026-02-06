import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/selling_unit_entity.dart';
import '../../domain/repositories/selling_device_repository.dart';
import 'selling_device_state.dart';

class SellingDeviceCubit extends Cubit<SellingDeviceState> {
  final SellingDeviceRepository repository;

  SellingDeviceCubit({required this.repository}) : super(SellingDeviceInitial());

  Future<void> fetchCategories() async {
    emit(SellingDeviceLoading());
    final result = await repository.getCategoryList();
    result.fold(
          (failure) => emit(const SellingDeviceError("Failed to fetch categories")),
          (categories) => emit(SellingDeviceLoaded(categories: categories)),
    );
  }

  void clearMessage() {
    final currentState = state;
    if (currentState is SellingDeviceLoaded) {
      emit(currentState.copyWith(message: null));
    }
  }

  Future<void> toggleCategory(int categoryId, String userId) async {
    final currentState = state;
    if (currentState is SellingDeviceLoaded) {
      final expanded = Set<int>.from(currentState.expandedCategories);

      if (expanded.contains(categoryId)) {
        expanded.remove(categoryId);
        emit(currentState.copyWith(expandedCategories: expanded, message: null));
      } else {
        if (!currentState.categoryUnits.containsKey(categoryId)) {
          emit(currentState.copyWith(isUnitsLoading: true, message: null));

          final result = await repository.getSellingUnits(userId, categoryId.toString());

          result.fold(
                (failure) {
              emit(currentState.copyWith(
                isUnitsLoading: false,
                message: "There are no devices for sale in your account",
              ));
            },
                (units) {
              if (units.isEmpty) {
                emit(currentState.copyWith(
                  isUnitsLoading: false,
                  message: "There are no devices for sale in your account",
                ));
              } else {
                final Map<int, List<SellingUnitEntity>> newUnits = Map.from(currentState.categoryUnits);
                newUnits[categoryId] = units;
                expanded.add(categoryId);
                emit(currentState.copyWith(
                  isUnitsLoading: false,
                  categoryUnits: newUnits,
                  expandedCategories: expanded,
                  message: null,
                ));
              }
            },
          );
        } else {
          expanded.add(categoryId);
          emit(currentState.copyWith(expandedCategories: expanded, message: null));
        }
      }
    }
  }

  void toggleProductSelection(int productId) {
    final currentState = state;
    if (currentState is SellingDeviceLoaded) {
      final selected = Set<int>.from(currentState.selectedProductIds);
      if (selected.contains(productId)) {
        selected.remove(productId);
      } else {
        selected.add(productId);
      }
      emit(currentState.copyWith(selectedProductIds: selected));
    }
  }

  void updateMobileNumber(String mobile) {
    final currentState = state;
    if (currentState is SellingDeviceLoaded) {
      emit(currentState.copyWith(mobileNumber: mobile, fetchedUserName: null));
    }
  }

  void updateUserType(String type) {
    final currentState = state;
    if (currentState is SellingDeviceLoaded) {
      emit(currentState.copyWith(userType: type, fetchedUserName: null));
    }
  }

  void setFetchedUserName(String name, String mobile, {String? successMessage}) {
    final currentState = state;
    if (currentState is SellingDeviceLoaded) {
      emit(currentState.copyWith(
        fetchedUserName: name,
        mobileNumber: mobile,
        isUsernameLoading: false,
        message: successMessage,
      ));
    }
  }

  Future<void> fetchUserName(String userId, {String? overrideType}) async {
    final currentState = state;
    if (currentState is SellingDeviceLoaded && currentState.mobileNumber.isNotEmpty) {
      emit(currentState.copyWith(isUsernameLoading: true));

      final typeToLookup = overrideType ?? currentState.userType;

      final result = await repository.getUsernameByMobile(
        userId,
        currentState.mobileNumber,
        typeToLookup,
      );
      result.fold(
            (failure) => emit(currentState.copyWith(isUsernameLoading: false, message: failure.message)),
            (lookupResult) => emit(currentState.copyWith(
          isUsernameLoading: false,
          fetchedUserName: lookupResult['userName'],
          message: lookupResult['message'],
        )),
      );
    }
  }

  Future<void> processSale(String userId, {String? overrideType}) async {
    final currentState = state;
    if (currentState is SellingDeviceLoaded && currentState.selectedProductIds.isNotEmpty && currentState.fetchedUserName != null) {
      emit(currentState.copyWith(isSalesLoading: true));

      final typeToSubmit = (currentState.userType == '4' && overrideType != null)
          ? overrideType
          : currentState.userType;

      final result = await repository.sellDevices(
        userId: userId,
        userName: currentState.fetchedUserName!,
        userType: typeToSubmit,
        mobileCountryCode: "91",
        mobileNumber: currentState.mobileNumber,
        productIds: currentState.selectedProductIds.toList(),
      );

      result.fold(
            (failure) => emit(currentState.copyWith(isSalesLoading: false, message: failure.message)),
            (_) {
          emit(currentState.copyWith(
            isSalesLoading: false,
            message: "Selected device(s) has been sold successfully",
            selectedProductIds: {},
            mobileNumber: '',
            fetchedUserName: null,
          ));
          fetchCategories();
        },
      );
    }
  }

  Future<void> traceDevice(String userId, String deviceId) async {
    if (kDebugMode) print("DEBUG: Cubit.traceDevice starting... User: $userId, Device: $deviceId");

    if (state is! SellingDeviceLoaded) {
      emit(const SellingDeviceLoaded(categories: []));
    }

    // Reset all trace and message states before starting new trace
    emit((state as SellingDeviceLoaded).copyWith(
      isTraceLoading: true,
      traceError: null,
      tracedDevice: null,
      message: null,
    ));

    final result = await repository.traceDevice(userId, deviceId);

    result.fold(
          (failure) {
        if (kDebugMode) print("DEBUG: Trace Failed Result: ${failure.message}");
        emit((state as SellingDeviceLoaded).copyWith(
          isTraceLoading: false,
          traceError: failure.message,
          tracedDevice: null,
        ));
      },
          (device) {
        if (kDebugMode) print("DEBUG: Trace Success Result: ${device.modelName}");
        emit((state as SellingDeviceLoaded).copyWith(
          isTraceLoading: false,
          tracedDevice: device,
          traceError: null,
        ));
      },
    );
  }

  Future<void> addController(String userId, int productId) async {
    final currentState = state;
    if (currentState is SellingDeviceLoaded) {
      emit(currentState.copyWith(isAddingController: true, message: null));

      final result = await repository.addControllerToDealer(userId: userId, productId: productId);

      result.fold(
            (failure) => emit((state as SellingDeviceLoaded).copyWith(isAddingController: false, message: failure.message)),
            (_) {
          emit((state as SellingDeviceLoaded).copyWith(
            isAddingController: false,
            message: "Controller added to your account successfully",
            tracedDevice: null,
          ));
          fetchCategories();
        },
      );
    }
  }

  void clearTrace() {
    final currentState = state;
    if (currentState is SellingDeviceLoaded) {
      emit(currentState.copyWith(tracedDevice: null, traceError: null, message: null));
    }
  }
}
