import 'badge.dart';

class StreakBadge extends Badge {
  final int streakCount;

  StreakBadge({
    required super.badgeID,
    required super.badgeName,
    required super.category,
    required this.streakCount,
  });
}
