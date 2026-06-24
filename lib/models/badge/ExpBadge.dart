// exp_badge.dart
import 'badge.dart';

class ExpBadge extends Badge {
  final int expRequire;

  ExpBadge({
    required super.badgeID,
    required super.badgeName,
    super.description,
    super.category,
    super.type,
    super.adminID,
    required this.expRequire,
  });

  factory ExpBadge.fromJson(Map<String, dynamic> json) {
    final data = json['Badge'] ?? json;
    return ExpBadge(
      badgeID: data['badgeID'] ?? 0,
      badgeName: data['badgeName'] ?? '',
      description: data['description'],
      category: data['category'],
      type: data['type'],
      adminID: data['AdminID'],
      expRequire: json['ExpRequire'] ?? data['ExpRequire'] ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'badgeID': badgeID,
      'badgeName': badgeName,
      'description': description,
      'category': category,
      'type': type,
      'AdminID': adminID,
      'ExpRequire': expRequire,
    };
  }
}
