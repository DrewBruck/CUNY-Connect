import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class SchedulePage extends StatefulWidget {
  const SchedulePage({Key? key}) : super(key: key);

  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late Stream<DocumentSnapshot> _userDataStream;

  @override
  void initState() {
    super.initState();
    _initializeUserDataStream();
  }

  void _initializeUserDataStream() {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userId = currentUser?.uid;
    _userDataStream =
        FirebaseFirestore.instance.collection('Info').doc(userId).snapshots();
  }

  Future<String?> fetchScheduleImage(String scheduleName) async {
    try {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('$scheduleName.png');
      String downloadURL = await ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error fetching schedule image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule Page'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _userDataStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No data found'));
          } else {
            Map<String, dynamic>? userData =
                snapshot.data!.data() as Map<String, dynamic>?; // Explicit cast
            String chosenSchedule = userData?['chosenSchedule'];
            return FutureBuilder<String?>(
              future: fetchScheduleImage(chosenSchedule),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError || snapshot.data == null) {
                  return Center(child: Text('Error fetching image'));
                } else {
                  return Image.network(snapshot.data!);
                }
              },
            );
          }
        },
      ),
    );
  }
}
