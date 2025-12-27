import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/program_settings/sub_module/common_id_settings/domain/usecases/submit_category_usecase.dart';
import 'package:niagara_smart_drip_irrigation/features/program_settings/sub_module/common_id_settings/presentation/bloc/common_id_settings_event.dart';
import 'package:niagara_smart_drip_irrigation/features/program_settings/sub_module/common_id_settings/presentation/bloc/common_id_settings_state.dart';

import '../../domain/entities/category_entity.dart';
import '../../domain/usecases/get_common_id_settings_usecase.dart';
import '../enums/common_id_settings_enum.dart';

class CommonIdSettingsBloc extends Bloc<CommonIdSettingsEvent, CommonIdSettingsState>{
  final GetCommonIdSettingsUsecase getCommonIdSettingsUsecase;
  final SubmitCategoryUsecase submitCategoryUsecase;

  CommonIdSettingsBloc({
    required this.getCommonIdSettingsUsecase,
    required this.submitCategoryUsecase,
  }) : super(CommonIdSettingsInitial()){

    on<FetchCommonIdSettings>((event, emit) async{
      emit(CommonIdSettingsLoading());
      GetCommonIdSettingsParams getCommonIdSettingsParams = GetCommonIdSettingsParams(
      userId: event.userId,
      controllerId: event.controllerId
      );
      final result = await getCommonIdSettingsUsecase(getCommonIdSettingsParams);
      result
          .fold(
            (failure){
              emit(CommonIdSettingsError(message: failure.message));
            },
            (success){
              emit(CommonIdSettingsLoaded(userId: event.userId, controllerId: event.controllerId, listOfCategoryEntity: success));
            },
        );
    });

    on<EditNodesSerialNo>((event, emit) async{

      final currentState = state as CommonIdSettingsLoaded;

      final updatedCategories =
      List<CategoryEntity>.from(currentState.listOfCategoryEntity);

      final oldCategory = updatedCategories[event.categoryIndex];

      final updatedCategory = oldCategory.copyWith(
        updatedNodes: event.nodes,
      );

      updatedCategories[event.categoryIndex] = updatedCategory;

      emit(
        currentState.copyWith(
          listOfCategoryEntity: updatedCategories,
        ),
      );
      var current = state as CommonIdSettingsLoaded;
      emit(current.copyWith(status: CommonIdSettingsUpdateStatus.loading));

      SubmitCategoryParams submitCategoryParams = SubmitCategoryParams(
          userId: current.userId,
          controllerId: current.controllerId,
          categoryEntity: current.listOfCategoryEntity[event.categoryIndex]
      );
      final result = await submitCategoryUsecase(submitCategoryParams);
      result
          .fold(
              (failure){
                emit(current.copyWith(status: CommonIdSettingsUpdateStatus.failure));
                emit(current.copyWith(status: CommonIdSettingsUpdateStatus.idle));
              },
              (success){
                emit(current.copyWith(status: CommonIdSettingsUpdateStatus.success));
                emit(current.copyWith(status: CommonIdSettingsUpdateStatus.idle));
              }
      );
    });

  }
}