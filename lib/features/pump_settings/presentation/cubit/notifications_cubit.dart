import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/entities/notifications_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/usecsases/subscribe_notifications_usecase.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/presentation/bloc/notifications_state.dart';

import '../../domain/usecsases/get_notifications_usecase.dart';

class NotificationsPageCubit extends Cubit<NotificationsState> {
  final GetNotificationsUsecase getNotificationsUsecase;
  final SubscribeNotificationsUsecase subscribeNotificationsUsecase;

  NotificationsPageCubit({required this.getNotificationsUsecase, required this.subscribeNotificationsUsecase}) : super(GetNotificationsInitial());

  Future<void> loadNotifications({
    required int userId,
    required int subUserId,
    required int controllerId,
  }) async {
    if (state is GetNotificationsLoaded) return;
    emit(GetNotificationsInitial());

    final result = await getNotificationsUsecase(GetNotificationsParams(
      userId: userId,
      subUserId: subUserId,
      controllerId: controllerId,
    ));

    result.fold(
          (failure) => emit(GetNotificationsFailure(message: failure.message)),
          (menuItem) => emit(GetNotificationsLoaded(notifications: menuItem)),
    );
  }

  void updateSettings(int value, int index) {
    if (state is GetNotificationsLoaded) {
      final loadedState = state as GetNotificationsLoaded;
      final notifications = List<NotificationsEntity>.from(loadedState.notifications);
      if(index == -1) {
        for(int i = 0; i < notifications.length; i++) {
          notifications[i] = notifications[i].copyWith(checkFlag: value);
        }
      } else {
        notifications[index] = notifications[index].copyWith(checkFlag: value);
      }
      emit(GetNotificationsLoaded(notifications: notifications));
    }
  }

  Future<void> subscribeNotifications(int userId, int controllerId, int subuserId, Map<String, dynamic> body) async {
    emit(UpdateNotificationsLoading());

    final result = await subscribeNotificationsUsecase(
        SubscribeNotificationsParams(
            userId: userId,
            subUserId: subuserId,
            controllerId: controllerId,
            body: body
        )
    );

    result.fold(
          (failure) => emit(UpdateNotificationsFailure(message: failure.message)),
          (subscribe) => emit(UpdateNotificationsSuccess(message: subscribe)),
    );
  }
}