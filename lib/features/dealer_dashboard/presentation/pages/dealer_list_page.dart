import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glass_effect.dart';
import 'package:niagara_smart_drip_irrigation/features/dealer_dashboard/presentation/cubit/dealer_list_cubit.dart';
import 'package:niagara_smart_drip_irrigation/features/dealer_dashboard/utils/dealer_routes.dart';

import '../../../dashboard/utils/dashboard_routes.dart';

class DisplayItem {
  final String title;
  final String subtitle;
  final String id;
  final String initial;

  DisplayItem({
    required this.title,
    required this.subtitle,
    required this.id,
    required this.initial,
  });
}

class DealerListPage extends StatefulWidget {
  const DealerListPage({super.key});

  @override
  State<DealerListPage> createState() => _DealerListPageState();
}

class _DealerListPageState extends State<DealerListPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<String, List<DisplayItem>> _getGroupedItems(List<DisplayItem> items) {
    final groupedItems = <String, List<DisplayItem>>{};
    for (var item in items) {
      final initial = item.initial.toUpperCase();
      groupedItems.putIfAbsent(initial, () => []).add(item);
    }
    return groupedItems;
  }

  @override
  Widget build(BuildContext context) {
    final route = GoRouterState.of(context);
    final extra = route.extra as Map<String, dynamic>? ?? {};
    final queryParams = GoRouterState.of(context).uri.queryParameters;

    final name = extra['name'] as String?;
    String title;
    bool isShared = false;
    if (name == DealerRoutes.selectedCustomer) {
      title = 'Selected Customer';
    } else if (name == DealerRoutes.sharedDevice) {
      title = 'Shared Devices';
      isShared = true;
    } else {
      title = 'Customer List';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        bottom: PreferredSize(
            preferredSize: Size(double.maxFinite, 45),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: GlassCard(
                margin: EdgeInsets.zero,
                padding: EdgeInsets.zero,
                opacity: 1,
                borderRadius: BorderRadius.circular(25),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: isShared ? 'Search by device or owner' : 'Search by name or mobile',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () => _searchController.clear(),
                    )
                        : null,
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade800.withOpacity(0.4)
                        : Colors.white,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            )),
      ),
      body: BlocBuilder<DealerListCubit, DealerListState>(
        builder: (context, state) {
          if (state is ListLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ListError) {
            return Center(
              child: Text('Error: ${state.message}'),
            );
          }

          List<DisplayItem> items = [];
          if (state is CustomersLoaded) {
            items = state.customers
                .map((customer) => DisplayItem(
              title: customer.userName,
              subtitle: customer.mobileNumber,
              id: customer.userId.toString(),
              initial: customer.userName[0].toUpperCase(),
            ))
                .toList()
              ..sort((a, b) => a.initial.compareTo(b.initial));
          } else if (state is SharedLoaded) {
            items = state.shared
                .map((device) => DisplayItem(
              title: device.deviceName,
              subtitle: 'Owner: ${device.userName}',
              id: device.userId.toString(),
              initial: device.deviceName[0].toUpperCase(),
            ))
                .toList()
              ..sort((a, b) => a.initial.compareTo(b.initial));
          }

          if (items.isEmpty) {
            return const Center(
              child: Text('No items found.'),
            );
          }

          final filteredItems = items.where((item) {
            return item.title.toLowerCase().contains(_searchQuery) ||
                item.subtitle.toLowerCase().contains(_searchQuery);
          }).toList();

          final groupedItems = _getGroupedItems(filteredItems);
          final sortedKeys = groupedItems.keys.toList()..sort();

          return ListView.builder(
            itemCount: sortedKeys.length,
            itemBuilder: (context, index) {
              final initial = sortedKeys[index];
              final itemsInSection = groupedItems[initial]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      initial,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                  GlassCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 0),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 0),
                    borderRadius: BorderRadius.circular(12),
                    blur: 0,
                    opacity: 1,
                    child: Column(
                      children: [
                        ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: itemsInSection.length,
                          separatorBuilder: (context, index) =>
                          const Divider(),
                          itemBuilder: (context, index) {
                            final item = itemsInSection[index];
                            return ListTile(
                              contentPadding:
                              const EdgeInsets.symmetric(vertical: 8),
                              minTileHeight: 45,
                              leading: CircleAvatar(
                                radius: 22,
                                child: Text(
                                  item.initial,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(
                                item.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                item.subtitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(fontWeight: FontWeight.w400),
                              ),
                              trailing:
                              const Icon(Icons.chevron_right_rounded),
                              onTap: () {
                                context.push(
                                  '${DashBoardRoutes.dashboard}?dealerId=${queryParams['userId']}&userId=${item.id}&userType=2',
                                  extra: extra,
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}