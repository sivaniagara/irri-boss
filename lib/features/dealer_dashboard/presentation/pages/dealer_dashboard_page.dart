import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/features/auth/utils/auth_routes.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../dashboard/utils/dashboard_routes.dart';

class DealerDashboardPage extends StatelessWidget {
  const DealerDashboardPage({super.key});

  static const _tabs = [
    {'icon': Icons.build, 'label': 'Service Request', 'route': DashBoardRoutes.dashboard},
    {'icon': Icons.sell, 'label': 'Selling Device', 'route': DashBoardRoutes.dashboard},
    {'icon': Icons.person_search, 'label': 'Customer Device', 'route': DashBoardRoutes.dashboard},
    {'icon': Icons.devices, 'label': 'My Device', 'route': DashBoardRoutes.dashboard},
    {'icon': Icons.group_work, 'label': 'Shared Device', 'route': DashBoardRoutes.dashboard},
    {'icon': Icons.check_box, 'label': 'Selected Customer', 'route': DashBoardRoutes.dashboard},
  ];

  @override
  Widget build(BuildContext dialogContext) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is LoggedOut) {
          context.go(AuthRoutes.login);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is Authenticated) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  itemCount: _tabs.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
                  itemBuilder: (context, index) {
                    final tab = _tabs[index];
                    final label = tab['label'] as String;
                    final route = tab['route'] as String;

                    return _glossyCard(
                      context,
                      icon: tab['icon'] as IconData,
                      label: label,
                      onTap: () {
                        context.push(route);
                      },
                    );
                  },
                ),
              ),
            );
          } else if (authState is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (authState is AuthError) {
            return Center(child: Column(children: [Text('Error: ${authState.message}'), ElevatedButton(onPressed: () => context.read<AuthBloc>().add(CheckCachedUserEvent()), child: Text('Retry'))]));
          } else {
            return const Center(child: Text('Please log in'));
          }
        },
      ),
    );
  }

  Widget _glossyCard(
      BuildContext context, {
        required IconData icon,
        required String label,
        VoidCallback? onTap,
      }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.04),
                  Colors.white.withOpacity(0.2),
                ],
              ),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 36, color: Colors.white70),
                const SizedBox(height: 12),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
