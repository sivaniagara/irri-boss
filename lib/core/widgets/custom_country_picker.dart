import 'package:flutter/material.dart';
import 'package:intl_phone_field/countries.dart';
import 'dart:ui';

import 'action_button.dart';

class CustomCountryPicker {
  static Future<Country?> show({
    required BuildContext context,
    required Function(Country) onCountrySelected,
    String initialCountryCode = 'IN',
  }) {
    final TextEditingController searchController = TextEditingController();
    List<Country> filteredCountries = List.from(countries);

    void filterCountries(String query) {
      filteredCountries = countries
          .where((country) =>
      country.name.toLowerCase().contains(query.toLowerCase()) ||
          country.code.toLowerCase().contains(query.toLowerCase()) ||
          country.dialCode.contains(query))
          .toList();
    }

    final initialCountry = countries.firstWhere(
          (c) => c.code == initialCountryCode,
      orElse: () => countries.firstWhere((c) => c.code == 'IN'),
    );

    return showDialog<Country>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          void localFilter(String query) {
            filterCountries(query);
            setState(() {});
          }

          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(32.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 20.0,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Select Country',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withOpacity(0.4)),
                              ),
                              child: TextField(
                                controller: searchController,
                                onChanged: localFilter,
                                style: const TextStyle(color: Colors.black87),
                                decoration: InputDecoration(
                                  hintText: 'Search country...',
                                  prefixIcon: const Icon(Icons.search, color: Colors.black54),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListView.separated(
                                itemCount: filteredCountries.length,
                                separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.white24),
                                itemBuilder: (context, index) {
                                  final country = filteredCountries[index];
                                  final isSelected = country.code == initialCountry.code;
                                  return ListTile(
                                    leading: Text(
                                      country.flag,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                    title: Text(
                                      country.name,
                                      style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,),
                                    ),
                                    trailing: RichText(
                                      text: TextSpan(
                                        style: const TextStyle(fontSize: 14),
                                        children: [
                                          TextSpan(text: '${country.dialCode} '),
                                          TextSpan(text: country.code),
                                        ],
                                      ),
                                    ),
                                    onTap: () {
                                      onCountrySelected(country);
                                      Navigator.pop(dialogContext);
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: ActionButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Cancel')
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}