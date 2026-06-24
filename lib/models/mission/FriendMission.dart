// friend_mission.dart
import 'mission.dart';

class FriendMission extends Mission {
  final int friendRequire;

  FriendMission({
    required super.missionID,
    required super.missionName,
    super.description,
    super.type,
    super.adminID,
    super.startAt,
    super.endAt,
    required this.friendRequire,
  });

  factory FriendMission.fromJson(Map<String, dynamic> json) {
    final data = json['Mission'] ?? json;
    return FriendMission(
      missionID: data['missionID'] ?? 0,
      missionName: data['missionName'] ?? '',
      description: data['description'],
      type: data['type'],
      adminID: data['AdminID'],
      startAt: data['startAt'] != null ? DateTime.parse(data['startAt']) : null,
      endAt: data['endAt'] != null ? DateTime.parse(data['endAt']) : null,
      friendRequire: json['friendRequire'] ?? data['friendRequire'] ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(), // Gọi từ lớp cha nếu cần
      'friendRequire': friendRequire,
    };
  }
}
