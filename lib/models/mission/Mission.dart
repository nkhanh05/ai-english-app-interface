class Mission {
  final int missionID;
  final String missionName;
  final String description;
  final String type;
  final int? adminID;

  Mission({
    required this.missionID,
    required this.missionName,
    required this.description,
    required this.type,
    this.adminID,
  });

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      missionID: json['missionID'] ?? 0,
      missionName: json['missionName'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      adminID: json['AdminID'],
    );
  }
}

// Lớp con (Ví dụ cho các nhiệm vụ cụ thể)
class FriendMission extends Mission {
  final int friendRequire;
  FriendMission({
    required super.missionID,
    required super.missionName,
    required super.description,
    required super.type,
    required this.friendRequire,
  });
}
