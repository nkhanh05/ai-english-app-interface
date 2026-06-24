class Badge {
  final int badgeID;
  final String badgeName;
  final String description;
  final String category;
  final String type;

  Badge({
    required this.badgeID,
    required this.badgeName,
    required this.description,
    required this.category,
    required this.type,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      badgeID: json['badgeID'] ?? 0,
      badgeName: json['badgeName'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      type: json['type'] ?? '',
    );
  }
}
