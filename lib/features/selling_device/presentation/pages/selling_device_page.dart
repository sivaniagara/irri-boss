import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_app_bar.dart';
import '../../../../core/theme/app_themes.dart';
import '../../../../core/utils/app_images.dart';
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
          final authState = context.read<AuthBloc>().state;
          if (authState is Authenticated) {
            final user = authState.user.userDetails;
            overrideType = user.userType.toString();

            if (user.mobile == text) {
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppThemes.scaffoldBackGround,
      appBar: CustomAppBar(
        title: 'Inventory & Sales',
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.qr_code_scanner_rounded, size: 22, color: theme.primaryColor),
              onPressed: () => context.push('${SellingDeviceRoutes.traceDevice}?userId=$userId'),
            ),
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
                padding: const EdgeInsets.only(top: 8, bottom: 24),
                itemCount: state.categories.length,
                itemBuilder: (context, index) {
                  final category = state.categories[index];
                  final isExpanded = state.expandedCategories.contains(category.categoryId);
                  final units = state.categoryUnits[category.categoryId];

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: isExpanded ? theme.primaryColor.withOpacity(0.3) : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _categoryHeader(context, category.categoryName, category.categoryId, userId, isExpanded),
                        if (isExpanded) ...[
                          const Divider(height: 1, indent: 16, endIndent: 16),
                          if (state.isUnitsLoading && units == null)
                            const Padding(padding: EdgeInsets.all(24.0), child: CircularProgressIndicator(strokeWidth: 2))
                          else if (units != null && units.isEmpty)
                            const Padding(padding: EdgeInsets.all(24.0), child: Text("No devices available in this category", style: TextStyle(color: Colors.grey, fontSize: 13)))
                          else if (units != null) ...[
                            ...units.map((unit) => _productItem(context, unit, state)),
                            if (state.selectedProductIds.isNotEmpty)
                              _refinedSalesForm(context, state, userId),
                          ]
                        ],
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
      borderRadius: BorderRadius.only(
        topRight: const Radius.circular(20),
        bottomLeft: Radius.circular(isExpanded ? 0 : 20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isExpanded ? AppThemes.primaryColor.withOpacity(0.1) : const Color(0xffF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                AppImages.mappedNodesIcon,
                width: 22,
                color: isExpanded ? AppThemes.primaryColor : Colors.black54,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isExpanded ? AppThemes.primaryColor : Colors.black87,
                    ),
                  ),
                  const Text("Tap to view devices", style: TextStyle(fontSize: 11, color: Colors.black45)),
                ],
              ),
            ),
            Icon(
              isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
              size: 28,
              color: isExpanded ? AppThemes.primaryColor : Colors.black38,
            ),
          ],
        ),
      ),
    );
  }

  Widget _productItem(BuildContext context, dynamic unit, SellingDeviceLoaded state) {
    final isSelected = state.selectedProductIds.contains(unit.productId);
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => context.read<SellingDeviceCubit>().toggleProductSelection(unit.productId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor.withOpacity(0.02) : Colors.transparent,
          border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.05))),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? theme.primaryColor : Colors.grey.shade300,
                  width: 2,
                ),
                color: isSelected ? theme.primaryColor : Colors.white,
              ),
              child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Image.asset(AppImages.communicationNodeIcon, width: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    unit.modelName,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      fontSize: 14,
                      color: isSelected ? theme.primaryColor : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      _badge("SN: ${unit.deviceId}", Colors.blueGrey.shade50, Colors.blueGrey.shade600),
                      const SizedBox(width: 6),
                      _badge("PID: ${unit.productId}", Colors.blue.shade50, Colors.blue.shade700),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: text)),
    );
  }

  Widget _refinedSalesForm(BuildContext context, SellingDeviceLoaded state, String userId) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xffF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.primaryColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shopping_bag_rounded, size: 20, color: AppThemes.primaryColor),
              const SizedBox(width: 10),
              Text(
                "Complete Assignment (${state.selectedProductIds.length})",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Role", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54)),
                    const SizedBox(height: 6),
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: state.userType,
                          isExpanded: true,
                          icon: const Icon(Icons.expand_more_rounded, color: Colors.black45),
                          style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w600),
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
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Mobile Number", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54)),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 48,
                      child: TextField(
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                        decoration: InputDecoration(
                          hintText: "10-digit number",
                          hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400, fontWeight: FontWeight.normal),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: theme.primaryColor, width: 1.5)),
                          suffixIcon: state.isUsernameLoading
                              ? const Padding(padding: EdgeInsets.all(14), child: CircularProgressIndicator(strokeWidth: 2))
                              : Icon(Icons.phone_android_rounded, size: 18, color: theme.primaryColor.withOpacity(0.5)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (state.fetchedUserName != null)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade100),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                    child: const Icon(Icons.check, color: Colors.white, size: 12),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Validated User", style: TextStyle(fontSize: 11, color: Colors.green)),
                        Text(
                          state.fetchedUserName!,
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.green.shade900),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
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
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                shadowColor: theme.primaryColor.withOpacity(0.3),
              ),
              child: state.isSalesLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : const Text("FINALIZE TRANSACTION", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 1)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: (isError ? Colors.red : Colors.green).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                  size: 56,
                  color: isError ? Colors.red : Colors.green,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isError ? "Transaction Failed" : "Success",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<SellingDeviceCubit>().clearMessage();
                    Navigator.of(dialogContext).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isError ? Colors.black87 : Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text("CONTINUE", style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
