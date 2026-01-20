import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glassy_wrapper.dart';
import 'package:niagara_smart_drip_irrigation/features/dealer_dashboard/utils/dealer_routes.dart';

import '../../../dashboard/utils/dashboard_routes.dart';
import '../cubit/dealer_customer_cubit.dart';

class DealerCustomerListPage extends StatelessWidget {
  const DealerCustomerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final route = GoRouterState.of(context);
    final extra = route.extra != null ? route.extra as Map<String, dynamic> : {};
    final queryParams = GoRouterState.of(context).uri.queryParameters as Map<String, dynamic>;
    return GlassyWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: Text(extra['name'] != null && extra['name'] == DealerRoutes.selectedCustomer ? 'Selected Customer' : 'Customer List'),
        ),
        body: BlocBuilder<DealerCustomerCubit, DealerCustomerState>(
          builder: (context, state) {
            if (state is DealerCustomerLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is DealerCustomerLoaded) {
              if (state.customers.isEmpty) {
                return const Center(
                  child: Text('No customers found.'),
                );
              }

              return ListView.builder(
                itemCount: state.customers.length,
                itemBuilder: (context, index) {
                  final customer = state.customers[index];
                  return ListTile(
                    title: Text(customer.userName),
                    subtitle: Text(customer.mobileNumber),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      context.push(
                        '${DashBoardRoutes.dashboard}?dealerId=${queryParams['userId']}&userId=${customer.userId}&userType=${2}',
                        extra: extra,
                      );
                    },
                  );
                },
              );
            } else if (state is DealerCustomerError) {
              return Center(
                child: Text(state.message),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
