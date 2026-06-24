// streak_badge.dart
import 'badge.dart';

class StreakBadge extends Badge {
  final int streakCount;

  StreakBadge({
    required super.badgeID,
    required super.badgeName,
    super.description,
    super.category,
    super.type,
    super.adminID,
    required this.streakCount,
  });

  factory StreakBadge.fromJson(Map<String, dynamic> json) {
    final data = json['Badge'] ?? json;
    return StreakBadge(
      badgeID: data['badgeID'] ?? 0,
      badgeName: data['badgeName'] ?? '',
      description: data['description'],
      category: data['category'],
      type: data['type'],
      adminID: data['AdminID'],
      streakCount: json['streakCount'] ?? data['streakCount'] ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {...super.toJson() ?? {}, 'streakCount': streakCount};
  }
}
