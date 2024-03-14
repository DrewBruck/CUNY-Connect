import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final void Function()? onTap;
  final String buttonName;

  const MyButton({super.key, required this.buttonName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 63, 4, 73),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.all(25),
        margin: EdgeInsets.symmetric(horizontal: 40),
        child: Center(
            child: Text(buttonName, style: TextStyle(color: Colors.white))),
      ),
    );
  }
}
