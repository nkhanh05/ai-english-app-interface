import 'Mission.dart';

class FriendMission extends Mission {
  final int friendRequire;

  FriendMission({
    required super.missionName,
    required super.description,
    required super.type,
    super.startAt,
    super.endAt,
    required this.friendRequire,
    super.missionID,
  });

  factory FriendMission.fromJson(Map<String, dynamic> json) {
    int friend = 0;
    if (json['FriendMission'] != null) {
      if (json['FriendMission'] is List &&
          (json['FriendMission'] as List).isNotEmpty) {
        friend = json['FriendMission'][0]['friendRequire'] ?? 0;
      } else if (json['FriendMission'] is Map) {
        friend = json['FriendMission']['friendRequire'] ?? 0;
      }
    }
    return FriendMission(
      missionID: json['missionID'] ?? 0, // <--- THÊM DÒNG NÀY
      missionName: json['missionName'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      startAt: json['startAt'] != null
          ? DateTime.tryParse(json['startAt'].toString())
          : null,
      endAt: json['endAt'] != null
          ? DateTime.tryParse(json['endAt'].toString())
          : null,
      friendRequire: friend,
    );
  }
}
