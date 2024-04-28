import 'package:cuny_connect/auth/login_or_register.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cuny_connect/auth/auth_gate.dart';
import 'package:cuny_connect/services/firebase_service.dart';
import 'package:cuny_connect/models/CUNYUser.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ProfilePage extends StatefulWidget {
  final String? userId; // Optional parameter to specify a user ID
  const ProfilePage({Key? key, this.userId}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _bioController = TextEditingController();
  bool _isEditing = false;
  final double _contentWidth = 500; // Set a fixed width for the content
  late bool _isCurrentUser;
  late String _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser!.uid;
    _isCurrentUser = widget.userId == null || widget.userId == _currentUserId;
  }

  void _updateBio() async {
    if (_bioController.text.length <= 250) {
      await _firebaseService.updateUserBio(_currentUserId, _bioController.text);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bio updated successfully!')));
      setState(() => _isEditing = false);
    }
  }

  Future<void> _signOutAndClearData() async{
    try{
      if(_isCurrentUser){
          await FirebaseAuth.instance.signOut();
          //await Hive.deleteFromDisk();  // Talk about data privacy later.
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const AuthGate()));
      }
    }catch(e){
      print("Error signing out: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while signing out. Please try again later.')));
    }
  }

  Future<CUNYUser?> _fetchUserProfile() async {
    String userId = widget.userId ?? _currentUserId;
    return await _firebaseService.getUserProfile(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Profile Page",
            style: TextStyle(color: Colors.white, fontSize: 20)),
        backgroundColor: Theme
            .of(context)
            .primaryColor,
      ),
      body: FutureBuilder<CUNYUser?>(
        future: _fetchUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No profile data available.'));
          }
          final user = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  color: Colors.grey[200], // Upper background color
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _profileIcon(),
                      const SizedBox(height: 20),
                      Container(),
                    ],
                  ),
                ),
                _buildDivider(context),
                const SizedBox(height: 20),
                if (_isEditing) _buildBioSection(user) else
                  Container(
                    width: _contentWidth,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        if (!_isEditing) _buildBioSection(user),
                        const SizedBox(height: 20),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            children: _infoCards(user),
                          ),
                        ),

                        if(_isCurrentUser) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20.0),
                              child: ElevatedButton(
                                onPressed: _signOutAndClearData,
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(150, 50),
                                ),
                                child: const Text(
                                  'Sign Out',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                         ],
                        
                      ],
                    ),

                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _profileIcon() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.black,
          width: 4,
        ),
      ),
      child: const CircleAvatar(
        radius: 60,
        backgroundColor: Colors.transparent,
        child: Icon(Icons.person, size: 120),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            height: 2,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  List<Widget> _infoCards(CUNYUser user) {
    return [
      _infoCard('Name', user.name),
      _infoCard('Email', user.email),
      _infoCard('Major', user.major),
      _infoCard('Schedule', user.schedule.join(', ')),
    ];
  }

  Widget _infoCard(String title, String info) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 50.0),
      // Increase horizontal padding for alignment
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              "$title: ",
              style: const TextStyle(fontWeight: FontWeight.bold,
                  fontSize: 18), // Increased font size
            ),
          ),
          Expanded(
            flex: 2, // Adjust flex to give more space for the info text
            child: Text(
              info,
              style: const TextStyle(
                  fontSize: 16), // Increased font size for info text
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildBioSection(CUNYUser user) {
      return Align(
        alignment: Alignment.center,
        child: Column(
          children: [
            if (_isCurrentUser) ...[
              if (_isEditing) ...[
                Container(
                  width: _contentWidth,  // Control the width of the TextFormField
                  child: TextFormField(
                    controller: _bioController,
                    maxLength: 250,
                    decoration: const InputDecoration(
                      labelText: 'Bio',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _updateBio,
                  child: const Text('Save Bio'),
                ),
              ] else ...[
                TextButton(
                  onPressed: () => setState(() => _isEditing = true),
                  child: const Text('Edit Bio', style: TextStyle(fontSize: 16)),
                ),
                Container(
                  width: _contentWidth,
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  alignment: Alignment.center,
                  child: Text(
                    user.bio ?? "No bio available.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ] else ...[
              Container(
                width: _contentWidth,
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                alignment: Alignment.center,
                child: Text(
                  user.bio ?? "No bio available.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ],
        ),
      );
    }
    
  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }
}
