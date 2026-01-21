import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glass_effect.dart';
import 'package:niagara_smart_drip_irrigation/features/auth/utils/auth_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/dealer_dashboard/utils/dealer_routes.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../dashboard/utils/dashboard_routes.dart';
import '../../../service_request/utils/service_request_routes.dart';

class DealerDashboardPage extends StatelessWidget {
  final Map<String, dynamic> userData;
  const DealerDashboardPage({super.key, required this.userData});

  static const _tabs = [
    {
      'icon': Icons.build,
      'label': 'Service Request',
      'route': ServiceRequestRoutes.serviceRequest,
      'description': 'Submit a request for technical support'
    },
    {
      'icon': Icons.sell,
      'label': 'Selling Device',
      'route': DashBoardRoutes.dashboard,
      'description': 'Sell your device simply and securely'
    },
    {
      'icon': Icons.person,
      'label': 'Customer Device',
      'route': DealerRoutes.customerDevice,
      'description': 'Access and manage customer devices'
    },
    {
      'icon': Icons.devices,
      'label': 'My Device',
      'route': DashBoardRoutes.dashboard,
      'description': 'Overview of your device and its status'
    },
    {
      'icon': Icons.mobile_screen_share_rounded,
      'label': 'Shared Device',
      'route': DealerRoutes.sharedDevice,
      'description': 'Devices shared for your access and use'
    },
    {
      'icon': Icons.favorite_rounded,
      'label': 'Selected Customer',
      'route': DealerRoutes.selectedCustomer,
      'description': 'View and manage your chosen customers'
    },
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 32),
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
                    final description = tab['description'] as String;

                    return _glossyCard(
                      context,
                      icon: tab['icon'] as IconData,
                      label: label,
                      description: description,
                      onTap: () {
                        context.push(
                            '$route?userId=${queryParams['userId']}&userType=${queryParams['userType']}',
                            extra: {'name': route});
                      },
                    );
                  },
                ),
              ),
            );
          } else if (authState is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (authState is AuthError) {
            return Center(
                child: Column(children: [
              Text('Error: ${authState.message}'),
              ElevatedButton(
                  onPressed: () =>
                      context.read<AuthBloc>().add(CheckCachedUserEvent()),
                  child: Text('Retry'))
            ]));
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
    required String description,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 1,
      child: ClipRRect(
        borderRadius: BorderRadiusGeometry.circular(12),
        child: Material(
          color: Colors.transparent,
          animationDuration: const Duration(seconds: 1),
          animateColor: true,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                          radius: 25,
                          backgroundColor: Theme.of(context).primaryColor.withAlpha(30),
                          child: Icon(
                            icon,
                            size: 26,
                            color: Theme.of(context).primaryColorDark,
                          )),
                      Text(
                        label,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      Row(
                        spacing: 10,
                        children: [
                          Expanded(
                            child: Text(
                              description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                            ),
                          ),
                          Icon(Icons.arrow_forward, color: Colors.black,)
                        ],
                      )
                    ],
                  ),
                ),
                Positioned(
                  top: -15,
                    right: -10,
                    child: Transform.rotate(
                      angle: 10 * 3.14 / 180,
                      child: ClipOval(
                        child: Container(
                          width: 100,
                          height: 50,
                          color: Theme.of(context).primaryColorDark,
                          alignment: Alignment.center,
                        ),
                      ),
                    )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
