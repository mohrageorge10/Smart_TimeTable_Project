import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon; 
  final Widget? suffixIcon; 
  final TextInputType keyboardType; 
  final void Function(String)? onChanged; 
  final String? Function(String?)? validator; 
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text, 
    this.onChanged,
    this.validator, this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      validator: validator,
      keyboardType: keyboardType,
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null 
            ? Icon(prefixIcon, color: Theme.of(context).primaryColor) 
            : null,
        suffixIcon: suffixIcon,
      ),
    );
  }
}