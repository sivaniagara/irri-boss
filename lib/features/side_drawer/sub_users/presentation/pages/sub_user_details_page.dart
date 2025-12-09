import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
      listener: _buildListener(dialogContext),  // extract for clarity
      builder: (context, state) => _buildBody(context, state),
    );
  }

  void Function(BuildContext, SubUsersState) _buildListener(BuildContext context) {
    return (context, state) {
      if (state is SubUserDetailsUpdateSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message)),
        );

        // THIS IS THE SAME BLOC as in SubUsers list → will refresh the list!
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
    final phoneKey = GlobalKey<CustomPhoneFieldState>();
    final nameKey = GlobalKey<FormFieldState>();
    late TextEditingController nameController;

    if (state is SubUserDetailsLoading || state is SubUserInitial || state is SubUserDetailsUpdateStarted) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is SubUserDetailsError || state is SubUserDetailsUpdateError) {
      return Retry(
          message: state is SubUserDetailsUpdateError
              ? state.message
              : state is SubUserDetailsError ? state.message : 'Unknown',
          onPressed: () => context.read<SubUsersBloc>().add(
            GetSubUserDetailsEvent(subUserDetailsParams: subUserDetailsParams),
          )
      );
    }

    if (state is SubUserDetailsUpdateSuccess) {
      return Center(child: Text(state.message));
    }

    if (state is GetSubUserByPhoneError) {
      nameController = TextEditingController(text: state.subUserDetails.subUserDetail.userName);
      return _buildLoadedUI(context, state.subUserDetails, formKey, phoneKey, nameKey, nameController);
    }

    if (state is SubUserDetailsLoaded) {
      nameController = TextEditingController(text: state.subUserDetails.subUserDetail.userName);
      return _buildLoadedUI(context, state.subUserDetails, formKey, phoneKey, nameKey, nameController);
    }

    return const Center(child: Text('Unexpected state. Please retry.'));
  }

  Widget _buildLoadedUI(BuildContext context, SubUserDetailsEntity subUserDetails, GlobalKey<FormState> formKey, GlobalKey<CustomPhoneFieldState> phoneKey, GlobalKey<FormFieldState> nameKey, TextEditingController nameController) {
    final subUserDetail = subUserDetails.subUserDetail;
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFieldRow(
              label: 'Sub-user Code',
              value: subUserDetail.subUserCode,
              theme: Theme.of(context),
            ),
            const SizedBox(height: 16),
            _buildPhoneField(context, subUserDetail.mobileNumber, phoneKey, subUserDetail.mobileCountryCode, context.read<SubUsersBloc>()),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Sub-user name',
              controller: nameController,
              onChanged: (value) {},
            ),
            const SizedBox(height: 24),
            const Text(
              'List of controllers',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...subUserDetails.controllerList.asMap().entries.map((entry) {
              final index = entry.key;
              final controller = entry.value;
              return _buildControllerTile(
                controller: controller,
                index: index,
                blocContext: context,
              );
            }),
            const SizedBox(height: 24),
            _buildActionButtons(context, formKey, phoneKey, nameKey, nameController, subUserDetails),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldRow({required String label, required String value, required ThemeData theme}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(width: 16),
        Text(value, style: theme.textTheme.titleLarge),
      ],
    );
  }

  Widget _buildPhoneField(
      BuildContext context,
      String initialPhone,
      GlobalKey<CustomPhoneFieldState> phoneKey,
      String countryCode,
      SubUsersBloc bloc,
      ) {
    return CustomPhoneField(
      key: phoneKey,
      initialCountryCode: 'IN',
      initialValue: initialPhone,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        labelText: 'Sub User Phone number',
        errorStyle: const TextStyle(color: Colors.redAccent),
        suffix: InkWell(
          onTap: () {
            final fullPhone = phoneKey.currentState!.phoneNumber;
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
          ),
          onChanged: onChanged,
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

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(vertical: 0),
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
          Expanded(child: Text(controller.deviceName)),
          const SizedBox(width: 16),
          const Text('DND'),
          Switch(
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
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context,
      GlobalKey<FormState> formKey,
      GlobalKey<CustomPhoneFieldState> phoneKey,
      GlobalKey<FormFieldState> nameKey,
      TextEditingController nameController,
      SubUserDetailsEntity subUserDetails,
      ) {
    return Row(
      spacing: 15,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _handleSubmit(context, formKey, phoneKey, nameController, subUserDetails, isDelete: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _handleSubmit(context, formKey, phoneKey, nameController, subUserDetails),
            child: const Text('Submit'),
          ),
        ),
        Expanded(
          child: ElevatedButton(
            onPressed: () => context.pop(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
            child: const Text('Cancel'),
          ),
        ),
      ],
    );
  }

  void _handleSubmit(
      BuildContext context,
      GlobalKey<FormState> formKey,
      GlobalKey<CustomPhoneFieldState> phoneKey,
      TextEditingController nameController,
      SubUserDetailsEntity subUserDetails,
      {bool isDelete = false}
      ) async{
    if (formKey.currentState!.validate()) {
      final bloc = context.read<SubUsersBloc>();
      final fullPhone = phoneKey.currentState!.phoneNumber;
      final countryCode = phoneKey.currentState!.countryCode;
      final updatedName = nameController.text;

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
                  isDelete: isDelete
              )
          )
      );
      await Future.delayed(Duration(milliseconds: 500));
      context.pop();
    }
  }
}