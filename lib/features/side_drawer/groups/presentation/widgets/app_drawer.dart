import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glass_effect.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glassy_wrapper.dart';
import 'package:niagara_smart_drip_irrigation/features/auth/utils/auth_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/dealer_dashboard/utils/dealer_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/side_drawer/groups/utils/group_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/side_drawer/sub_users/utils/sub_user_routes.dart';

import '../../../../../core/utils/route_constants.dart';
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../auth/presentation/bloc/auth_event.dart';
import '../../../../auth/presentation/bloc/auth_state.dart';
import '../../../../dashboard/utils/dashboard_routes.dart';

class AppDrawer extends StatelessWidget {
  final Map<String, dynamic> userData;
  const AppDrawer({super.key, required this.userData});

  @override
  Widget build(BuildContext dialogContext) {
    final theme = Theme.of(dialogContext);

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: [
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    String userName = 'Guest';
                    String? mobile;

                    if (authState is Authenticated) {
                      userName = authState.user.userDetails.name;
                      mobile = authState.user.userDetails.mobile;
                    }

                    return UserAccountsDrawerHeader(
                      decoration: BoxDecoration(color: theme.primaryColorDark),
                      currentAccountPictureSize: const Size(double.maxFinite, 70),
                      accountName: Text(
                        userName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      accountEmail: Text(
                        mobile != null && mobile.isNotEmpty ? mobile : '+91 123456789',
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                      currentAccountPicture: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            clipBehavior: Clip.hardEdge,
                            children: [
                              CircleAvatar(
                                radius: 35,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                child: Text(
                                  userName.isNotEmpty ? userName[0].toUpperCase() : 'G',
                                  style: TextStyle(
                                    fontSize: 22,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(0, 1),
                                        blurRadius: 2,
                                        color: Colors.black.withOpacity(0.3),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              context.push(AuthRoutes.editProfile);
                            },
                            icon: const Icon(Icons.edit, size: 16, color: Colors.white70),
                            label: const Text(
                              'Edit Profile',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              foregroundColor: Colors.white70,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(color: Colors.white.withOpacity(0.3)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    String? homeRoute;
                    if (authState is Authenticated) {
                      final userType = authState.user.userDetails.userType;
                      homeRoute = userType == 2 ? DealerRoutes.dealerDashboard : DashBoardRoutes.dashboard;
                    } else {
                      homeRoute = AuthRoutes.login;
                    }

                    return _buildDrawerItem(
                      context,
                      icon: Icons.home,
                      title: 'Home',
                      route: homeRoute,
                    );
                  },
                ),
                const Divider(indent: 10, endIndent: 10,),
                // Groups (Dynamic Content)
                _buildDrawerItem(
                  dialogContext,
                  icon: Icons.group_work,
                  title: 'Groups',
                  route: GroupRoutes.groups,
                ),
                const Divider(indent: 10, endIndent: 10,),
                // Sub Users
                _buildDrawerItem(
                  dialogContext,
                  icon: Icons.group,
                  title: 'Sub Users',
                  route: SubUserRoutes.subUsers,
                ),
                const Divider(indent: 10, endIndent: 10,),
                // Chat
                _buildDrawerItem(
                  dialogContext,
                  icon: Icons.chat,
                  title: 'Chat',
                  route: RouteConstants.chat,
                ),
                const Divider(indent: 10, endIndent: 10,),
                // Reminder
                _buildDrawerItem(
                  dialogContext,
                  icon: Icons.alarm,
                  title: 'Reminder',
                  // route: RouteConstants.reminder, // Add this route
                ),
                const Divider(indent: 10, endIndent: 10,),
              ],
            ),
          ),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is Authenticated) {
                return ListTile(
                  tileColor: Colors.transparent,
                  leading: Icon(Icons.logout, color: Colors.red,),
                  title: Text(
                    'Logout',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Colors.red
                    ),
                  ),
                  onTap: () {
                    context.read<AuthBloc>().add(LogoutEvent());
                    context.go(AuthRoutes.login);
                    // context.pop();
                  },
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                );
              }
              return _buildDrawerItem(
                context,
                icon: Icons.login,
                title: 'Login',
                route: AuthRoutes.login,
              );
            },
          ),
          SizedBox(height: 20,)
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        String? route,
        VoidCallback? onTap,
      }) {
    return ListTile(
      tileColor: Colors.transparent,
      leading: Icon(icon),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        if (onTap != null) {
          onTap();
        } else if (route != null) {
          context.go('$route?userId=${userData['userId']}&userType=${userData['userType']}');
          Navigator.pop(context);
        }
      },
      trailing: const Icon(Icons.chevron_right),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}