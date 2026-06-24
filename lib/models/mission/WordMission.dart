// word_mission.dart
import 'mission.dart';

class WordMission extends Mission {
  final int wordRequire;

  WordMission({
    required super.missionID,
    required super.missionName,
    super.description,
    super.type,
    super.adminID,
    super.startAt,
    super.endAt,
    required this.wordRequire,
  });

  factory WordMission.fromJson(Map<String, dynamic> json) {
    final data = json['Mission'] ?? json;
    return WordMission(
      missionID: data['missionID'] ?? 0,
      missionName: data['missionName'] ?? '',
      description: data['description'],
      type: data['type'],
      adminID: data['AdminID'],
      startAt: data['startAt'] != null ? DateTime.parse(data['startAt']) : null,
      endAt: data['endAt'] != null ? DateTime.parse(data['endAt']) : null,
      wordRequire: json['wordRequire'] ?? data['wordRequire'] ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {...super.toJson(), 'wordRequire': wordRequire};
  }
}
