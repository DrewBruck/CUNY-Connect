import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cuny_connect/models/CUNYUser.dart';
import 'package:cuny_connect/utils/conversation.dart';

class FirebaseService {

  // This variable since it has final can only be set once and it's
  // initialized at the time of declaration.
  // _db can be reassigned after its inital assignment.

  // NOTE: instance returns a singleton. This means we only have on active
  // connection to the Firestore database throughout the application.
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // The _instance is a private constuctor that prevents other parts of
  // the app from creating new instances of firebase.
  static final FirebaseService _instance = FirebaseService._internal();

  // Variables to keep track of the current user state.
  // The ? denotes that _currentUser can hold a null value.
  String get userId => FirebaseAuth.instance.currentUser!.uid;
  CUNYUser? _currentUser;

  // Private constructor
  FirebaseService._internal();

  // Factory constructor to return the same instance
  factory FirebaseService() {
    return _instance;
  }

    // Static method to fetch isAdmin and adminTitle from Firestore
   Future<Map<String, dynamic>> fetchAdminDetails(String conversationId) async {
    try {
      var docSnapshot = await _db.collection('Conversations').doc(conversationId).get();
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      return {
        'isAdmin': data['isAdmin'] ?? false, // Default to false if not set
        'adminTitle': data['adminTitle'] ?? '' // Default to empty string if not set
      };
    } catch (e) {
      print("Error fetching conversation details: $e");
      return {'isAdmin': false, 'adminTitle': ''}; // Return default values on error
    }
  }
  
  Future<CUNYUser?> getUserProfile(String userId) async {
    try {
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

  Future<String> formatParticipantNames(List<String> participantIds) async {
    if (participantIds.isEmpty) return "";
    List<String> names = [];
    for (String uid in participantIds) {
      if(uid != userId){
        String name = await _instance.getUserName(uid);
        names.add(name);
      }
    }

    if (names.length > 2) { return '${names[0]}, ${names[1]}...'; }
    else { return names.join(', '); }

  }

  Stream<List<Conversation>> conversationsStream() {
    return _db.collection('Conversations')
      .where('participants', arrayContains: userId)  // Ensure the user is a participant
      .snapshots()
      .asyncMap((snapshot) async {
        List<Future<Conversation>> futures = snapshot.docs.map((doc) async {
          return Conversation.fromFirestore(_db, doc.data(), doc.id);
        }).toList();
        
        // Wait for all Conversation objects to be created
        List<Conversation> conversations = await Future.wait(futures);
        conversations.sort((a, b) {
          // Handle possible null lastMessageTime
          if (a.lastMessageTime == null && b.lastMessageTime == null) return 0;
          if (a.lastMessageTime == null) return 1;  // Assume nulls last
          if (b.lastMessageTime == null) return -1; // Assume nulls last
          return b.lastMessageTime!.compareTo(a.lastMessageTime!);
        });

        return conversations;
      });
  }

  // Updates the bio for the user with the given UID
  Future<void> updateUserBio(String uid, String bio) async {
    try {
      await _db.collection('Info').doc(uid).update({'bio': bio});
      print("Bio updated successfully for UID: $uid");
    } catch (e) {
      print("Error updating user bio: $e");
      rethrow; // Rethrow the error if you need to handle it further up the call stack.
    }
  }

  Future<CUNYUser?> getCurrentUser({bool forceRefresh = false}) async {
    if (_currentUser == null || forceRefresh) {
      _currentUser = await getUserProfile(userId);
    }
    return _currentUser;
  }

  // Returns a stream of conversations for the current user
  Stream<QuerySnapshot> getUserConversationsStream() {
    return _db.collection('Conversations')
              .where('participants', arrayContains: userId)
              .snapshots();
  }

    Future<List<Conversation>> getUserConversations() async {

      List<Conversation> conversations = [];
      try {
        DocumentSnapshot userSnapshot = await _db.collection('Info').doc(userId).get();
        Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>? ?? {};
        List<dynamic> conversationIds = userData['conversationIDs'] ?? [];

        print(conversationIds);
        for (String conversationId in conversationIds) {
          DocumentSnapshot conversationSnapshot = await _db.collection('Conversations').doc(conversationId).get();
          if (conversationSnapshot.exists && conversationSnapshot.data() != null) {
            Conversation conversation = await Conversation.fromFirestore(
                _db, conversationSnapshot.data() as Map<String, dynamic>, conversationId);
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
