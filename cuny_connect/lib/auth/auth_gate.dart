import 'package:cuny_connect/auth/login_or_register.dart';
import 'package:cuny_connect/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/*This page should act like a gate for logging in.  If
someone doesn't log out, they shouldn't have to sign
back in every time they close the app. This is the first
page that will be pulled when the app opens; based on
firebase instances, this will direct the user either to
the main page or the login page.*/

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        //is user logged in?
        if (snapshot.hasData) {
          return const HomePage();
        }

        //is user NOT logged in?
        else {
          return const LoginOrRegister();
        }
      },
    ));
  }
}
