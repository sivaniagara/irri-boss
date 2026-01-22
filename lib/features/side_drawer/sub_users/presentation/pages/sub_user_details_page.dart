import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_switch.dart';

import '../../../../../core/widgets/custom_phone_field.dart';
import '../../../../../core/widgets/glass_effect.dart';
import '../../../../../core/widgets/retry.dart';
import '../../sub_users_barrel.dart';

class SubUserDetailsScreen extends StatelessWidget {
  final GetSubUserDetailsParams subUserDetailsParams;

  const SubUserDetailsScreen({
    super.key,
    required this.subUserDetailsParams,
  });

  @override
  Widget build(BuildContext dialogContext) {
    dialogContext.read<SubUsersBloc>().add(
      GetSubUserDetailsEvent(subUserDetailsParams: subUserDetailsParams),
    );
    return BlocConsumer<SubUsersBloc, SubUsersState>(
      listener: _buildListener(dialogContext),
      builder: (context, state) => _buildBody(context, state),
    );
  }

  void Function(BuildContext, SubUsersState) _buildListener(BuildContext context) {
    return (context, state) {
      if (state is SubUserDetailsUpdateSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message)),
        );

        // Refresh the parent list
        context.read<SubUsersBloc>().add(
          GetSubUsersEvent(userId: subUserDetailsParams.userId),
        );

        Future.delayed(const Duration(milliseconds: 800), () {
          if (context.mounted) context.pop();
        });
      } else if (state is SubUserDetailsUpdateError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message), backgroundColor: Colors.red),
        );
      }
    };
  }

  Widget _buildBody(BuildContext context, SubUsersState state) {
    final formKey = GlobalKey<FormState>();
    final nameKey = GlobalKey<FormFieldState>();
    late TextEditingController nameController;
    late TextEditingController phoneController;

    if (state is SubUserDetailsLoading ||
        state is SubUserInitial ||
        state is SubUserDetailsUpdateStarted) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is SubUserDetailsError || state is SubUserDetailsUpdateError) {
      return Retry(
        message: state is SubUserDetailsUpdateError
            ? state.message
            : state is SubUserDetailsError
            ? state.message
            : 'Unknown',
        onPressed: () => context.read<SubUsersBloc>().add(
          GetSubUserDetailsEvent(subUserDetailsParams: subUserDetailsParams),
        ),
      );
    }

    if (state is SubUserDetailsUpdateSuccess) {
      return Center(child: Text(state.message));
    }

    if (state is GetSubUserByPhoneError) {
      nameController = TextEditingController(text: state.subUserDetails.subUserDetail.userName);
      phoneController = TextEditingController(text: "${state.subUserDetails.subUserDetail.mobileCountryCode}${state.subUserDetails.subUserDetail.mobileNumber}");
      return _buildLoadedUI(context, state.subUserDetails, formKey, nameKey, nameController, phoneController);
    }

    if (state is SubUserDetailsLoaded) {
      nameController = TextEditingController(text: state.subUserDetails.subUserDetail.userName);
      phoneController = TextEditingController(text: "${state.subUserDetails.subUserDetail.mobileCountryCode}${state.subUserDetails.subUserDetail.mobileNumber}");
      return _buildLoadedUI(context, state.subUserDetails, formKey, nameKey, nameController, phoneController);
    }

    return const Center(child: Text('Unexpected state. Please retry.'));
  }

  Widget _buildLoadedUI(
      BuildContext context,
      SubUserDetailsEntity subUserDetails,
      GlobalKey<FormState> formKey,
      GlobalKey<FormFieldState> nameKey,
      TextEditingController nameController,
      TextEditingController phoneController,
      ) {
    final subUserDetail = subUserDetails.subUserDetail;

    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassCard(
              opacity: 1,
                blur: 0,
                borderRadius: BorderRadius.circular(12),
                margin: EdgeInsets.zero,
                padding: EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sub-user Code',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          subUserDetail.subUserCode,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5,),
                    Divider(),
                    SizedBox(height: 5,),
                    Text(
                      'Sub user mobile number',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildPhoneField(
                      context,
                      subUserDetail.mobileNumber,
                      subUserDetail.mobileCountryCode,
                      context.read<SubUsersBloc>(),
                      phoneController
                    ),
                  ],
                )
            ),
            const SizedBox(height: 16),

            GlassCard(
              opacity: 1,
              blur: 0,
              borderRadius: BorderRadius.circular(12),
              margin: EdgeInsets.zero,
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Text(
                    'Sub user name',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey, width: 0.5)
                    ),
                    child: Row(
                      spacing: 15,
                      children: [
                        Icon(Icons.person, color: Colors.black,),
                        Text(subUserDetails.subUserDetail.userName, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ))
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            GlassCard(
              opacity: 1,
              blur: 0,
              borderRadius: BorderRadius.circular(12),
              margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    color: Colors.grey.withOpacity(0.08),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'List of controllers',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'DND',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // List of controllers
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: subUserDetails.controllerList.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final controller = subUserDetails.controllerList[index];
                      return _buildControllerTile(
                        controller: controller,
                        index: index + 1,
                        blocContext: context,
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _buildActionButtons(
              context,
              formKey,
              nameKey,
              nameController,
              subUserDetails,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneField(
      BuildContext context,
      String initialPhone,
      String countryCode,
      SubUsersBloc bloc,
      TextEditingController phoneController
      ) {
    return CustomPhoneField(
      initialCountryCode: 'IN',
      initialValue: initialPhone,
      controller: phoneController,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        labelText: 'Sub User Phone number',
        errorStyle: const TextStyle(color: Colors.redAccent),
        suffix: InkWell(
          onTap: () {
            final fullPhone = phoneController.text;
            bloc.add(
              GetSubUserByPhoneEvent(getSubUserByPhoneParams: GetSubUserByPhoneParams(phoneNumber: fullPhone)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Icon(
                Icons.done_outline_rounded,
                color: Colors.green
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
              label: Text(label),
            border: InputBorder.none,
            enabledBorder: InputBorder.none
          ),
          onChanged: onChanged,
          readOnly: true,
          validator: (value) => value?.isEmpty == true ? 'Name is required' : null,
        ),
      ],
    );
  }

  Widget _buildControllerTile({
    required SubUserControllerEntity controller,
    required int index,
    required BuildContext blocContext,
  }) {
    final isSelected = controller.shareFlag == 1;
    final isEnabled = controller.dndStatus == '1';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        children: [
          Checkbox(
            value: isSelected,
            onChanged: (value) {
              blocContext.read<SubUsersBloc>().add(
                UpdateControllerSelectionEvent(
                  controllerIndex: index,
                  isSelected: value ?? false,
                ),
              );
            },
          ),
          Expanded(child: Text(controller.deviceName, style: Theme.of(blocContext).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ))),
          const SizedBox(width: 16),
          SizedBox(
            width: 55,
            height: 25,
            child: CustomSwitch(
              value: isEnabled,
              onChanged: (value) {
                blocContext.read<SubUsersBloc>().add(
                  UpdateControllerDndEvent(
                    controllerIndex: index,
                    isEnabled: value,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context,
      GlobalKey<FormState> formKey,
      GlobalKey<FormFieldState> nameKey,
      TextEditingController nameController,
      SubUserDetailsEntity subUserDetails,
      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _handleSubmit(
              context,
              formKey,
              nameController,
              subUserDetails,
              isDelete: true,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _handleSubmit(
              context,
              formKey,
              nameController,
              subUserDetails,
            ),
            child: const Text('Submit'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => context.pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            child: const Text('Cancel'),
          ),
        ),
      ],
    );
  }

  void _handleSubmit(
      BuildContext context,
      GlobalKey<FormState> formKey,
      TextEditingController nameController,
      SubUserDetailsEntity subUserDetails, {
        bool isDelete = false,
      }) async {
    if (formKey.currentState!.validate()) {
      final bloc = context.read<SubUsersBloc>();
      final fullPhone = subUserDetails.subUserDetail.mobileNumber;
      final countryCode = subUserDetails.subUserDetail.mobileCountryCode;
      final updatedName = nameController.text.trim();

      final updatedSubUserDetail = subUserDetails.subUserDetail.copyWith(
        mobileNumber: fullPhone,
        userName: updatedName,
        mobileCountryCode: countryCode,
      );

      final updatedDetails = SubUserDetailsEntity(
        subUserDetail: updatedSubUserDetail,
        controllerList: subUserDetails.controllerList,
      );

      bloc.add(
        SubUserDetailsUpdateEvent(
          updatedDetails: UpdateSubUserDetailsParams(
            subUserDetailsEntity: updatedDetails,
            userId: subUserDetailsParams.userId,
            isNewSubUser: subUserDetailsParams.isNewSubUser,
            isDelete: isDelete,
          ),
        ),
      );

      // Small delay before pop to allow snackbar to be visible
      await Future.delayed(const Duration(milliseconds: 400));
      if (context.mounted) context.pop();
    }
  }
}