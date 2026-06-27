import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
// Lưu ý: Cập nhật lại đường dẫn import Badge.dart cho khớp với thư mục của bạn
import '/models/badge/Badge.dart';
import 'BaseApi.dart';

class BadgeService {
  static String baseUrl = BaseApi.url;

  // =========================================================
  // 1. DÀNH CHO ADMIN (THÊM, SỬA, XÓA)
  // =========================================================

  /// Thêm huy hiệu mới
  static Future<bool> addBadge({
    required String badgeName,
    required String description,
    required String category,
    required String type,
    required int adminID,
    int? expRequire,
    int? friendRequire,
    int? streakCount,
  }) async {
    final url = Uri.parse('$baseUrl/api/badge/admin/add');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'badgeName': badgeName,
          'description': description,
          'category': category,
          'type': type,
          'adminID': adminID,
          'expRequire': expRequire,
          'friendRequire': friendRequire,
          'streakCount': streakCount,
        }),
      );

      if (response.statusCode == 201) {
        debugPrint("✅ Thêm huy hiệu thành công!");
        return true;
      } else {
        debugPrint("❌ Lỗi API thêm huy hiệu: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Lỗi kết nối: $e");
      return false;
    }
  }

  static Future<List<Badge>> getAllBadges() async {
    final url = Uri.parse('$baseUrl/api/badge/admin/select');
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((e) => Badge.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> checkAndAwardBadges(int studentID) async {
    final url = Uri.parse('$baseUrl/api/badge/check/$studentID');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint("✅ Kiểm tra huy hiệu hoàn tất!");

        // In ra log nếu user vừa nhận được huy hiệu mới
        if (data['awarded'] != null && (data['awarded'] as List).isNotEmpty) {
          debugPrint("🏆 Bạn vừa nhận được huy hiệu mới: ${data['awarded']}");
        }

        return true;
      } else {
        debugPrint("❌ Lỗi API checkAndAwardBadges: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Lỗi kết nối mạng tại checkAndAwardBadges: $e");
      return false;
    }
  }

  /// Cập nhật huy hiệu
  static Future<bool> updateBadge(
    int badgeId, {
    required String badgeName,
    required String description,
    required String category,
    required String type,
    int? expRequire,
    int? friendRequire,
    int? streakCount,
  }) async {
    final url = Uri.parse('$baseUrl/api/badge/admin/update/$badgeId');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'badgeName': badgeName,
          'description': description,
          'category': category,
          'type': type,
          'expRequire': expRequire,
          'friendRequire': friendRequire,
          'streakCount': streakCount,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("❌ Lỗi kết nối updateBadge: $e");
      return false;
    }
  }

  /// Xóa huy hiệu
  static Future<bool> deleteBadge(int badgeId) async {
    final url = Uri.parse('$baseUrl/api/badge/admin/delete/$badgeId');
    try {
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      debugPrint("❌ Lỗi kết nối deleteBadge: $e");
      return false;
    }
  }

  // =========================================================
  // 2. DÀNH CHO STUDENT (NGƯỜI HỌC)
  // =========================================================

  /// Lấy danh sách huy hiệu ĐÃ SỞ HỮU
  static Future<List<Badge>> getOwnedBadges(int studentId) async {
    final url = Uri.parse('$baseUrl/api/badge/student/$studentId/owned');
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        debugPrint("Badge Owned API Body: ${response.body}");

        var decoded = jsonDecode(response.body);
        List<dynamic> data = [];

        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map) {
          if (decoded.containsKey('data') && decoded['data'] is List) {
            data = decoded['data'];
          } else {
            data = [decoded];
          }
        }

        return data.map((item) {
          // Xử lý bọc lót: Dữ liệu có thể lồng trong key 'Badge' hoặc nằm thẳng ở ngoài
          final badgeJson = (item is Map && item.containsKey('Badge'))
              ? item['Badge'] as Map<String, dynamic>
              : item as Map<String, dynamic>;

          return Badge.fromJson(badgeJson);
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint("❌ Lỗi getOwnedBadges: $e");
      return [];
    }
  }

  /// Lấy danh sách huy hiệu CHƯA SỞ HỮU
  static Future<List<Badge>> getUnownedBadges(int studentId) async {
    final url = Uri.parse('$baseUrl/api/badge/student/$studentId/unowned');
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        debugPrint("Badge Unowned API Body: ${response.body}");

        var decoded = jsonDecode(response.body);
        List<dynamic> data = [];

        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map) {
          if (decoded.containsKey('data') && decoded['data'] is List) {
            data = decoded['data'];
          } else {
            data = [decoded];
          }
        }

        // Danh sách chưa sở hữu thường trả về dạng mảng phẳng
        return data
            .map((item) => Badge.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint("❌ Lỗi getUnownedBadges: $e");
      return [];
    }
  }
}
