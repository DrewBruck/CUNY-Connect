import 'package:cuny_connect/components/app_textfield.dart';
import 'package:cuny_connect/components/my_button.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  //necessary email and password controller variables
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  //login onTap function
  final void Function()? onTap;

  RegisterPage({super.key, required this.onTap});

  //register method
  void register() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //logo here, added icon for filler
          const Icon(Icons.switch_account_rounded, size: 150),

          const SizedBox(height: 30), //spacer between picture and text

          const Center(
            child: Text(
              'Just a click away from something incredible!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
              ),
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

          const SizedBox(height: 10), //spacer between TextFields

          //confirm pass textfield
          AppTextField(
            hintText: "Confirm Password",
            obscureText: true,
            controller: _confirmPassController,
          ),
          const SizedBox(height: 30), //spacer between TextFields and Buttons

          //sign in button
          MyButton(
            buttonName: "Register",
            onTap: register,
          ),

          const SizedBox(height: 30), //spacer between TextFields and Buttons

          //register
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Already enrolled?  ",
                  style: TextStyle(color: Colors.grey[600])),
              GestureDetector(
                onTap: onTap,
                child: const Text("Login now!",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          )

          //forgot password
        ],
      ),
    ));
  }
}
