import 'Badge.dart';

class StreakBadge extends Badge {
  final int streakCount;

  StreakBadge({
    required super.badgeName,
    required super.description,
    super.category = '',
    required super.type,
    required this.streakCount,
    super.badgeID = 0,
  });

  factory StreakBadge.fromJson(Map<String, dynamic> json) {
    int streak = 0;
    if (json['StreakBadge'] != null) {
      if (json['StreakBadge'] is List &&
          (json['StreakBadge'] as List).isNotEmpty) {
        streak = json['StreakBadge'][0]['streakCount'] ?? 0;
      } else if (json['StreakBadge'] is Map) {
        streak = json['StreakBadge']['streakCount'] ?? 0;
      }
    }
    return StreakBadge(
      badgeName: json['badgeName'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      type: json['type'] ?? '',
      streakCount: streak,
      badgeID: json['badgeID'] ?? 0, // <--- THÊM DÒNG NÀY
    );
  }
}
