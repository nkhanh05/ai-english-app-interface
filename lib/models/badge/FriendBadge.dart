import 'badge.dart';

class FriendBadge extends Badge {
  final int friendRequire;

  FriendBadge({
    required super.badgeID,
    required super.badgeName,
    required super.category,
    required this.friendRequire,
  });
}
