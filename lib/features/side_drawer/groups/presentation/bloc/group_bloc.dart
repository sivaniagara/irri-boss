import 'package:flutter_bloc/flutter_bloc.dart';

import '../../groups_barrel.dart';

class GroupBloc extends Bloc<GroupEvent, GroupState> {
  final GroupFetchingUsecase groupFetchingUsecase;
  final GroupAddingUsecase groupAddingUsecase;
  final EditGroupUsecase editGroupUsecase;
  final DeleteGroupUsecase deleteGroupUsecase; // New usecase

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

      result.fold(
        (failure) => emit(GroupAddingError(message: failure.message)),
        (message) {
          emit(GroupAddingLoaded(message: message));
          add(FetchGroupsEvent(event.userId));
        },
      );
    });

    on<GroupEditEvent>((event, emit) async {
      emit(EditGroupInitial());
      final result = await editGroupUsecase(EditGroupParams(event.userId, event.groupId, event.groupName));

      result.fold(
        (failure) => emit(EditGroupError(message: failure.message)),
        (message) {
          emit(EditGroupSuccess(message: message));
          add(FetchGroupsEvent(event.userId));
        },
      );
    });

    // New Delete Handler
    on<GroupDeleteEvent>((event, emit) async {
      emit(GroupDeletingStarted());
      final result = await deleteGroupUsecase(DeleteGroupParams(event.userId, event.groupId));

      result.fold(
        (failure) => emit(GroupDeleteError(message: failure.message)),
        (message) {
          emit(GroupDeleteSuccess(message: message));
          add(FetchGroupsEvent(event.userId)); // Refetch after successful delete
        },
      );
    });
  }
}