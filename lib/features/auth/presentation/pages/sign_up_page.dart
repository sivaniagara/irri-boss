import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../../core/widgets/glassy_wrapper.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

class UserProfileForm extends StatelessWidget {
  final bool isEdit;
  final UserEntity? initialData;

  const UserProfileForm({
    super.key,
    required this.isEdit,
    this.initialData,
  });

  @override
  Widget build(BuildContext dialogContext) {
    // Reuse existing AuthBloc from DI instead of creating new one
    return _UserProfileFormBody(isEdit: isEdit, initialData: initialData);
  }
}

class _UserProfileFormBody extends StatelessWidget {
  final bool isEdit;
  final UserEntity? initialData;

  const _UserProfileFormBody({required this.isEdit, this.initialData});

  @override
  Widget build(BuildContext dialogContext) {
    final formKey = GlobalKey<FormState>();

    // Controllers
    final nameCtrl = TextEditingController(text: initialData?.name ?? '');
    final address1Ctrl = TextEditingController(text: initialData?.addressOne ?? '');
    final address2Ctrl = TextEditingController(text: initialData?.addressTwo ?? '');
    final townCtrl = TextEditingController(text: initialData?.town ?? '');
    final villageCtrl = TextEditingController(text: initialData?.village ?? '');
    final cityCtrl = TextEditingController(text: initialData?.city ?? '');
    final postalCodeCtrl = TextEditingController(text: initialData?.postalCode ?? '');
    final altPhoneCtrl = TextEditingController(
      text: initialData?.altPhoneNum.isNotEmpty == true
          ? initialData!.altPhoneNum.first
          : '',
    );
    final emailCtrl = TextEditingController(text: initialData?.email ?? '');
    final passwordCtrl = TextEditingController();

    // Phone field state
    String? phoneNumber;           // Full international number (e.g. +918888888888)
    String? phoneCountryCode;      // e.g. "IN"
    String? phoneWithoutCountry;   // e.g. "8888888888"

    String getUserTypeLabel(int? type) {
      const map = {1: 'Customer', 2: 'Dealer', 3: 'Admin'};
      return map[type] ?? '';
    }

    // Dropdown state
    final selectedUserType = ValueNotifier<String?>(
      ['Customer', 'Dealer', 'Admin'].contains(getUserTypeLabel(initialData?.userType))
          ? getUserTypeLabel(initialData?.userType)
          : null,
    );

    final selectedCountry = ValueNotifier<String?>(
      ['India', 'USA', 'UK'].contains(initialData?.country) ? initialData!.country : 'India',
    );

    final selectedState = ValueNotifier<String?>(
      ['State 1', 'State 2', 'State 3'].contains(initialData?.state) ? initialData!.state : null,
    );

    // User type mapping
    int? mapUserTypeToInt(String label) {
      const map = {'Customer': 1, 'Dealer': 2, 'Admin': 3};
      return map[label];
    }

    void submit() {
      if (!formKey.currentState!.validate()) return;

      if (phoneNumber == null || phoneNumber!.isEmpty) {
        ScaffoldMessenger.of(dialogContext).showSnackBar(
          const SnackBar(content: Text('Please enter a valid mobile number')),
        );
        return;
      }

      if (!isEdit && passwordCtrl.text.isEmpty) {
        ScaffoldMessenger.of(dialogContext).showSnackBar(
          const SnackBar(content: Text('Password is required for signup')),
        );
        return;
      }

      if (selectedUserType.value == null) {
        ScaffoldMessenger.of(dialogContext).showSnackBar(
          const SnackBar(content: Text('Please select User Type')),
        );
        return;
      }

      final userTypeInt = mapUserTypeToInt(selectedUserType.value!);

      // Use normalized mobile (last 10 digits or full with country code as per backend)
      final mobileToSend = phoneWithoutCountry ?? phoneNumber!.replaceAll(RegExp(r'\D'), '');

      if (isEdit) {
        dialogContext.read<AuthBloc>().add(UpdateProfileEvent(
          id: initialData!.id,
          name: nameCtrl.text.trim(),
          mobile: mobileToSend,
          userType: userTypeInt,
          addressOne: address1Ctrl.text.trim(),
          addressTwo: address2Ctrl.text.trim(),
          town: townCtrl.text.trim(),
          village: villageCtrl.text.trim(),
          country: selectedCountry.value,
          state: selectedState.value,
          city: cityCtrl.text.trim(),
          postalCode: postalCodeCtrl.text.trim(),
          altPhone: altPhoneCtrl.text.trim(),
          email: emailCtrl.text.trim(),
          password: passwordCtrl.text.isEmpty ? null : passwordCtrl.text,
        ));
      } else {
        dialogContext.read<AuthBloc>().add(SignUpEvent(
          mobile: mobileToSend,
          name: nameCtrl.text.trim(),
          userType: userTypeInt,
          addressOne: address1Ctrl.text.trim(),
          addressTwo: address2Ctrl.text.trim(),
          town: townCtrl.text.trim(),
          village: villageCtrl.text.trim(),
          country: selectedCountry.value,
          state: selectedState.value,
          city: cityCtrl.text.trim(),
          postalCode: postalCodeCtrl.text.trim(),
          altPhone: altPhoneCtrl.text.trim(),
          email: emailCtrl.text.trim(),
          password: passwordCtrl.text,));
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Profile' : 'Sign Up'),
        leading: isEdit
            ? IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(dialogContext),
        )
            : null,
      ),
      body: SafeArea(
        child: GlassyWrapper(
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Personal Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 20),

                  // Mobile Number with intl_phone_field
                  IntlPhoneField(
                    initialCountryCode: _detectInitialCountry(initialData?.mobile),
                    initialValue: _extractPhoneNumber(initialData?.mobile),
                    decoration: _inputDecoration('Mobile Number *', Icons.phone),
                    onChanged: (phone) {
                      phoneNumber = phone.completeNumber;
                      phoneCountryCode = phone.countryISOCode;
                      phoneWithoutCountry = phone.number;
                    },
                    onCountryChanged: (country) {
                      selectedCountry.value = country.name;
                    },
                    validator: (phone) {
                      if (phone == null || phone.number.isEmpty || phone.number.length < 10) {
                        return 'Enter valid mobile number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildField(nameCtrl, 'User Name *', Icons.person,
                      validator: (v) => v!.trim().isEmpty ? 'Name is required' : null),
                  const SizedBox(height: 16),

                  // User Type Dropdown
                  ValueListenableBuilder<String?>(
                    valueListenable: selectedUserType,
                    builder: (_, value, __) {
                      return DropdownButtonFormField<String>(
                        value: value,
                        decoration: _inputDecoration('User Type *', Icons.person_outline),
                        validator: (_) => value == null ? 'Please select user type' : null,
                        items: const [
                          DropdownMenuItem(value: 'Customer', child: Text('Customer')),
                          DropdownMenuItem(value: 'Dealer', child: Text('Dealer')),
                          DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                        ],
                        onChanged: (v) => selectedUserType.value = v,
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Address',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                  ),
                  const SizedBox(height: 16),

                  _buildField(address1Ctrl, 'Address Line 1', Icons.home),
                  const SizedBox(height: 16),
                  _buildField(address2Ctrl, 'Address Line 2 (Optional)', Icons.home),
                  const SizedBox(height: 16),
                  _buildField(townCtrl, 'Town', Icons.location_on),
                  const SizedBox(height: 16),
                  _buildField(villageCtrl, 'Village', Icons.location_on),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: ValueListenableBuilder<String?>(
                          valueListenable: selectedCountry,
                          builder: (_, value, __) {
                            return DropdownButtonFormField<String>(
                              value: value,
                              decoration: _inputDecoration('Country', Icons.public),
                              items: const [
                                DropdownMenuItem(value: 'India', child: Text('India')),
                                DropdownMenuItem(value: 'USA', child: Text('USA')),
                                DropdownMenuItem(value: 'UK', child: Text('UK')),
                              ],
                              onChanged: (v) => selectedCountry.value = v,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ValueListenableBuilder<String?>(
                          valueListenable: selectedState,
                          builder: (_, value, __) {
                            return DropdownButtonFormField<String>(
                              value: value,
                              decoration: _inputDecoration('State', Icons.map),
                              items: const [
                                DropdownMenuItem(value: 'State 1', child: Text('State 1')),
                                DropdownMenuItem(value: 'State 2', child: Text('State 2')),
                                DropdownMenuItem(value: 'State 3', child: Text('State 3')),
                              ],
                              onChanged: (v) => selectedState.value = v,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildField(cityCtrl, 'City', Icons.location_city),
                  const SizedBox(height: 16),
                  _buildField(postalCodeCtrl, 'Postal Code', Icons.mail),
                  const SizedBox(height: 16),
                  _buildField(altPhoneCtrl, 'Alternate Phone (Optional)', Icons.phone),
                  const SizedBox(height: 16),

                  _buildField(emailCtrl, 'Email (Optional)', Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v!.isNotEmpty && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                          return 'Enter valid email';
                        }
                        return null;
                      }),
                  const SizedBox(height: 16),

                  if (!isEdit)
                    TextFormField(
                      controller: passwordCtrl,
                      obscureText: true,
                      decoration: _inputDecoration('Password *', Icons.lock),
                      validator: (_) => passwordCtrl.text.isEmpty ? 'Password required' : null,
                    ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(dialogContext).primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        isEdit ? 'Update Profile' : 'Sign Up',
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper: Detect initial country from mobile
  String _detectInitialCountry(String? mobile) {
    if (mobile == null || mobile.isEmpty) return 'IN';
    if (mobile.startsWith('+91')) return 'IN';
    if (mobile.startsWith('+1')) return 'US';
    if (mobile.startsWith('+44')) return 'GB';
    return 'IN';
  }

  // Helper: Extract phone number without country code
  String _extractPhoneNumber(String? mobile) {
    if (mobile == null || mobile.isEmpty) return '';
    return mobile.replaceAll(RegExp(r'^\+\d{1,3}'), '').trim();
  }

  Widget _buildField(
      TextEditingController controller,
      String label,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
        String? Function(String?)? validator,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _inputDecoration(label, icon),
      validator: validator ??
              (v) {
            if (label.contains('*') && (v == null || v.trim().isEmpty)) {
              return 'This field is required';
            }
            return null;
          },
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.white70),
      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2)),
      errorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
      focusedErrorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent, width: 2)),
      labelStyle: const TextStyle(color: Colors.white70),
      errorStyle: const TextStyle(color: Colors.redAccent),
    );
  }
}