import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class SchedulePage extends StatelessWidget {
  const SchedulePage({Key? key}) : super(key: key);

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
        title: const Text('Schedule Page'),
      ),
      body: FutureBuilder<String?>(
        future: fetchScheduleImage('Schedule-Abby'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching image'));
          } else if (snapshot.data == null) {
            return const Center(child: Text('No image found'));
          } else {
            return Image.network(snapshot.data!);
          }
        },
      ),
    );
  }
}
