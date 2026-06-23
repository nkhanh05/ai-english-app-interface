import 'badge.dart';

class ExpBadge extends Badge {
  final int expRequire;

  ExpBadge({
    required super.badgeID,
    required super.badgeName,
    required super.category,
    required this.expRequire,
  });
}
