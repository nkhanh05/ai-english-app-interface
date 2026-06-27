import '/models/user/User.dart';

class Admin extends User {
  Admin({
    required int userID,
    required String username,
    required String fullName,
    String? avatarUrl,
    String? status,
  }) : super(
         userID: userID,
         username: username,
         fullName: fullName,
         role: 'admin',
         avatarUrl: avatarUrl,
         status: status,
       );
}
