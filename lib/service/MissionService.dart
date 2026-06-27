import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
// Lưu ý: Cập nhật lại đường dẫn import Mission.dart cho khớp với thư mục của bạn
import '/models/mission/Mission.dart';
import 'BaseApi.dart';

class MissionService {
  static String baseUrl = BaseApi.url;

  /// Lấy danh sách nhiệm vụ của một User
  /// Trả về list đối tượng StudentMissionDetail (chứa Mission, status và progress)
  ///

  static Future<List<Mission>> getAllMissions() async {
    final url = Uri.parse('$baseUrl/api/mission/admin/select');
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((e) => Mission.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> addMission({
    required String missionName,
    required String description,
    required String type,
    required int adminID,
    String? startAt,
    String? endAt,
    int? wordRequire,
    int? friendRequire,
  }) async {
    final url = Uri.parse('$baseUrl/api/mission/admin/add');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'missionName': missionName,
          'description': description,
          'type': type,
          'adminID': adminID,
          'startAt': startAt,
          'endAt': endAt,
          'wordRequire': wordRequire,
          'friendRequire': friendRequire,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateMission(
    int missionId, {
    required String missionName,
    required String description,
    required String type,
    String? startAt,
    String? endAt,
    int? wordRequire,
    int? friendRequire,
  }) async {
    final url = Uri.parse('$baseUrl/api/mission/admin/update/$missionId');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'missionName': missionName,
          'description': description,
          'type': type,
          'startAt': startAt,
          'endAt': endAt,
          'wordRequire': wordRequire,
          'friendRequire': friendRequire,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteMission(int missionId) async {
    final url = Uri.parse('$baseUrl/api/mission/admin/delete/$missionId');
    try {
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  static Future<List<StudentMissionDetail>> getStudentMissions(
    int studentId,
  ) async {
    final url = Uri.parse('$baseUrl/api/mission/student/$studentId');
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // In log ra để dễ debug nếu server đổi cấu trúc
        debugPrint("Mission API Body: ${response.body}");

        var decoded = jsonDecode(response.body);
        List<dynamic> data = [];

        // Kiểm tra thông minh xem dữ liệu là List hay Map
        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map) {
          if (decoded.containsKey('data') && decoded['data'] is List) {
            data = decoded['data'];
          } else {
            data = [decoded];
          }
        }

        // Parse JSON
        return data
            .map(
              (json) =>
                  StudentMissionDetail.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      } else {
        debugPrint("❌ Lỗi API getStudentMissions: ${response.body}");
        return [];
      }
    } catch (e) {
      debugPrint("❌ Lỗi kết nối getStudentMissions: $e");
      return [];
    }
  }

  static Future<bool> updateWordMissionProgress(int studentID) async {
    final url = Uri.parse('$baseUrl/api/mission/word/update/$studentID');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        debugPrint("✅ Cập nhật nhiệm vụ Từ Vựng thành công!");
        return true;
      } else {
        debugPrint("❌ Lỗi API updateWordMission: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Lỗi kết nối mạng tại updateWordMission: $e");
      return false;
    }
  }

  /// Gọi API cập nhật tiến độ nhiệm vụ Bạn Bè
  static Future<bool> updateFriendMissionProgress(int studentID) async {
    final url = Uri.parse('$baseUrl/api/mission/friend/update/$studentID');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        debugPrint("✅ Cập nhật nhiệm vụ Bạn Bè thành công!");
        return true;
      } else {
        debugPrint("❌ Lỗi API updateFriendMission: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Lỗi kết nối mạng tại updateFriendMission: $e");
      return false;
    }
  }
}
