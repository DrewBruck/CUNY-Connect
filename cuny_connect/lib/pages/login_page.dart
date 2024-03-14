import 'package:cuny_connect/components/my_button.dart';
import 'package:flutter/material.dart';
import 'package:cuny_connect/components/app_textfield.dart';

class LoginPage extends StatelessWidget {
  //necessary email and password controller variables
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  LoginPage({super.key});

  //login

  void login() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //logo here, added icon for filler
          const Icon(Icons.school_outlined, size: 150),

          const SizedBox(height: 50), //spacer between picture and text

          const Text(
            'School Group Chats Made Easy',
            style: TextStyle(
              fontSize: 20,
            ),
          ),

          const SizedBox(height: 50), //spacer between text and email field

          //email textfield
          AppTextField(
            hintText: "Email",
            obscureText: false,
            controller: _emailController,
          ),

          const SizedBox(height: 10), //spacer between TextFields

          //pass textfield
          AppTextField(
            hintText: "Password",
            obscureText: true,
            controller: _passController,
          ),

          const SizedBox(height: 30), //spacer between TextFields and Buttons

          //sign in button
          MyButton(
            buttonName: "Login",
            onTap: login,
          ),

          const SizedBox(height: 30), //spacer between TextFields and Buttons

          //register
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Not registered?  ",
                  style: TextStyle(color: Colors.grey[600])),
              Text("Sign up now!",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          )

          //forgot password
        ],
      ),
    ));
  }
}
