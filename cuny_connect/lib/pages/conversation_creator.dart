import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cuny_connect/services/firebase_service.dart';
import 'package:flutter/services.dart';

class ConversationCreator extends StatefulWidget {
  const ConversationCreator({super.key});

  @override
  _ConversationCreatorState createState() => _ConversationCreatorState();
}

class _ConversationCreatorState extends State<ConversationCreator> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _initialMessageController = TextEditingController(text: "Hello! This is the start of your conversation.");
  Map<String, String> _participants = {}; // userID: userName
  final FirebaseService _firebaseService = FirebaseService();
  TextEditingController _autocompleteController = TextEditingController();
  FocusNode _autocompleteFocusNode = FocusNode();
  final Map<String, String> _nameToIdMap = {}; 

  @override
  void initState() {
    super.initState();
    _addCurrentUser();
  }

  void _addCurrentUser() {
    String currentUserId = _firebaseService.userId;
    _firebaseService.getUserName(currentUserId).then((userName) {
      setState(() {
        _participants[currentUserId] = userName ?? 'Current User'; // Assuming getUserName might return null
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text("Create Conversation", style: const TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) async {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                else { if (kDebugMode) { print(textEditingValue.text); } }

                var suggestions = await _firebaseService.fetchUserSuggestions(textEditingValue.text);
                _nameToIdMap.clear();
                for (var suggestion in suggestions) {
                  var details = suggestion.split(':');
                  if (details.length >= 2 && details[0] != _firebaseService.userId) {
                    _nameToIdMap[details[1]] = details[0]; // Populate the map with userName: userId
                  }
                }

                return _nameToIdMap.keys; // Return only names
              },
              onSelected: (String userName) {
                String? userId = _nameToIdMap[userName];
                if (userId != null && userId != _firebaseService.userId) {
                  _addParticipant(userId, userName);
                  _autocompleteController.clear();
                  setState(() {
                    _autocompleteController.text = ' ';
                    _autocompleteController.text = '';
                  });
                  FocusScope.of(context).requestFocus(FocusNode()); // Explicitly shift the focus
                }
              },
              fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                _autocompleteController = textEditingController;
                _autocompleteFocusNode = focusNode;
                return TextFormField(
                  controller: _autocompleteController,
                  focusNode: _autocompleteFocusNode,
                  decoration: const InputDecoration(
                    labelText: 'Search users',
                    hintText: 'Start typing...',
                  ),
                );
              },
            ),
            if (_participants.length > 2) // Only show when more than two users are present
              TextFormField(
                controller: _groupNameController,
                decoration: const InputDecoration(
                  labelText: 'Group Name',
                  hintText: 'Enter a name for the group',
                  counterText: '',
                ),
                maxLength: 30,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
              ),
            TextFormField(
              controller: _initialMessageController,
              decoration: const InputDecoration(
                labelText: 'Initial Message',
                hintText: 'Enter the initial message',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:  (_participants.length > 1) ? _createConversation : null,
              child: const Text('Create Conversation'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _participants.length,
                itemBuilder: (context, index) {
                  String userId = _participants.keys.elementAt(index);
                  String userName = _participants[userId]!;
                  return ListTile(
                    title: Text(userName),
                    trailing: userId != _firebaseService.userId ? IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => _removeParticipant(userId),
                    ) : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addParticipant(String userId, String userName) {
    if (!_participants.containsKey(userId)) {
      setState(() {
        _participants[userId] = userName;
      });
    }
  }

  void _removeParticipant(String userId) {
    if (userId != _firebaseService.userId) { // Prevent removing current user
      setState(() {
        _participants.remove(userId);
      });
    }
  }

  void _createConversation() async {
    if (_participants.isNotEmpty) {
      Map<String, dynamic> newConversation = {
        'participants': _participants.keys.toList(),
        'isAdmin': false,
        'adminTitle': _participants.length > 2 ? _groupNameController.text : "",
      };

      try {
        DocumentReference conversationRef = await _firebaseService.addConversation(newConversation);
        if (kDebugMode) {
          print('Conversation created with ID: ${conversationRef.id}');
        }
        await _addInitialMessage(conversationRef.id, conversationRef);
        Navigator.pop(context);
      } catch (e) {
        if (kDebugMode) {
          print('Failed to create conversation: $e');
        }
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error creating conversation')));
      }
    }
  }

  Future<void> _addInitialMessage(String conversationId, DocumentReference conversationRef) async {
    String senderId = _firebaseService.userId;
    String senderName = await _firebaseService.getUserName(senderId);
    // Create a list of receiver IDs by filtering out the current user's ID
    List<String> receiverIds = _participants.keys.where((id) => id != senderId).toList();

    Map<String, dynamic> messageData = {
      'content': _initialMessageController.text,
      'receiverId': receiverIds,
      'senderId': senderId,
      'senderName': senderName,
      'timestamp': Timestamp.now(),
    };

    try {
      await conversationRef.collection('messages').add(messageData);
      if (kDebugMode) {
        print('Initial message added successfully.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to add initial message: $e');
      }
    }
  }
}