import 'dart:math';
import 'package:flutter/foundation.dart'; // for kDebugMode
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cuny_connect/auth/auth_gate.dart';

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

  static const Map<String, String> courseIDs = {
    'CSCI 275': '5ccA0Bf80hYEZkH2Q8lP',
    'ENGL 100': 'RkHMELrZgeTIK14Wp8hw',
    'GEO 101': 'b9Xs2YhMWocxGOfd3099',
    'ART 101': 'gwNh8DhhPJi5gXKORvjg',
    'MATH 100': 'jufv4qAFHl1jedyh5WOg',
  };

  final List<Map<String, List<String>>> schedules = [
    {
      'Schedule-Abby': ['CSCI 275', 'ART 101', 'GEO 101']
    },
    {
      'Schedule-Jessica': ['ENGL 100', 'CSCI 335', 'ART 101']
    },
    {
      'Schedule-Joe': ['ENGL 100', 'CSCI 275']
    },
    {
      'Schedule-John': ['CSCI 499', 'ART 101', 'GEO 101']
    },
    {
      'Schedule-Leo': ['ENGL 100', 'CSCI 275']
    },
    {
      'Schedule-Test': ['CSCI 275', 'ART 101']
    },
    {
      'Schedule-Tester': ['CSCI 335', 'ENGL 100']
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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passController.text,
      );

      final Random random = Random();
      final int index = random.nextInt(schedules.length);
      final Map<String, List<String>> selectedSchedule = schedules[index];
      final String chosenSchedule = selectedSchedule.keys.first;
      final List<String> courses = selectedSchedule.values.first;

      List<String> conversationIDs = [];
      for (String course in courses) {
        if (courseIDs.containsKey(course)) {
          conversationIDs.add(courseIDs[course]!);
        }
      }

      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      if (kDebugMode) {
        print("Storing user information...");
      }
      await firestore.collection('Info').doc(userCredential.user!.uid).set({
        'bio': '',
        'conversationIDs': conversationIDs,
        'email': _emailController.text,
        'major': _majorController.text,
        'name': _nameController.text,
        'schedule': courses,
        'chosenSchedule': chosenSchedule,
      });

      if (kDebugMode) {
        print("User information stored successfully.");
      }

      // Ensure user is authenticated before updating conversations
      if (FirebaseAuth.instance.currentUser != null) {
        if (kDebugMode) {
          print("Updating conversations...");
        }

        // TODO: THE ISSUE WITH THIS CODE IS THAT IT IS A SECURITY RISK.
        // BECAUSE WE HAVE ACCESS TO CREATE A CONVERSATION IT MEANS THAT
        // ANYONE CAN FAKE AND GET IN.
        for (String conversationID in conversationIDs) {
          DocumentReference conversationRef =
              firestore.collection('Conversations').doc(conversationID);

          await conversationRef.update({
            'participants': FieldValue.arrayUnion([userCredential.user!.uid]),
          });
        }

        if (kDebugMode) {
          print("Conversations updated successfully.");
        }
      } else {
        if (kDebugMode) {
          print("User is not authenticated.");
        }
      }

      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => const AuthGate()));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Error creating user: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error creating user: ${e.message}")),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Unexpected error: $e")),
        );
        setState(() {
          _isLoading = false;
        });
      }
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
              //const Icon(Icons.switch_account_rounded, size: 150),
              Image.asset(
                'assets/images/Logo-CC.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 30),
              const Text(
                'Register now!',
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
                  ? const CircularProgressIndicator()
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
