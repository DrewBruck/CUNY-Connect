import 'package:cuny_connect/pages/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cuny_connect/auth/auth_gate.dart';
import 'package:cuny_connect/services/firebase_service.dart';
import 'package:cuny_connect/models/CUNYUser.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  final String? userId;
  const ProfilePage({Key? key, this.userId}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _bioController = TextEditingController();
  bool _isEditing = false;
  late bool _isCurrentUser;

  @override
  void initState() {
    super.initState();
    _isCurrentUser = FirebaseAuth.instance.currentUser!.uid == widget.userId || widget.userId == null;
  }

  void _updateBio() async {
    if (_bioController.text.length <= 250) {
      await _firebaseService.updateUserBio(FirebaseAuth.instance.currentUser!.uid, _bioController.text);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bio updated successfully!')));
      setState(() => _isEditing = false);
    }
  }

  void _signOut() async {
    final socketService = Provider.of<SocketService>(context, listen: false);
    await socketService.handleLogout(); // Call handleLogout to clear Hive data
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AuthGate()));
  }

  Future<CUNYUser?> _fetchUserProfile() async {
    String userId = widget.userId ?? FirebaseAuth.instance.currentUser!.uid;
    return await _firebaseService.getUserProfile(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Profile", style: TextStyle(color: Colors.white, fontFamily: 'SF Pro Display')),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: 600,
            padding: const EdgeInsets.all(25),
            child: FutureBuilder<CUNYUser?>(
              future: _fetchUserProfile(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (!snapshot.hasData) {
                  return const Text('No profile data available.');
                }
                CUNYUser user = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildProfilePicture(user),
                    const SizedBox(height: 10),
                    Text(user.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'SF Pro Display')),
                    const SizedBox(height: 20),
                    _buildInfoBubble(user),
                    const SizedBox(height: 20),
                    _buildBioSection(user),
                    const SizedBox(height: 20),
                    if (_isCurrentUser) _buildSignOutButton(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture(CUNYUser user) {
    return CircleAvatar(
      radius: 100,
      backgroundColor: Colors.purple[50],
      child: Text(
        user.name.isNotEmpty ? user.name[0] : 'U',
        style: const TextStyle(fontSize: 100, fontWeight: FontWeight.bold, fontFamily: 'SF Pro Display'),
      ),
    );
  }

  Widget _buildInfoBubble(CUNYUser user) {
    return Container(
      width: 600,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _infoRow(Icons.email, user.email),
          const Padding(
            padding: EdgeInsets.only(left: 48.0),
            child: Divider(color: Colors.black54, thickness: 1),
          ),
          _infoRow(Icons.school, user.major),
          const Padding(
            padding: EdgeInsets.only(left: 48.0),
            child: Divider(color: Colors.black54, thickness: 1),
          ),
          _infoRow(Icons.schedule, user.schedule.join(', ')),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String info) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: Colors.deepPurple),
          const SizedBox(width: 20),
          Expanded(
            child: Text(info, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'SF Pro Display')),
          ),
        ],
      ),
    );
  }

  Widget _buildBioSection(CUNYUser user) {
    return Container(
      width: 600,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Icon(Icons.description, size: 28, color: Colors.deepPurple),
          const SizedBox(width: 20),
          Expanded(
            child: _isEditing ? TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Edit Bio',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
              onFieldSubmitted: (_) => _updateBio(),
            ) : Text(user.bio ?? "No bio available.", style: const TextStyle(fontSize: 16, fontFamily: 'SF Pro Display')),
          ),
          if (_isCurrentUser && !_isEditing) ...[
            IconButton(
              icon: Icon(_isEditing ? Icons.check : Icons.edit, color: Colors.deepPurple),
              onPressed: () {
                if (_isEditing) {
                  _updateBio();
                } else {
                  setState(() {
                    _isEditing = true;
                    _bioController.text = user.bio ?? "";
                  });
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSignOutButton() {
    return InkWell(
      onTap: _signOut,
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.purple[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            "Sign Out",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }
}
