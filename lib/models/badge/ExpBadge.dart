import 'Badge.dart';

class ExpBadge extends Badge {
  final int expRequire;

  ExpBadge({
    required super.badgeName,
    required super.description,
    super.category = '',
    required super.type,
    required this.expRequire,
    super.badgeID = 0,
  });

  factory ExpBadge.fromJson(Map<String, dynamic> json) {
    int exp = 0;
    if (json['ExpBadge'] != null) {
      if (json['ExpBadge'] is List && (json['ExpBadge'] as List).isNotEmpty) {
        exp = json['ExpBadge'][0]['ExpRequire'] ?? 0;
      } else if (json['ExpBadge'] is Map) {
        exp = json['ExpBadge']['ExpRequire'] ?? 0;
      }
    }
    return ExpBadge(
      badgeID: json['badgeID'] ?? 0, // <--- THÊM DÒNG NÀY
      badgeName: json['badgeName'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      type: json['type'] ?? '',
      expRequire: exp,
    );
  }
}
