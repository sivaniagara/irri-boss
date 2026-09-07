import 'package:flutter_bloc/flutter_bloc.dart';

import '../../groups_barrel.dart';

class GroupBloc extends Bloc<GroupEvent, GroupState> {
  final GroupFetchingUsecase groupFetchingUsecase;
  final GroupAddingUsecase groupAddingUsecase;
  final EditGroupUsecase editGroupUsecase;
  final DeleteGroupUsecase deleteGroupUsecase;

  GroupBloc({
    required this.groupFetchingUsecase,
    required this.groupAddingUsecase,
    required this.editGroupUsecase,
    required this.deleteGroupUsecase,
  }) : super(GroupInitial()) {
    on<FetchGroupsEvent>((event, emit) async {
      emit(GroupLoading());
      final result = await groupFetchingUsecase(GroupFetchParams(event.userId));

      result.fold(
        (failure) => emit(GroupFetchingError(message: failure.message)),
        (groups) {
          emit(GroupLoaded(groups: groups));
        },
      );
    });

    on<GroupAddEvent>((event, emit) async {
      emit(GroupAddingStarted());
      final result = await groupAddingUsecase(GroupAddingParams(event.userId, event.groupName));

      await result.fold(
        (failure) async => emit(GroupAddingError(message: failure.message)),
        (message) async {
          emit(GroupAddingLoaded(message: message));
          final fetchResult = await groupFetchingUsecase(GroupFetchParams(event.userId));
          fetchResult.fold(
            (failure) => emit(GroupFetchingError(message: failure.message)),
            (groups) => emit(GroupLoaded(groups: groups)),
          );
        },
      );
    });

    on<GroupEditEvent>((event, emit) async {
      emit(EditGroupInitial());
      final result = await editGroupUsecase(EditGroupParams(event.userId, event.groupId, event.groupName));

      await result.fold(
        (failure) async => emit(EditGroupError(message: failure.message)),
        (message) async {
          emit(EditGroupSuccess(message: message));
          final fetchResult = await groupFetchingUsecase(GroupFetchParams(event.userId));
          fetchResult.fold(
            (failure) => emit(GroupFetchingError(message: failure.message)),
            (groups) => emit(GroupLoaded(groups: groups)),
          );
        },
      );
    });

    on<GroupDeleteEvent>((event, emit) async {
      emit(GroupDeletingStarted());
      final result = await deleteGroupUsecase(DeleteGroupParams(event.userId, event.groupId));

      await result.fold(
        (failure) async => emit(GroupDeleteError(message: failure.message)),
        (message) async {
          emit(GroupDeleteSuccess(message: message));
          final fetchResult = await groupFetchingUsecase(GroupFetchParams(event.userId));
          fetchResult.fold(
            (failure) => emit(GroupFetchingError(message: failure.message)),
            (groups) => emit(GroupLoaded(groups: groups)),
          );
        },
      );
    });
  }
}