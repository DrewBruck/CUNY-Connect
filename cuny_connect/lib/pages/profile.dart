import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, //change auto-back button color
        ),
        title: const Text(
          "Profile Page",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: const Center(
        child: Text('Information and picture here'),

        //need to add picture pull from firebase

        //need to add username pull from firebase

        //need to add academic year pull from firebase

        //need to add bio pull from firebase
      ),
    );
  }
}
