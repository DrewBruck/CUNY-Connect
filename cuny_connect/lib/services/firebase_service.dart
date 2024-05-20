// import 'dart:async';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cuny_connect/models/CUNYUser.dart';
// import 'package:cuny_connect/utils/conversation.dart';
// import 'package:flutter/foundation.dart';

// // NOTE: The goal is to have this class for syncing data.
// // The goal is to use the firebase service as a singleton where we
// // have a central location to deal with firebase.
// class FirebaseService {

//     // This variable since it has final can only be set once and it's
//     // initialized at the time of declaration.
//     // _db can be reassigned after its inital assignment.

//     // NOTE: instance returns a singleton. This means we only have on active
//     // connection to the Firestore database throughout the application.
//     final FirebaseFirestore _db = FirebaseFirestore.instance;

//     // The _instance is a private constuctor that prevents other parts of
//     // the app from creating new instances of firebase.
//     static final FirebaseService _instance = FirebaseService._internal();

//     // Variables to keep track of the current user state.
//     // The ? denotes that _currentUser can hold a null value.
//     String get userId => FirebaseAuth.instance.currentUser!.uid;
//     CUNYUser? _currentUser;

//     // Private constructor
//     FirebaseService._internal();

//     // Factory constructor to return the same instance
//     factory FirebaseService() {
//         return _instance;
//     }

//     ///////////////////////////////////
//     /// CHAT_PAGE
//     /// STATUS: CHANGE   -- Should be dealt with in conversations Hive.
//     ///                  -- This is okay if we remove so long as we can
//     ///                  -- safely replace it.

//     // Static method to fetch isAdmin and adminTitle from Firestore
//     Future<Map<String, dynamic>> fetchAdminDetails(String conversationId) async {
//         try {
//             var docSnapshot = await _db.collection('Conversations').doc(conversationId).get();
//             Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
//             return {
//                 'isAdmin': data['isAdmin'] ?? false, // Default to false if not set
//                 'adminTitle': data['adminTitle'] ?? '' // Default to empty string if not set
//             };
//         } catch (e) {
//             print("Error fetching conversation details: $e");
//             return {'isAdmin': false, 'adminTitle': ''}; // Return default values on error
//         }
//     }

//     ///////////////////////////////////
//     /// CHAT_LOG_PAGE
//     /// STATUS: CHANGE          -- This does not need to be called if we have
//     ///                         -- hive installed and working.

//     Future<String> formatParticipantNames(List<String> participantIds) async {

//         if (participantIds.isEmpty) return "";
//         List<String> names = [];
//         for (String uid in participantIds) {
//             if(uid != userId){
//                 String name = await _instance.getUserName(uid);
//                 names.add(name);
//             }
//         }

//         if (names.length > 2) { return '${names[0]}, ${names[1]}...'; }
//         else { return names.join(', '); }

//     }

//     ///////////////////////////////////
//     /// CHAT_LOG_PAGE
//     /// STATUS: CHANGE          -- This does not need to be called if we have
//     ///                         -- hive installed and working.

//     StreamSubscription<QuerySnapshot<Map<String, dynamic>>> listenForConversationChanges(){
//         return _db.collection('conversations').where('participants', arrayContains: userId)
//             .snapshots()
//             .listen((snapshot){

//             for(var change in snapshot.docChanges){
//                 if (change.type == DocumentChangeType.modified){
//                   print("${change.doc.data()}");
//                 }
//             }
//         });
//     }

//     ///////////////////////////////////
//     /// CHAT_LOG_PAGE
//     /// STATUS: CHANGE          -- This does not need to be called if we have
//     ///                         -- hive installed and working.

//     Stream<List<Conversation>> conversationsStream() {

//         return _db.collection('Conversations')
//             .where('participants', arrayContains: userId)
//             .snapshots()
//             .asyncMap((snapshot) async {

//             List<Future<Conversation>> futures = snapshot.docs.map((doc) async {
//                 return Conversation.fromFirestore(_db, doc.data() as Map<String, dynamic>, doc.id);
//             }).toList();

//             // Wait for all Conversation objects to be created
//             List<Conversation> conversations = await Future.wait(futures);

//             conversations.sort((a, b) {
//                 // Handle possible null lastMessageTime
//                 if (a.lastMessageTime == null && b.lastMessageTime == null) return 0;
//                 if (a.lastMessageTime == null) return 1;  // Assume nulls last
//                 if (b.lastMessageTime == null) return -1; // Assume nulls last
//                 return b.lastMessageTime!.compareTo(a.lastMessageTime!);
//             });

//             return conversations;
//         });

//     }

//     ///////////////////////////////////
//     /// CHAT_PAGE
//     /// STATUS: CHANGE          -- This does not need to be called if we have
//     ///                         -- hive installed and working.

//     Future<List<String>> fetchParticipants(String conversationId) async{
//         List<String> participants = [];
//         try{
//             DocumentSnapshot conversationSnapshot = await _db.collection('Conversations').doc(conversationId).get();
//             if(conversationSnapshot.exists && conversationSnapshot.data() != null){
//                 final data = conversationSnapshot.data() as Map<String,dynamic>;
//                 participants = List.from(data['participants'] ?? []);
//             }
//         }catch(e){
//             print("Error");
//         }
//         return participants;
//     }

//     ///////////////////////////////////
//     /// PROFILE_PAGE, FIREBASE_SERVICE
//     /// STATUS: GOOD

//     Future<CUNYUser?> getUserProfile(String userId) async {
//         try {
//             DocumentSnapshot snapshot = await _db.collection('Info').doc(userId).get();
//             if (snapshot.exists && snapshot.data() != null) {
//                 print(snapshot.data());
//                 return CUNYUser.fromMap(snapshot.data() as Map<String, dynamic>, userId);
//             }
//         } catch (e) {
//             if(kDebugMode){
//                 print("Error fetching user profile: $e");
//             }
//         }
//         return null;
//     }

//     ///////////////////////////////////
//     /// PROFILE_PAGE, FIREBASE_SERVICE
//     /// STATUS: GOOD

//     // Updates the bio for the user with the given UID
//     Future<void> updateUserBio(String uid, String bio) async {
//         try {
//             await _db.collection('Info').doc(uid).update({'bio': bio});
//             print("Bio updated successfully for UID: $uid");
//         } catch (e) {
//             print("Error updating user bio: $e");
//             throw e;
//         }
//     }

//     ///////////////////////////////////
//     /// HOME_PAGE, FIREBASE_SERVICE
//     /// STATUS: GOOD

//     Future<CUNYUser?> getCurrentUser({bool forceRefresh = false}) async {
//         if (_currentUser == null || forceRefresh) {
//             _currentUser = await getUserProfile(userId);
//         }
//         return _currentUser;
//     }

//     ///////////////////////////////////
//     /// CHAT_PAGE, CONVERSATION_CREATOR, FIREBASE_SERVICE
//     /// STATUS: GOOD

//     Future<String> getUserName(String uid) async{
//         try{
//             DocumentSnapshot userDoc = await _db.collection('Info').doc(uid).get();
//             if(userDoc.exists){
//                 final userData = userDoc.data() as Map<String, dynamic>?;
//                 return userData?['name'] ?? 'Unknown User';
//             }else{
//                 return 'User Not Found';
//             }
//         }catch(e){
//             print("Error fetching user name: $e");
//             return 'Error';
//         }
//     }

//     ///////////////////////////////////
//     /// Conversation Creator
//     /// STATUS: GOOD

//     Future<DocumentReference> addConversation(Map<String, dynamic> conversationData) async {
//         return await _db.collection('Conversations').add(conversationData);
//     }

//     ///////////////////////////////////
//     // Conversation Creator
//     // STATUS: GOOD

//     Future<List<String>> fetchUserSuggestions(String query) async {
//         var snapshot = await _db.collection('Info')
//           .orderBy('name')
//           .startAt([query])
//           .endAt([query + '\uf8ff'])
//           .limit(5)
//           .get();

//         return snapshot.docs.map((doc) => '${doc.id}:${doc['name']}').toList();
//     }

//     // Fetch conversations for the current user
//     Future<List<Conversation>> fetchConversations() async {
//         try {
//             var conversationSnapshots = await _db
//               .collection('Conversations')
//               .where('participants', arrayContains: userId)
//               .get();

//             List<Conversation> conversations = [];
//             for (var doc in conversationSnapshots.docs) {
//                 var data = doc.data();
//                 var conversation = await Conversation.fromFirestore(_db, data, doc.id);
//                 conversations.add(conversation);
//             }
//             return conversations;
//         } catch (e) {
//             print('Error fetching conversations: $e');
//             return [];
//         }
//     }

//     ///////////////////////////////////
//     // Conversation Creator
//     // STATUS: GOOD
//     void updateUserProfile(String conversationId) async {
//         try {
//             DocumentReference userDoc = _db.collection('Info').doc(userId);
//             DocumentSnapshot userSnapshot = await userDoc.get();
//             if (userSnapshot.exists) {
//                 var data = userSnapshot.data() as Map<String, dynamic>;
//                 List<String> conversationIds = List<String>.from(data['conversationIDs'] ?? []);
//                 if (!conversationIds.contains(conversationId)) {
//                     conversationIds.add(conversationId);
//                     await userDoc.update({'conversationIDs': conversationIds});
//                     print('User profile updated with new conversation ID');
//                 }
//             }
//         } catch (e) {
//           print('Error updating user profile: $e');
//         }
//     }

//     ///////////////////////////////////
//     // Conversation Creator
//     // STATUS: GOOD
//     Future<bool> checkConversationInUserProfile(String conversationId) async {
//         try {
//             DocumentSnapshot userDoc = await _db.collection('Info').doc(userId).get();
//             if (userDoc.exists) {
//                 Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
//                 List<String> conversationIds = List<String>.from(data['conversationIDs'] ?? []);
//                 return conversationIds.contains(conversationId);
//             }
//         } catch (e) {
//             print('Error checking conversation in user profile: $e');
//         }
//         return false;
//     }

//     ///////////////////////////////////
//     // Conversation Creator
//     // STATUS: GOOD
//     Future<void> addConversationToUserProfile(String conversationId) async {
//         try {
//             DocumentReference userDoc = _db.collection('Info').doc(userId);
//             DocumentSnapshot userSnapshot = await userDoc.get();
//             if (userSnapshot.exists) {
//                 Map<String, dynamic> data = userSnapshot.data() as Map<String, dynamic>;
//                 List<String> conversationIds = List<String>.from(data['conversationIDs'] ?? []);
//                 if (!conversationIds.contains(conversationId)) {
//                     conversationIds.add(conversationId);
//                     await userDoc.update({'conversationIDs': conversationIds});
//                     print('User profile updated with new conversation ID');
//                 }
//             }
//         } catch (e) {
//             print('Error updating user profile: $e');
//         }
//     }

// }

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cuny_connect/models/CUNYUser.dart';
import 'package:cuny_connect/utils/conversation.dart';
import 'package:flutter/foundation.dart';

// NOTE: The goal is to have this class for syncing data.
// The goal is to use the firebase service as a singleton where we
// have a central location to deal with firebase.
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

  ///////////////////////////////////
  /// CHAT_PAGE
  /// STATUS: CHANGE   -- Should be dealt with in conversations Hive.
  ///                  -- This is okay if we remove so long as we can
  ///                  -- safely replace it.

  // Static method to fetch isAdmin and adminTitle from Firestore
  Future<Map<String, dynamic>> fetchAdminDetails(String conversationId) async {
    try {
      var docSnapshot =
          await _db.collection('Conversations').doc(conversationId).get();
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      return {
        'isAdmin': data['isAdmin'] ?? false, // Default to false if not set
        'adminTitle':
            data['adminTitle'] ?? '' // Default to empty string if not set
      };
    } catch (e) {
      print("Error fetching conversation details: $e");
      return {
        'isAdmin': false,
        'adminTitle': ''
      }; // Return default values on error
    }
  }

  ///////////////////////////////////
  /// CHAT_LOG_PAGE
  /// STATUS: CHANGE          -- This does not need to be called if we have
  ///                         -- hive installed and working.

  Future<String> formatParticipantNames(List<String> participantIds) async {
    if (participantIds.isEmpty) return "";
    List<String> names = [];
    for (String uid in participantIds) {
      if (uid != userId) {
        String name = await _instance.getUserName(uid);
        names.add(name);
      }
    }

    if (names.length > 2) {
      return '${names[0]}, ${names[1]}...';
    } else {
      return names.join(', ');
    }
  }

  ///////////////////////////////////
  /// CHAT_LOG_PAGE
  /// STATUS: CHANGE          -- This does not need to be called if we have
  ///                         -- hive installed and working.

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>
      listenForConversationChanges() {
    return _db
        .collection('conversations')
        .where('participants', arrayContains: userId)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.modified) {
          print("${change.doc.data()}");
        }
      }
    });
  }

  ///////////////////////////////////
  /// CHAT_LOG_PAGE
  /// STATUS: CHANGE          -- This does not need to be called if we have
  ///                         -- hive installed and working.

  Stream<List<Conversation>> conversationsStream() {
    return _db
        .collection('Conversations')
        .where('participants', arrayContains: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Future<Conversation>> futures = snapshot.docs.map((doc) async {
        return Conversation.fromFirestore(
            _db, doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      // Wait for all Conversation objects to be created
      List<Conversation> conversations = await Future.wait(futures);

      conversations.sort((a, b) {
        // Handle possible null lastMessageTime
        if (a.lastMessageTime == null && b.lastMessageTime == null) return 0;
        if (a.lastMessageTime == null) return 1; // Assume nulls last
        if (b.lastMessageTime == null) return -1; // Assume nulls last
        return b.lastMessageTime!.compareTo(a.lastMessageTime!);
      });

      return conversations;
    });
  }

  ///////////////////////////////////
  /// CHAT_PAGE
  /// STATUS: CHANGE          -- This does not need to be called if we have
  ///                         -- hive installed and working.

  Future<List<String>> fetchParticipants(String conversationId) async {
    List<String> participants = [];
    try {
      DocumentSnapshot conversationSnapshot =
          await _db.collection('Conversations').doc(conversationId).get();
      if (conversationSnapshot.exists && conversationSnapshot.data() != null) {
        final data = conversationSnapshot.data() as Map<String, dynamic>;
        participants = List.from(data['participants'] ?? []);
      }
    } catch (e) {
      print("Error");
    }
    return participants;
  }

  ///////////////////////////////////
  /// PROFILE_PAGE, FIREBASE_SERVICE
  /// STATUS: GOOD

  Future<CUNYUser?> getUserProfile(String userId) async {
    try {
      DocumentSnapshot snapshot =
          await _db.collection('Info').doc(userId).get();
      if (snapshot.exists && snapshot.data() != null) {
        print(snapshot.data());
        return CUNYUser.fromMap(
            snapshot.data() as Map<String, dynamic>, userId);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching user profile: $e");
      }
    }
    return null;
  }

  ///////////////////////////////////
  /// PROFILE_PAGE, FIREBASE_SERVICE
  /// STATUS: GOOD

  // Updates the bio for the user with the given UID
  Future<void> updateUserBio(String uid, String bio) async {
    try {
      await _db.collection('Info').doc(uid).update({'bio': bio});
      print("Bio updated successfully for UID: $uid");
    } catch (e) {
      print("Error updating user bio: $e");
      throw e;
    }
  }

  ///////////////////////////////////
  /// HOME_PAGE, FIREBASE_SERVICE
  /// STATUS: GOOD

  Future<CUNYUser?> getCurrentUser({bool forceRefresh = false}) async {
    if (_currentUser == null || forceRefresh) {
      _currentUser = await getUserProfile(userId);
    }
    return _currentUser;
  }

  ///////////////////////////////////
  /// CHAT_PAGE, CONVERSATION_CREATOR, FIREBASE_SERVICE
  /// STATUS: GOOD

  Future<String> getUserName(String uid) async {
    try {
      DocumentSnapshot userDoc = await _db.collection('Info').doc(uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>?;
        return userData?['name'] ?? 'Unknown User';
      } else {
        return 'User Not Found';
      }
    } catch (e) {
      print("Error fetching user name: $e");
      return 'Error';
    }
  }

  ///////////////////////////////////
  /// Conversation Creator
  /// STATUS: GOOD

  Future<DocumentReference> addConversation(
      Map<String, dynamic> conversationData) async {
    return await _db.collection('Conversations').add(conversationData);
  }

  ///////////////////////////////////
  // Conversation Creator
  // STATUS: GOOD

  Future<List<String>> fetchUserSuggestions(String query) async {
    var snapshot = await _db
        .collection('Info')
        .orderBy('name')
        .startAt([query])
        .endAt([query + '\uf8ff'])
        .limit(5)
        .get();

    return snapshot.docs.map((doc) => '${doc.id}:${doc['name']}').toList();
  }

  // Fetch conversations for the current user
  Future<List<Conversation>> fetchConversations() async {
    try {
      var conversationSnapshots = await _db
          .collection('Conversations')
          .where('participants', arrayContains: userId)
          .get();

      List<Conversation> conversations = [];
      for (var doc in conversationSnapshots.docs) {
        var data = doc.data();
        var conversation = await Conversation.fromFirestore(_db, data, doc.id);
        conversations.add(conversation);
      }
      return conversations;
    } catch (e) {
      print('Error fetching conversations: $e');
      return [];
    }
  }

  ///////////////////////////////////
  // Conversation Creator
  // STATUS: GOOD
  void updateUserProfile(String conversationId) async {
    try {
      DocumentReference userDoc = _db.collection('Info').doc(userId);
      DocumentSnapshot userSnapshot = await userDoc.get();
      if (userSnapshot.exists) {
        var data = userSnapshot.data() as Map<String, dynamic>;
        List<String> conversationIds =
            List<String>.from(data['conversationIDs'] ?? []);
        if (!conversationIds.contains(conversationId)) {
          conversationIds.add(conversationId);
          await userDoc.update({'conversationIDs': conversationIds});
          print('User profile updated with new conversation ID');
        }
      }
    } catch (e) {
      print('Error updating user profile: $e');
    }
  }

  ///////////////////////////////////
  // Conversation Creator
  // STATUS: GOOD
  Future<bool> checkConversationInUserProfile(String conversationId) async {
    try {
      DocumentSnapshot userDoc = await _db.collection('Info').doc(userId).get();
      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        List<String> conversationIds =
            List<String>.from(data['conversationIDs'] ?? []);
        return conversationIds.contains(conversationId);
      }
    } catch (e) {
      print('Error checking conversation in user profile: $e');
    }
    return false;
  }

  ///////////////////////////////////
  // Conversation Creator
  // STATUS: GOOD
  Future<void> addConversationToUserProfile(String conversationId) async {
    try {
      DocumentReference userDoc = _db.collection('Info').doc(userId);
      DocumentSnapshot userSnapshot = await userDoc.get();
      if (userSnapshot.exists) {
        Map<String, dynamic> data = userSnapshot.data() as Map<String, dynamic>;
        List<String> conversationIds =
            List<String>.from(data['conversationIDs'] ?? []);
        if (!conversationIds.contains(conversationId)) {
          conversationIds.add(conversationId);
          await userDoc.update({'conversationIDs': conversationIds});
          print('User profile updated with new conversation ID');
        }
      }
    } catch (e) {
      print('Error updating user profile: $e');
    }
  }

  ///////////////////////////////////
  /// PROFILE_PAGE, FIREBASE_SERVICE
  /// STATUS: GOOD

  // Updates the profile picture URL for the user with the given UID
  Future<void> updateUserProfilePicture(String uid, String imageUrl) async {
    try {
      await _db
          .collection('Info')
          .doc(uid)
          .update({'profilePictureUrl': imageUrl});
      print("Profile picture updated successfully for UID: $uid");
    } catch (e) {
      print("Error updating profile picture: $e");
      throw e;
    }
  }
}
