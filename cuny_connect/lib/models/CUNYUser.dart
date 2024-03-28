class CUNYUser {
  final String CUNYUserId;
  final String name;
  final String email;
  final String major;
  final String bio;
  final List<String> schedule;

  CUNYUser({
    required this.CUNYUserId,
    required this.name,
    required this.email,
    required this.major,
    required this.schedule,
    required this.bio
  });

  factory CUNYUser.fromMap(Map<String, dynamic> data, String UserID) {
    List<String> scheduleList =  List<String>.from(data['schedule'] as List<dynamic> ?? []);
    return CUNYUser(
      CUNYUserId: UserID,
      name: data['name'],
      email: data['email'],
      major: data['major'],
      bio: data['bio'],
      schedule: scheduleList,
    );
  }
}

