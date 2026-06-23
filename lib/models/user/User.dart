class User {
  final int userID;
  final String username;
  final String fullName;
  final String role;
  final String? avatarUrl;
  final String? status;

  User({
    required this.userID,
    required this.username,
    required this.fullName,
    required this.role,
    this.avatarUrl,
    this.status,
  });
}
