import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/badge/Badge.dart';

class BadgeService {
  static const String baseUrl = 'https://ai-english-app-server.onrender.com';

  static Future<List<Badge>> getAllBadges() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/badge/admin/select'),
    );
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((e) => Badge.fromJson(e)).toList();
    }
    return [];
  }

  static Future<List<Badge>> getStudentBadges(int studentID) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/badge/student/$studentID'),
    );
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      // Backend trả về Badge(*) nên cần map vào key 'Badge'
      return data.map((e) => Badge.fromJson(e['Badge'])).toList();
    }
    return [];
  }
}
