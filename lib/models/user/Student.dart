import '/models/user/User.dart';

class Student extends User {
  final int weeklyExp;
  final int totalExp;
  final int streak;
  final bool isStreakMaintained;

  Student({
    required int userID,
    required String username,
    required String fullName,
    required this.weeklyExp,
    required this.totalExp,
    required this.streak,
    this.isStreakMaintained = false,
    String? avatarUrl,
    String? status,
  }) : super(
         userID: userID,
         username: username,
         fullName: fullName,
         role: 'student',
         avatarUrl: avatarUrl,
         status: status,
       );

  Student copyWith({
    int? weeklyExp,
    int? totalExp,
    int? streak,
    bool? isStreakMaintained,
    String? avatarUrl,
    String? status,
  }) {
    return Student(
      userID: this.userID,
      username: this.username,
      fullName: this.fullName,
      weeklyExp: weeklyExp ?? this.weeklyExp,
      totalExp: totalExp ?? this.totalExp,
      streak: streak ?? this.streak,
      isStreakMaintained: isStreakMaintained ?? this.isStreakMaintained,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      status: status ?? this.status,
    );
  }
}
