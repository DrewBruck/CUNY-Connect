class CUNYUser {
  final String CUNYUserId;
  final String name;
  final String email;
  final String major;
  final String bio;
  final List<String> schedule;
  final List<String> conIDs;
  final String? profilePictureUrl;

  CUNYUser({
    required this.CUNYUserId,
    required this.name,
    required this.email,
    required this.major,
    required this.schedule,
    required this.bio,
    required this.conIDs,
    this.profilePictureUrl,
  });

  factory CUNYUser.fromMap(Map<String, dynamic> data, String UserID) {
    List<String> scheduleList =
        List<String>.from(data['schedule'] as List<dynamic> ?? []);
    List<String> conIDList =
        List<String>.from(data['conversationIDs'] as List<dynamic> ?? []);
    return CUNYUser(
      CUNYUserId: UserID,
      name: data['name'],
      email: data['email'],
      major: data['major'],
      bio: data['bio'],
      conIDs: conIDList,
      schedule: scheduleList,
      profilePictureUrl: data['profilePictureUrl'],
    );
  }
}
