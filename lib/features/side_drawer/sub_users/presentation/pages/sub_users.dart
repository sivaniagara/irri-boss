import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glass_effect.dart';
import 'package:niagara_smart_drip_irrigation/features/side_drawer/sub_users/utils/sub_user_routes.dart';

import '../../sub_users_barrel.dart';

class SubUsers extends StatelessWidget {
  final int userId;
  const SubUsers({super.key, required this.userId});

  @override
  Widget build(BuildContext dialogContext) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (dialogContext.read<SubUsersBloc>().state is! SubUsersLoaded) {
        dialogContext.read<SubUsersBloc>().add(GetSubUsersEvent(userId: userId));
      }
    });
    return BlocBuilder<SubUsersBloc, SubUsersState>(
      builder: (context, state) {
        if (state is SubUserLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is SubUsersError) {
          return Center(child: Text(state.message));
        }
        if (state is SubUsersLoaded) {
          return RefreshIndicator(
            onRefresh: () async{
              context.read<SubUsersBloc>().add(GetSubUsersEvent(userId: userId));
              await context.read<SubUsersBloc>().stream
                  .firstWhere((s) => s is SubUsersLoaded || s is SubUsersError);
            },
            child: ListView.builder(
              itemCount: state.subUsersList.length,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              itemBuilder: (context, index) {
                final isFirst = index == 0;
                final SubUserEntity subUserEntity = state.subUsersList[index];
                final isLast = index == state.subUsersList.length - 1;
                final borderRadius = BorderRadius.only(
                  topLeft: isFirst ? const Radius.circular(16) : Radius.zero,
                  topRight: isFirst ? const Radius.circular(16) : Radius.zero,
                  bottomLeft: isLast ? const Radius.circular(16) : Radius.zero,
                  bottomRight: isLast ? const Radius.circular(16) : Radius.zero,
                );
                return GlassCard(
                  padding: EdgeInsets.zero,
                  borderRadius: borderRadius,
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    minTileHeight: 40,
                    leading: Text(subUserEntity.subUserCode),
                    title: Text(subUserEntity.userName, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(subUserEntity.mobileNumber),
                    onTap: () {
                      final bloc = context.read<SubUsersBloc>();
                      context.push(
                          SubUserRoutes.subUserDetails,
                          extra: {
                            "userId": userId,
                            "subUserCode": subUserEntity.subUserCode,
                            "isNewSubUser": subUserEntity.sharedUserId.toString().isEmpty,
                            "existingBloc": bloc,
                          });
                    },
                  ),
                );
              },
            ),
          );
        }
        return const Center(child: Text("Loading sub-users..."));
      },
    );
  }
}