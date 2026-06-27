import 'FriendMission.dart';
import 'WordMission.dart';

class Mission {
  final int missionID;
  final String missionName;
  final String description;
  final String type;
  final DateTime? startAt;
  final DateTime? endAt;

  Mission({
    required this.missionName,
    required this.description,
    required this.type,
    this.startAt,
    this.endAt,
    this.missionID = 0,
  });

  factory Mission.fromJson(Map<String, dynamic> json) {
    String type = json['type'] ?? '';

    bool hasFriend =
        json['FriendMission'] != null &&
        (json['FriendMission'] is Map ||
            (json['FriendMission'] is List &&
                (json['FriendMission'] as List).isNotEmpty));

    bool hasWord =
        json['WordMission'] != null &&
        (json['WordMission'] is Map ||
            (json['WordMission'] is List &&
                (json['WordMission'] as List).isNotEmpty));

    if (type == 'Friend' || hasFriend) {
      return FriendMission.fromJson(json);
    } else if (type == 'Word' || hasWord) {
      return WordMission.fromJson(json);
    }

    return Mission(
      missionName: json['missionName'] ?? '',
      missionID: json['missionID'] ?? 0, //THÊM DÒNG NÀY
      description: json['description'] ?? '',
      type: type,
      startAt: json['startAt'] != null
          ? DateTime.tryParse(json['startAt'].toString())
          : null,
      endAt: json['endAt'] != null
          ? DateTime.tryParse(json['endAt'].toString())
          : null,
    );
  }
}

// Class bọc dành riêng cho Student_Mission (chứa thêm status và progress)
class StudentMissionDetail {
  final Mission mission;
  final String status;
  final int progress;

  StudentMissionDetail({
    required this.mission,
    required this.status,
    required this.progress,
  });

  factory StudentMissionDetail.fromJson(Map<String, dynamic> json) {
    return StudentMissionDetail(
      mission: Mission.fromJson(json['Mission'] ?? {}),
      status: json['status'] ?? 'unfinished',
      progress: json['progress'] ?? 0,
    );
  }
}
