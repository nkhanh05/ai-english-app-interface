import 'Mission.dart';

class WordMission extends Mission {
  final int wordRequire;

  WordMission({
    required super.missionName,
    required super.description,
    required super.type,
    super.startAt,
    super.endAt,
    required this.wordRequire,
    super.missionID = 0,
  });

  factory WordMission.fromJson(Map<String, dynamic> json) {
    int word = 0;
    if (json['WordMission'] != null) {
      if (json['WordMission'] is List &&
          (json['WordMission'] as List).isNotEmpty) {
        word = json['WordMission'][0]['wordRequire'] ?? 0;
      } else if (json['WordMission'] is Map) {
        word = json['WordMission']['wordRequire'] ?? 0;
      }
    }
    return WordMission(
      missionID: json['missionID'] ?? 0, //
      missionName: json['missionName'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      startAt: json['startAt'] != null
          ? DateTime.tryParse(json['startAt'].toString())
          : null,
      endAt: json['endAt'] != null
          ? DateTime.tryParse(json['endAt'].toString())
          : null,
      wordRequire: word,
    );
  }
}
