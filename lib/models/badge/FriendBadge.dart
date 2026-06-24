// friend_badge.dart
import 'badge.dart';

class FriendBadge extends Badge {
  final int friendRequire;

  FriendBadge({
    required super.badgeID,
    required super.badgeName,
    super.description,
    super.category,
    super.type,
    super.adminID,
    required this.friendRequire,
  });

  factory FriendBadge.fromJson(Map<String, dynamic> json) {
    final data = json['Badge'] ?? json;
    return FriendBadge(
      badgeID: data['badgeID'] ?? 0,
      badgeName: data['badgeName'] ?? '',
      description: data['description'],
      category: data['category'],
      type: data['type'],
      adminID: data['AdminID'],
      friendRequire: json['friendRequire'] ?? data['friendRequire'] ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {...super.toJson() ?? {}, 'friendRequire': friendRequire};
  }
}
