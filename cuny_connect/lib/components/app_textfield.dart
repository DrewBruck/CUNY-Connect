import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  //necessary variables
  final bool obscureText;
  final String hintText;
  final TextEditingController controller;

  const AppTextField({
    super.key,
    required this.hintText,
    required this.obscureText,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50.0),
      child: TextField(
        obscureText: obscureText,
        controller: controller,
        decoration: InputDecoration(
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.deepPurple),
            ),
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[400])),
      ),
    );
  }
}
