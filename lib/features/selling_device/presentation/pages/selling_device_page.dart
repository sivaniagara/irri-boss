import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_app_bar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../cubit/selling_device_cubit.dart';
import '../cubit/selling_device_state.dart';
import '../../utils/selling_device_routes.dart';

class SellingDevicePage extends StatefulWidget {
  const SellingDevicePage({super.key});

  @override
  State<SellingDevicePage> createState() => _SellingDevicePageState();
}

class _SellingDevicePageState extends State<SellingDevicePage> {
  final TextEditingController _mobileController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _mobileController.addListener(_onMobileChanged);
  }

  void _onMobileChanged() {
    final text = _mobileController.text;
    if (text.length == 10) {
      final queryParams = GoRouterState.of(context).uri.queryParameters;
      final userId = queryParams['userId'] ?? '153';

      final state = context.read<SellingDeviceCubit>().state;
      if (state is SellingDeviceLoaded) {
        context.read<SellingDeviceCubit>().updateMobileNumber(text);

        String? overrideType;
        if (state.userType == '4') {
          if (kDebugMode) {
            print("DEBUG: User type is 'Myself' (4). Mobile: $text");
          }
          final authState = context.read<AuthBloc>().state;
          if (authState is Authenticated) {
            final user = authState.user.userDetails;
            if (kDebugMode) {
              print("DEBUG: Logged-in user mobile: ${user.mobile}, name: ${user.name}, type: ${user.userType}");
            }
            overrideType = user.userType.toString();

            if (user.mobile == text) {
              if (kDebugMode) {
                print("DEBUG: Mobile matched! Setting name locally.");
              }
              context.read<SellingDeviceCubit>().setFetchedUserName(user.name, text, successMessage: "Username successfully listed");
              return;
            }
          }
        }

        context.read<SellingDeviceCubit>().fetchUserName(userId, overrideType: overrideType);
      }
    }
  }

  @override
  void dispose() {
    _mobileController.removeListener(_onMobileChanged);
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final queryParams = GoRouterState.of(context).uri.queryParameters;
    final userId = queryParams['userId'] ?? '153';

    return Scaffold(
      backgroundColor: const Color(0xffF3F4F6),
      appBar: CustomAppBar(
        title: 'Selling Device',
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_rounded, size: 26, color: Theme.of(context).primaryColor),
            onPressed: () => context.push('${SellingDeviceRoutes.traceDevice}?userId=$userId'),
          ),
        ],
      ),
      body: BlocListener<SellingDeviceCubit, SellingDeviceState>(
        listener: (context, state) {
          if (state is SellingDeviceLoaded && state.message != null) {
            final isSuccess = state.message!.contains("successfully") || state.message!.contains("listed");

            if (isSuccess && !state.message!.contains("sold")) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Expanded(child: Text(state.message!, style: const TextStyle(fontWeight: FontWeight.w600))),
                    ],
                  ),
                  backgroundColor: Colors.green.shade600,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  duration: const Duration(seconds: 2),
                ),
              );
              context.read<SellingDeviceCubit>().clearMessage();
            } else if (state.message!.contains("sold")) {
              _showWarningPopup(context, state.message!, isError: false);
            } else {
              _showWarningPopup(context, state.message!, isError: true);
            }
          }
        },
        child: BlocBuilder<SellingDeviceCubit, SellingDeviceState>(
          builder: (context, state) {
            if (state is SellingDeviceLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SellingDeviceLoaded) {
              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: state.categories.length,
                itemBuilder: (context, index) {
                  final category = state.categories[index];
                  final isExpanded = state.expandedCategories.contains(category.categoryId);
                  final units = state.categoryUnits[category.categoryId];

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _categoryHeader(context, category.categoryName, category.categoryId, userId, isExpanded),
                        if (isExpanded && (state.isUnitsLoading || (units != null && units.isNotEmpty)))
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xffF9FAFB),
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
                            ),
                            child: Column(
                              children: [
                                if (state.isUnitsLoading && units == null)
                                  const Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator(strokeWidth: 2))
                                else ...[
                                  ...units!.map((unit) => _productItem(context, unit, state)),
                                  if (state.selectedProductIds.isNotEmpty)
                                    _premiumSalesForm(context, state, userId),
                                ]
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            } else if (state is SellingDeviceError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _categoryHeader(BuildContext context, String name, int categoryId, String userId, bool isExpanded) {
    return InkWell(
      onTap: () => context.read<SellingDeviceCubit>().toggleCategory(categoryId, userId),
      borderRadius: BorderRadius.vertical(
        top: const Radius.circular(15),
        bottom: Radius.circular(isExpanded ? 0 : 15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xffB4E7FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.inventory_2_rounded, size: 22, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            Icon(
              isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
              size: 26,
              color: Colors.black45,
            ),
          ],
        ),
      ),
    );
  }

  Widget _productItem(BuildContext context, dynamic unit, SellingDeviceLoaded state) {
    final isSelected = state.selectedProductIds.contains(unit.productId);
    return InkWell(
      onTap: () => context.read<SellingDeviceCubit>().toggleProductSelection(unit.productId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade400,
                  width: 1.5,
                ),
                color: isSelected ? Theme.of(context).primaryColor : Colors.white,
              ),
              child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(unit.modelName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87)),
                  const SizedBox(height: 2),
                  Text("ID: ${unit.deviceId} • PID: ${unit.productId}", style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _premiumSalesForm(BuildContext context, SellingDeviceLoaded state, String userId) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xffB1E4AA),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.person_add_rounded, size: 16, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(width: 10),
              const Text(
                "Sales Details",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  height: 45,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xffF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: state.userType,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                      style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500),
                      items: const [
                        DropdownMenuItem(value: '1', child: Text('Customer')),
                        DropdownMenuItem(value: '2', child: Text('Dealer')),
                        DropdownMenuItem(value: '3', child: Text('Admin')),
                        DropdownMenuItem(value: '4', child: Text('Myself')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          context.read<SellingDeviceCubit>().updateUserType(val);
                          if (_mobileController.text.length == 10) {
                            _onMobileChanged();
                          }
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 45,
                  child: TextField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: "Mobile Number",
                      hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      filled: true,
                      fillColor: const Color(0xffF3F4F6),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      suffixIcon: state.isUsernameLoading
                          ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2))
                          : Icon(Icons.phone_android_rounded, size: 18, color: Colors.grey.shade600),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (state.fetchedUserName != null)
            Container(
              margin: const EdgeInsets.only(top: 14),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade100),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_rounded, color: Colors.green, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Assigning to: ${state.fetchedUserName}",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green.shade700),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: (state.fetchedUserName != null && !state.isSalesLoading)
                  ? () {
                String? sellerType;
                final authState = context.read<AuthBloc>().state;
                if (authState is Authenticated) {
                  sellerType = authState.user.userDetails.userType.toString();
                }
                context.read<SellingDeviceCubit>().processSale(userId, overrideType: sellerType);
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: state.isSalesLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("COMPLETE SALE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5)),
            ),
          ),
        ],
      ),
    );
  }

  void _showWarningPopup(BuildContext context, String message, {bool isError = true}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (isError ? Colors.red : Colors.green).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isError ? Icons.warning_amber_rounded : Icons.verified_rounded,
                  size: 48,
                  color: isError ? Colors.red : Colors.green,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isError ? "Attention Required" : "Sale Successful",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.4),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<SellingDeviceCubit>().clearMessage();
                    Navigator.of(dialogContext).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isError ? Colors.black87 : Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("CONTINUE", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
