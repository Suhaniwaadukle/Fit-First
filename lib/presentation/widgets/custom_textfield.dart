import 'package:flutter/material.dart';

class CustomTextfield extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final TextInputType? keyboardType;
  final bool isPassword;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final InputDecoration? decoration;
  final bool? readOnly;
  final String? prefixText;
  final Widget? prefixIcon;
  final int? maxLines;
  final String? initialValue;
  final bool? obscureText;
  final Color? labelStyle;
  final bool autofocus;          
  final Color? cursorColor;
  final int? maxLength;
  final String? suffixText;  

  const CustomTextfield({
    super.key,
    required this.controller,
    required this.hintText,
    required this.labelText,
    this.keyboardType,
    required this.isPassword,
    this.prefixText,
    this.validator,
    this.onChanged,
    this.decoration,
    this.readOnly,
    this.prefixIcon,
    this.obscureText,
    this.maxLines,
    this.initialValue,
    this.labelStyle,
    this.autofocus = false,
    this.cursorColor,
    this.maxLength,
    this.suffixText, 
  });

  @override
  State<CustomTextfield> createState() => _CustomTextfieldState();
}

class _CustomTextfieldState extends State<CustomTextfield> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _isObscured : (widget.obscureText ?? false),
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      onChanged: widget.onChanged,
      initialValue: widget.initialValue,
      autofocus: widget.autofocus,
      cursorColor: widget.cursorColor ?? Colors.black,
      readOnly: widget.readOnly ?? false,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: widget.decoration ??
          InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixText: widget.prefixText,
            prefixIcon: widget.prefixIcon,
            prefixIconColor: WidgetStateColor.resolveWith((states) {
              if (states.contains(WidgetState.focused)) {
                return Colors.black;
              }
              return Colors.white;
            }),
            labelText: widget.labelText,
            hintText: widget.hintText,
            labelStyle: WidgetStateTextStyle.resolveWith((states) {
              return const TextStyle(color: Colors.black);
            }),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 2.0),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 1.5),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.redAccent, width: 2.0),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            suffixText: widget.suffixText, 
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _isObscured ? Icons.visibility_off : Icons.visibility,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    },
                  )
                : null,
          ),
    );
  }
}
