import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/features/auth/utils/auth_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/dealer_dashboard/utils/dealer_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/side_drawer/groups/utils/group_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/side_drawer/sub_users/utils/sub_user_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/standalone_settings/utils/standalone_routes.dart';

import '../../../../../core/utils/route_constants.dart';
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../auth/presentation/bloc/auth_event.dart';
import '../../../../auth/presentation/bloc/auth_state.dart';
import '../../../../dashboard/utils/dashboard_routes.dart';

class AppDrawer extends StatelessWidget {
  final Map<String, dynamic> userData;
  const AppDrawer({super.key, required this.userData});

  String _formatMobile(String mobile) {
    if (mobile.isEmpty || mobile == 'No Number') return mobile;
    
    // Remove all non-digits
    String digits = mobile.replaceAll(RegExp(r'\D'), '');
    
    if (digits.length >= 10) {
      String country = digits.substring(0, digits.length - 10);
      String number = digits.substring(digits.length - 10);
      
      if (country.isEmpty) return number;
      return '+$country $number';
    }
    return mobile;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                    String mobile = 'No Number';

                    if (authState is Authenticated) {
                      userName = authState.user.userDetails.name;
                      mobile = authState.user.userDetails.mobile;
                    }

                    return UserAccountsDrawerHeader(
                      decoration: BoxDecoration(color: theme.primaryColor),
                      accountName: Text(
                        userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      accountEmail: Text(
                        _formatMobile(mobile),
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      currentAccountPicture: CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : 'G',
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      otherAccountsPictures: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                            context.push(AuthRoutes.editProfile);
                          },
                          icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                          tooltip: 'Edit Profile',
                        ),
                      ],
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.home,
                  title: 'Home',
                  onTap: () {
                    final authState = context.read<AuthBloc>().state;
                    if (authState is Authenticated) {
                      final userId = authState.user.userDetails.id;
                      final userType = authState.user.userDetails.userType;
                      final route = userType == 2 ? DealerRoutes.dealerDashboard : DashBoardRoutes.dashboard;
                      context.go('$route?userId=$userId&userType=$userType');
                    } else {
                      context.go(AuthRoutes.login);
                    }
                    Navigator.pop(context);
                  },
                ),
                const Divider(indent: 10, endIndent: 10),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings_remote,
                  title: 'Standalone Settings',
                  onTap: () {
                    context.push(
                      StandaloneRoutes.standalone,
                      extra: {
                        'userId': userData['userId'],
                        'controllerId': userData['controllerId'],
                        'userType': userData['userType'],
                        'subUserId': userData['subUserId'] ?? '0',
                        'deviceId': userData['deviceId'] ?? '',
                      },
                    );
                    Navigator.pop(context);
                  },
                ),
                const Divider(indent: 10, endIndent: 10),
                _buildDrawerItem(
                  context,
                  icon: Icons.group_work,
                  title: 'Groups',
                  onTap: () {
                    context.push(GroupRoutes.groups);
                    Navigator.pop(context);
                  },
                ),
                const Divider(indent: 10, endIndent: 10),
                _buildDrawerItem(
                  context,
                  icon: Icons.group,
                  title: 'Sub Users',
                  onTap: () {
                    context.push(SubUserRoutes.subUsers);
                    Navigator.pop(context);
                  },
                ),
                const Divider(indent: 10, endIndent: 10),
                _buildDrawerItem(
                  context,
                  icon: Icons.chat,
                  title: 'Chat',
                  onTap: () {
                    context.push(RouteConstants.chat);
                    Navigator.pop(context);
                  },
                ),
                const Divider(indent: 10, endIndent: 10),
                _buildDrawerItem(
                  context,
                  icon: Icons.alarm,
                  title: 'Reminder',
                  onTap: () {
                    // Navigate to reminder
                    Navigator.pop(context);
                  },
                ),
                const Divider(indent: 10, endIndent: 10),
              ],
            ),
          ),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is Authenticated) {
                return ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Logout',
                    style: TextStyle(fontWeight: FontWeight.w500, color: Colors.red),
                  ),
                  onTap: () {
                    context.read<AuthBloc>().add(LogoutEvent());
                    context.go(AuthRoutes.login);
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
      }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
      trailing: const Icon(Icons.chevron_right),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
