import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cuny_connect/models/CUNYUser.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<CUNYUser?> getUserProfile() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot snapshot = await _db.collection('Info').doc(userId).get();
      if (snapshot.exists && snapshot.data() != null) {
        print(snapshot.data());
        return CUNYUser.fromMap(snapshot.data() as Map<String, dynamic>, userId);
      }
    } catch (e) {
      print("Error fetching user profile: $e");
    }
    return null;
  }

  // Updates the bio for the user with the given UID
  Future<void> updateUserBio(String uid, String bio) async {
    try {
      await _db.collection('Info').doc(uid).update({'bio': bio});
      print("Bio updated successfully for UID: $uid");
    } catch (e) {
      print("Error updating user bio: $e");
      throw e; // Rethrow the error if you need to handle it further up the call stack.
    }
  }
}

