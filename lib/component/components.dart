import 'package:flutter/material.dart';
import 'package:app/theme/app_theme.dart';

class Components extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;

  const Components({
    super.key,
    required this.hintText,
    required this.controller,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: context.scheme.onSurfaceVariant),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: context.scheme.outlineVariant, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: context.scheme.primary,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
