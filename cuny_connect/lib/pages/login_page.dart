import 'package:cuny_connect/auth/auth_service.dart';
import 'package:cuny_connect/components/my_button.dart';
import 'package:flutter/material.dart';
import 'package:cuny_connect/components/app_textfield.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  final void Function()? onTap;

  LoginPage({super.key, required this.onTap});

  void login(BuildContext context) async {
    final authService = AuthService();
    try {
      await authService.signInWithEmailPassword(
        _emailController.text,
        _passController.text,
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text("Invalid Email or Password"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.school_outlined, size: 150),
              const SizedBox(height: 20),
              const Text(
                'School Group Chats Made Easy',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 50),
              AppTextField(
                hintText: "Email",
                obscureText: false,
                controller: _emailController,
              ),
              const SizedBox(height: 10),
              AppTextField(
                hintText: "Password",
                obscureText: true,
                controller: _passController,
              ),
              const SizedBox(height: 30),
              MyButton(
                buttonName: "Login",
                onTap: () => login(context),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Not registered?  ",
                      style: TextStyle(color: Colors.grey[600])),
                  GestureDetector(
                    onTap: onTap,
                    child: const Text("Sign up now!",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
