import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glass_effect.dart';
import 'package:niagara_smart_drip_irrigation/features/auth/utils/auth_routes.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../dashboard/utils/dashboard_routes.dart';

class DealerDashboardPage extends StatelessWidget {
  final Map<String, dynamic> userData;
  const DealerDashboardPage({super.key, required this.userData});

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
    final queryParams = GoRouterState.of(dialogContext).uri.queryParameters;
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
                        context.push(
                          '$route?userId=${queryParams['userId']}&userType=${queryParams['userType']}',
                        );
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
      child: GlassCard(
        opacity: 1,
        blur: 0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36,color: Theme.of(context).primaryColor,),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
