import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cuny_connect/models/CUNYUser.dart';
import 'package:cuny_connect/utils/conversation.dart';

class FirebaseService {

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseService _instance = FirebaseService._internal();
  CUNYUser? _currentUser;

  // Private constructor
  FirebaseService._internal();

  // Factory constructor to return the same instance
  factory FirebaseService() {
    return _instance;
  }

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

  Future<CUNYUser?> getCurrentUser({bool forceRefresh = false}) async {
    if (_currentUser == null || forceRefresh) {
      _currentUser = await getUserProfile();
    }
    return _currentUser;
  }

    Future<List<Conversation>> getUserConversations() async {
      List<Conversation> conversations = [];
      try {
        String userId = FirebaseAuth.instance.currentUser!.uid;
        DocumentSnapshot userSnapshot = await _db.collection('Info').doc(userId).get();
        Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>? ?? {};
        List<dynamic> conversationIds = userData['conversationIds'] ?? [];

        for (String conversationId in conversationIds) {
          DocumentSnapshot conversationSnapshot = await _db.collection('Conversations').doc(conversationId).get();
          if (conversationSnapshot.exists && conversationSnapshot.data() != null) {
            Conversation conversation = await Conversation.fromFirestore(_db, conversationSnapshot.data() as Map<String, dynamic>, conversationId);
            conversations.add(conversation);
          }
        }
      } catch (e) {
        print("Error fetching conversations: $e");
      }
      return conversations;
    }

    Future<String> getUserName(String uid) async{
      try{
        DocumentSnapshot userDoc = await _db.collection('Info').doc(uid).get();
        if(userDoc.exists){
          final userData = userDoc.data() as Map<String, dynamic>?;
          return userData?['name'] ?? 'Unknown User';
        }else{
          return 'User Not Found';
        }
      }catch(e){
        print("Error fetching user name: $e");
        return 'Error';
      }
    }

    Future<List<String>> fetchParticipants(String conversationId) async{
      List<String> participants = [];
      try{
        DocumentSnapshot conversationSnapshot = await _db.collection('Conversations').doc(conversationId).get();
        if(conversationSnapshot.exists && conversationSnapshot.data() != null){
          final data = conversationSnapshot.data() as Map<String,dynamic>;
          participants = List.from(data['participants'] ?? []);
        }
      }catch(e){
        print("Error");
      }
      return participants;
    }
}