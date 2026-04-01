import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:orka_sports/presentation/widgets/custom_textfield.dart';
import 'package:phone_numbers_parser/metadata.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

class PhoneNumberWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onPhoneCodeChanged;
  final String? Function(String?)? validator;
  final String initialPhoneCode;

  const PhoneNumberWidget({
    super.key,
    required this.controller,
    required this.onPhoneCodeChanged,
    this.validator,
    this.initialPhoneCode = 'IN',
  });

  @override
  State<PhoneNumberWidget> createState() => _PhoneNumberWidgetState();
}

class _PhoneNumberWidgetState extends State<PhoneNumberWidget> {
  late Country _selectedCountry; // Default country India
  String? _phoneErrorMessage;

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final isoCode = IsoCode.values.firstWhere(
      (e) => e.name.toUpperCase() == _selectedCountry.countryCode.toUpperCase(),
      orElse: () => IsoCode.IN, // fallback to India if not found
    );
    final phoneNumber = PhoneNumber.parse(
      value,
      destinationCountry: isoCode,
    );
    if (!phoneNumber.isValid()) {
      return 'Invalid phone number for ${_selectedCountry.name}';
    }
    return null;
  }

  @override
  void initState() {
    _selectedCountry =
        Country.parse(countryCodeToIsoCode[widget.initialPhoneCode.replaceAll('+', '')]?.first.name ?? 'IN');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    log(widget.initialPhoneCode);
    return Row(
      children: [
        // Country Flag and Code Picker
        GestureDetector(
          onTap: () {
            showCountryPicker(
              context: context,
              showPhoneCode: true,
              onSelect: (Country country) {
                setState(() {
                  _selectedCountry = country;
                  _phoneErrorMessage = null;
                });
                widget.onPhoneCodeChanged('+${country.phoneCode}');
              },
            );
          },
          child: Row(
            children: [
              Text(
                _selectedCountry.flagEmoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              Text(
                '+${_selectedCountry.phoneCode}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),

        // Phone Number Input Field
        Expanded(
          child: CustomTextfield(
            controller: widget.controller,
            keyboardType: TextInputType.phone,
            autofocus: false,
            cursorColor: Colors.black,
            validator: (value) {
              return _validatePhoneNumber(value);
            },
            hintText: 'Phone number',
            labelText: 'Phone number',
            isPassword: false,
            onChanged: (value) {
              setState(() {
                _phoneErrorMessage = _validatePhoneNumber(value);
              });
            },
          ),
        ),
      ],
    );
  }
}
