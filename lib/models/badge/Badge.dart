import 'ExpBadge.dart';
import 'FriendBadge.dart';
import 'StreakBadge.dart';

class Badge {
  final String badgeName;
  final String description;
  final String category;
  final String type;
  final int badgeID;

  Badge({
    required this.badgeName,
    required this.description,
    this.category = '',
    required this.type,
    this.badgeID = 0,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    String type = json['type'] ?? '';

    // Kiểm tra an toàn cho cả trường hợp trả về Map hoặc List
    bool hasExp =
        json['ExpBadge'] != null &&
        (json['ExpBadge'] is Map ||
            (json['ExpBadge'] is List &&
                (json['ExpBadge'] as List).isNotEmpty));

    bool hasFriend =
        json['FriendBadge'] != null &&
        (json['FriendBadge'] is Map ||
            (json['FriendBadge'] is List &&
                (json['FriendBadge'] as List).isNotEmpty));

    bool hasStreak =
        json['StreakBadge'] != null &&
        (json['StreakBadge'] is Map ||
            (json['StreakBadge'] is List &&
                (json['StreakBadge'] as List).isNotEmpty));

    if (type == 'Exp' || hasExp) {
      return ExpBadge.fromJson(json);
    } else if (type == 'Friend' || hasFriend) {
      return FriendBadge.fromJson(json);
    } else if (type == 'Streak' || hasStreak) {
      return StreakBadge.fromJson(json);
    }

    return Badge(
      badgeName: json['badgeName'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      type: type,
      badgeID: json['badgeID'] ?? 0,
    );
  }
}
