import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mission/Mission.dart';

class MissionService {
  static const String baseUrl = 'https://ai-english-app-server.onrender.com';

  static Future<List<Mission>> getAllMissions() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/mission/admin/select'),
    );
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((e) => Mission.fromJson(e)).toList();
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getStudentMissions(
    int studentID,
  ) async {
    final response = await http.get(Uri.parse('$baseUrl/student/$studentID'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    }
    return [];
  }
}
