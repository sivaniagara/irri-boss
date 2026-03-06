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
    return _UserProfileFormBody(isEdit: isEdit, initialData: initialData);
  }
}

class _UserProfileFormBody extends StatefulWidget {
  final bool isEdit;
  final UserEntity? initialData;

  const _UserProfileFormBody({required this.isEdit, this.initialData});

  @override
  State<_UserProfileFormBody> createState() => _UserProfileFormBodyState();
}

class _UserProfileFormBodyState extends State<_UserProfileFormBody> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController nameCtrl;
  late TextEditingController address1Ctrl;
  late TextEditingController address2Ctrl;
  late TextEditingController townCtrl;
  late TextEditingController villageCtrl;
  late TextEditingController cityCtrl;
  late TextEditingController postalCodeCtrl;
  late TextEditingController altPhoneCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController passwordCtrl;

  String? phoneNumber;
  String? phoneCountryCode;
  String? phoneWithoutCountry;

  late ValueNotifier<String?> selectedUserType;
  late ValueNotifier<String?> selectedCountry;
  late ValueNotifier<String?> selectedState;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.initialData?.name ?? '');
    address1Ctrl = TextEditingController(text: widget.initialData?.addressOne ?? '');
    address2Ctrl = TextEditingController(text: widget.initialData?.addressTwo ?? '');
    townCtrl = TextEditingController(text: widget.initialData?.town ?? '');
    villageCtrl = TextEditingController(text: widget.initialData?.village ?? '');
    cityCtrl = TextEditingController(text: widget.initialData?.city ?? '');
    postalCodeCtrl = TextEditingController(text: widget.initialData?.postalCode ?? '');
    altPhoneCtrl = TextEditingController(
      text: widget.initialData?.altPhoneNum.isNotEmpty == true
          ? widget.initialData!.altPhoneNum.first
          : '',
    );
    emailCtrl = TextEditingController(text: widget.initialData?.email ?? '');
    passwordCtrl = TextEditingController();

    phoneNumber = widget.initialData?.mobile;
    phoneWithoutCountry = _extractPhoneNumber(widget.initialData?.mobile);

    selectedUserType = ValueNotifier<String?>(
      ['Customer', 'Dealer', 'Admin'].contains(getUserTypeLabel(widget.initialData?.userType))
          ? getUserTypeLabel(widget.initialData?.userType)
          : null,
    );

    selectedCountry = ValueNotifier<String?>(
      ['India', 'USA', 'UK'].contains(widget.initialData?.country) ? widget.initialData!.country : 'India',
    );

    selectedState = ValueNotifier<String?>(
      ['State 1', 'State 2', 'State 3'].contains(widget.initialData?.state) ? widget.initialData!.state : null,
    );
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    address1Ctrl.dispose();
    address2Ctrl.dispose();
    townCtrl.dispose();
    villageCtrl.dispose();
    cityCtrl.dispose();
    postalCodeCtrl.dispose();
    altPhoneCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  String getUserTypeLabel(int? type) {
    const map = {1: 'Customer', 2: 'Dealer', 3: 'Admin'};
    return map[type] ?? '';
  }

  int? mapUserTypeToInt(String label) {
    const map = {'Customer': 1, 'Dealer': 2, 'Admin': 3};
    return map[label];
  }

  void submit() {
    if (!formKey.currentState!.validate()) return;

    if (phoneNumber == null || phoneNumber!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid mobile number')),
      );
      return;
    }

    if (!widget.isEdit && passwordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password is required for signup')),
      );
      return;
    }

    if (selectedUserType.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select User Type')),
      );
      return;
    }

    final userTypeInt = mapUserTypeToInt(selectedUserType.value!);
    final mobileToSend = phoneWithoutCountry ?? phoneNumber!.replaceAll(RegExp(r'\D'), '');

    if (widget.isEdit) {
      context.read<AuthBloc>().add(UpdateProfileEvent(
        id: widget.initialData!.id,
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
      context.read<AuthBloc>().add(SignUpEvent(
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

  String _detectInitialCountry(String? mobile) {
    if (mobile == null || mobile.isEmpty) return 'IN';
    if (mobile.startsWith('+91')) return 'IN';
    if (mobile.startsWith('+1')) return 'US';
    if (mobile.startsWith('+44')) return 'GB';
    return 'IN';
  }

  String _extractPhoneNumber(String? mobile) {
    if (mobile == null || mobile.isEmpty) return '';
    // If it starts with a '+' and country code, we want just the number.
    // Assuming standard 10-digit numbers for now as a fallback.
    if (mobile.contains('+')) {
       final digits = mobile.replaceAll(RegExp(r'\D'), '');
       if (digits.length > 10) {
         return digits.substring(digits.length - 10);
       }
       return digits;
    }
    return mobile.replaceAll(RegExp(r'\D'), '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Profile' : 'Sign Up'),
        leading: widget.isEdit
            ? IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        )
            : null,
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Personal Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                IntlPhoneField(
                  initialCountryCode: _detectInitialCountry(widget.initialData?.mobile),
                  initialValue: _extractPhoneNumber(widget.initialData?.mobile),
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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

                if (!widget.isEdit)
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
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      widget.isEdit ? 'Update Profile' : 'Sign Up',
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
    );
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
      prefixIcon: Icon(icon),
      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black26)),
      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87, width: 2)),
      errorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
      focusedErrorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent, width: 2)),
      errorStyle: const TextStyle(color: Colors.redAccent),
    );
  }
}
