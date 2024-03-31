import 'package:hive/hive.dart';
import 'package:cuny_connect/utils/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'conversation.g.dart';

@HiveType(typeId: 2)
class Conversation extends HiveObject {
  @HiveField(0)
  String conversationIds;
  @HiveField(1)
  List<ChatMessage> messages; // Ensure this is ready to store fetched messages.
  @HiveField(2)
  List<String> participants;

  Conversation({required this.conversationIds, required this.messages, required this.participants});

  // Adjust fromFirestore to handle message fetching
  static Future<Conversation> fromFirestore(FirebaseFirestore db, Map<String, dynamic> firestoreData, String id) async {
    List<String> participants = List<String>.from(firestoreData['participants']);
    // Fetch messages from the subcollection
    var messagesSnapshot = await db.collection('Conversations').doc(id).collection('messages').orderBy('timestamp').get();
    List<ChatMessage> messages = messagesSnapshot.docs
        .map((doc) => ChatMessage.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
        .toList();

    return Conversation(conversationIds: id, messages: messages, participants: participants);
  }
}

