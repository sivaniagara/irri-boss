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
            child: ListView.separated(
              itemCount: state.subUsersList.length,
              physics: BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              itemBuilder: (context, index) {
                final SubUserEntity subUserEntity = state.subUsersList[index];
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  minTileHeight: 40,
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    child: Icon(Icons.person, color: Colors.grey, size: 30,),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  title: Text(subUserEntity.userName, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(subUserEntity.mobileNumber),
                  tileColor: Colors.white,
                  trailing: Icon(Icons.chevron_right),
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
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(height: 10,);
              },
            ),
          );
        }
        return const Center(child: Text("Loading sub-users..."));
      },
    );
  }
}