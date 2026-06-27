import 'Badge.dart';

class FriendBadge extends Badge {
  final int friendRequire;

  FriendBadge({
    required super.badgeName,
    required super.description,
    super.category = '',
    required super.type,
    required this.friendRequire,
    super.badgeID = 0,
  });

  factory FriendBadge.fromJson(Map<String, dynamic> json) {
    int friend = 0;
    if (json['FriendBadge'] != null) {
      if (json['FriendBadge'] is List &&
          (json['FriendBadge'] as List).isNotEmpty) {
        friend = json['FriendBadge'][0]['friendRequire'] ?? 0;
      } else if (json['FriendBadge'] is Map) {
        friend = json['FriendBadge']['friendRequire'] ?? 0;
      }
    }
    return FriendBadge(
      badgeName: json['badgeName'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      type: json['type'] ?? '',
      friendRequire: friend,
      badgeID: json['badgeID'] ?? 0, // <--- THÊM DÒNG NÀY
    );
  }
}
