import 'package:equatable/equatable.dart';
import '../../domain/entities/selling_device_category_entity.dart';
import '../../domain/entities/selling_unit_entity.dart';
import '../../domain/entities/device_trace_entity.dart';

abstract class SellingDeviceState extends Equatable {
  const SellingDeviceState();

  @override
  List<Object?> get props => [];
}

class SellingDeviceInitial extends SellingDeviceState {}

class SellingDeviceLoading extends SellingDeviceState {}

class SellingDeviceLoaded extends SellingDeviceState {
  final List<SellingDeviceCategoryEntity> categories;
  final Map<int, List<SellingUnitEntity>> categoryUnits;
  final Set<int> expandedCategories;
  final bool isUnitsLoading;
  final String? message;

  // Sales process fields
  final Set<int> selectedProductIds;
  final String mobileNumber;
  final String userType;
  final String? fetchedUserName;
  final bool isSalesLoading;
  final bool isUsernameLoading;

  // Trace process fields
  final bool isTraceLoading;
  final DeviceTraceEntity? tracedDevice;
  final String? traceError;

  // Add controller fields
  final bool isAddingController;

  const SellingDeviceLoaded({
    required this.categories,
    this.categoryUnits = const {},
    this.expandedCategories = const {},
    this.isUnitsLoading = false,
    this.message,
    this.selectedProductIds = const {},
    this.mobileNumber = '',
    this.userType = '1',
    this.fetchedUserName,
    this.isSalesLoading = false,
    this.isUsernameLoading = false,
    this.isTraceLoading = false,
    this.tracedDevice,
    this.traceError,
    this.isAddingController = false,
  });

  SellingDeviceLoaded copyWith({
    List<SellingDeviceCategoryEntity>? categories,
    Map<int, List<SellingUnitEntity>>? categoryUnits,
    Set<int>? expandedCategories,
    bool? isUnitsLoading,
    String? message,
    Set<int>? selectedProductIds,
    String? mobileNumber,
    String? userType,
    String? fetchedUserName,
    bool? isSalesLoading,
    bool? isUsernameLoading,
    bool? isTraceLoading,
    DeviceTraceEntity? tracedDevice,
    String? traceError,
    bool? isAddingController,
  }) {
    return SellingDeviceLoaded(
      categories: categories ?? this.categories,
      categoryUnits: categoryUnits ?? this.categoryUnits,
      expandedCategories: expandedCategories ?? this.expandedCategories,
      isUnitsLoading: isUnitsLoading ?? this.isUnitsLoading,
      message: message,
      selectedProductIds: selectedProductIds ?? this.selectedProductIds,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      userType: userType ?? this.userType,
      fetchedUserName: fetchedUserName ?? this.fetchedUserName,
      isSalesLoading: isSalesLoading ?? this.isSalesLoading,
      isUsernameLoading: isUsernameLoading ?? this.isUsernameLoading,
      isTraceLoading: isTraceLoading ?? this.isTraceLoading,
      tracedDevice: tracedDevice ?? this.tracedDevice,
      traceError: traceError ?? this.traceError,
      isAddingController: isAddingController ?? this.isAddingController,
    );
  }

  @override
  List<Object?> get props => [
    categories,
    categoryUnits,
    expandedCategories,
    isUnitsLoading,
    message,
    selectedProductIds,
    mobileNumber,
    userType,
    fetchedUserName,
    isSalesLoading,
    isUsernameLoading,
    isTraceLoading,
    tracedDevice,
    traceError,
    isAddingController,
  ];
}

class SellingDeviceError extends SellingDeviceState {
  final String message;

  const SellingDeviceError(this.message);

  @override
  List<Object?> get props => [message];
}
