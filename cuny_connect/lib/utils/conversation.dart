import 'package:hive/hive.dart';
import 'package:cuny_connect/utils/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'conversation.g.dart';

@HiveType(typeId: 2)
class Conversation extends HiveObject {
  @HiveField(0)
  String conversationIds;
  @HiveField(1)
  List<ChatMessage> messages;
  @HiveField(2)
  List<String> participants;
  @HiveField(3)
  DateTime? lastMessageTime;
  @HiveField(4)
  String adminTitle;
  @HiveField(5)
  bool isAdmin;

  Conversation({
    required this.conversationIds,
    required this.messages,
    required this.participants,
    required this.adminTitle,
    required this.isAdmin,
  }) {
    lastMessageTime = messages.isNotEmpty ? messages.last.timestamp : null;
  }

  // Adjust fromFirestore to handle message fetching
  static Future<Conversation> fromFirestore(FirebaseFirestore db, Map<String, dynamic> firestoreData, String id) async {
    List<String> participants = List<String>.from(firestoreData['participants']);
    List<ChatMessage> messages = [];
    bool isAdmin = firestoreData['isAdmin'];
    String adminTitle = firestoreData['adminTitle'];

    try {
      // Fetch messages from the subcollection
      var messagesSnapshot = await db.collection('Conversations').doc(id).collection('messages').orderBy('timestamp').get();
      messages = messagesSnapshot.docs
          .map((doc) => ChatMessage.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print(e);
    }

    return Conversation(
      conversationIds: id,
      messages: messages,
      participants: participants,
      isAdmin: isAdmin,
      adminTitle: adminTitle,
    );
  }
}
