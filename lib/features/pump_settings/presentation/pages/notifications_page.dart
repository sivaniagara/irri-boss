import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/action_button.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glass_effect.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glassy_wrapper.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/data/models/notifications_model.dart';

import 'package:niagara_smart_drip_irrigation/features/pump_settings/presentation/bloc/notifications_state.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/presentation/cubit/notifications_cubit.dart';

import '../../../../core/di/injection.dart' as di;

class NotificationsPage extends StatelessWidget {
  final int userId;
  final int controllerId;
  final int subUserId;

  const NotificationsPage({
    super.key,
    required this.userId,
    required this.controllerId,
    required this.subUserId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<NotificationsPageCubit>()
        ..loadNotifications(
          userId: userId,
          subUserId: subUserId,
          controllerId: controllerId,
        ),
      child: Builder(
        builder: (context) {
          return GlassyWrapper(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: const Text("Notifications"),
              ),
              body: BlocConsumer<NotificationsPageCubit, NotificationsState>(
                listener: (context, state) {
                  if (state is GetNotificationsFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }

                  if (state is UpdateNotificationsSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Notifications subscribed successfully!")),
                    );
                    Future.delayed(Duration(milliseconds: 500));
                    context.pop();
                  }

                  if (state is UpdateNotificationsFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is GetNotificationsInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is GetNotificationsFailure) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(state.message),
                          ElevatedButton(
                            onPressed: () => context.read<NotificationsPageCubit>().loadNotifications(
                              userId: userId,
                              subUserId: subUserId,
                              controllerId: controllerId,
                            ),
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is GetNotificationsLoaded) {
                    if (state.notifications.isEmpty) {
                      return const Center(child: Text("No notifications yet"));
                    }

                    return NotificationListener<OverscrollIndicatorNotification>(
                      onNotification: (n) {
                        n.disallowIndicator();
                        return true;
                      },
                      child: Column(
                        children: [
                          CheckboxListTile(
                            title: const Text("Select All"),
                            value: state.notifications.every((e) => e.checkFlag == 1),
                            onChanged: (newValue) => context.read<NotificationsPageCubit>().updateSettings(newValue! ? 1 : 0, -1),
                          ),
                          Expanded(
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: state.notifications.length,
                              itemBuilder: (context, index) {
                                final notification = state.notifications[index];
                                return Column(
                                  children: [
                                    GlassCard(
                                      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                      padding: EdgeInsets.zero,
                                      child: CheckboxListTile(
                                        title: Text(notification.msgDesc),
                                        value: notification.checkFlag == 1,
                                        contentPadding:
                                        const EdgeInsets.symmetric(horizontal: 10),
                                        onChanged: (newValue) => context.read<NotificationsPageCubit>().updateSettings(newValue! ? 1 : 0, index),
                                      ),
                                    ),
                                    if (index == state.notifications.length - 1)
                                      const SizedBox(height: 80),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is UpdateNotificationsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return const SizedBox();
                },
              ),
              floatingActionButton: Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: ActionButton(
                        onPressed: () {
                          final currentState = context.read<NotificationsPageCubit>().state;
                          if (currentState is GetNotificationsLoaded) {
                            final List<Map<String, dynamic>> notificationsJson = currentState.notifications.map((entity) => entity.toModel().toJson()).toList();
                            final Map<String, dynamic> body = {
                              "msgCodeList": notificationsJson,
                            };
                            context.read<NotificationsPageCubit>().subscribeNotifications(userId, controllerId, subUserId, body);
                          }
                        },
                        isPrimary: true,
                        child: context.watch<NotificationsPageCubit>().state is UpdateNotificationsLoading
                            ? CircularProgressIndicator()
                            : Text("Subscribe"),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ActionButton(
                        onPressed: () => context.pop(),
                        child: const Text("Cancel"),
                      ),
                    ),
                  ],
                ),
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            ),
          );
        }
      ),
    );
  }
}