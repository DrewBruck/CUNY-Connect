import 'package:cuny_connect/auth/auth_service.dart';
import 'package:cuny_connect/components/my_button.dart';
import 'package:cuny_connect/components/app_textfield.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final void Function()? onTap;

  LoginPage({super.key, this.onTap});

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

  void forgotPassword(BuildContext context) async {
    final authService = AuthService();
    try {
      await authService.resetPassword(_emailController.text);
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text("Password Reset Email Sent"),
          content:
              Text("Please check your email to reset your password."),
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school_outlined, size: 150),
            const SizedBox(height: 50),
            const Text(
              'School Group Chats Made Easy',
              style: TextStyle(
                fontSize: 20,
              ),
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
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => forgotPassword(context),
              child: const Text(
                'Forgot Password?',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Not registered?  ",
                    style: TextStyle(color: Color.fromARGB(255, 75, 75, 75))),
                GestureDetector(
                  onTap: onTap,
                  child: const Text("Sign up now!",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
