import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _majorController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  bool _isLoading = false;

  // Define schedules
  final List<Map<String, List<String>>> schedules = [
    {
      'Schedule-Abby': ['CSCI 275', 'ART 101', 'GEO 101']
    },
    {
      'Schedule-Jessica': ['Eng 499', 'csci 335', 'art 101']
    },
    {
      'Schedule-Joe': ['Eng 499', 'CSCI 275']
    },
    {
      'Schedule-John': ['CSCI 499', 'Art 101', 'geo 101']
    },
    {
      'Schedule-Leo': ['Eng 499', 'CSCI 275']
    },
    {
      'Schedule-Test': ['CSCI 275', 'ART 101']
    },
    {
      'Schedule-Tester': ['CSCI 335', 'ENG 101']
    },
  ];

  void register(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    if (_passController.text != _confirmPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Create a new user with the provided email and password
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passController.text,
      );

      // Randomly select a schedule
      final Random random = Random();
      final int index = random.nextInt(schedules.length);
      final Map<String, List<String>> selectedSchedule = schedules[index];
      final String chosenSchedule = selectedSchedule.keys.first;
      final List<String> courses = selectedSchedule.values.first;

      // Store additional user information in Firestore
      await FirebaseFirestore.instance
          .collection('Info')
          .doc(userCredential.user!.uid)
          .set({
        'bio': '',
        'conversationIDs': ['PjEptDwra89ZbCoCxlSX'],
        'email': _emailController.text,
        'major': _majorController.text,
        'name': _nameController.text,
        'schedule': courses, // Set schedule to courses
        'chosenSchedule': chosenSchedule, // Set chosen schedule
      });

      // Navigate to the profile page
      Navigator.of(context).pushReplacementNamed('/profile');

      setState(() {
        _isLoading = false;
      });
    } on FirebaseAuthException catch (e) {
      print('Error creating user: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error creating user: ${e.message}")),
      );

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.switch_account_rounded, size: 150),
              const SizedBox(height: 30),
              const Text(
                'Register for Cuny Connect',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(hintText: "Name"),
                controller: _nameController,
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(hintText: "Major"),
                controller: _majorController,
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(hintText: "Email"),
                controller: _emailController,
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(hintText: "Password"),
                obscureText: true,
                controller: _passController,
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(hintText: "Confirm Password"),
                obscureText: true,
                controller: _confirmPassController,
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator() // Show loading indicator
                  : ElevatedButton(
                      onPressed: () => register(context),
                      child: const Text("Register"),
                    ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already enrolled?  ",
                      style: TextStyle(color: Colors.grey[600])),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text("Login now!",
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
