import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '/models/user/Student.dart';
import 'BaseApi.dart';

class StudentService {
  static const String baseUrl = BaseApi.url;

  // 1. LẤY XẾP HẠNG TOÀN CẦU (Global Ranking)
  static Future<List<Student>> getGlobalRanking() async {
    final url = Uri.parse('$baseUrl/api/relationship/allPeople');

    try {
      final response = await http.get(url, headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) {
          return Student(
            userID: json['studentID'] is int ? json['studentID'] : int.tryParse(json['studentID']?.toString() ?? '0') ?? 0,
            username: json['username']?.toString() ?? '',
            fullName: json['fullName']?.toString() ?? '',
            weeklyExp: json['weeklyExp'] is int ? json['weeklyExp'] : 0,
            totalExp: json['totalExp'] is int ? json['totalExp'] : 0,
            streak: json['streak'] is int ? json['streak'] : 0,
            isStreakMaintained: json['isStreakmaintained'] == 1 || json['isStreakmaintained'] == true,
          );
        }).toList();
      } else {
        debugPrint("❌ Lỗi API Global Ranking: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      debugPrint("❌ Lỗi kết nối mạng tại getGlobalRanking: $e");
      return [];
    }
  }

  Future<Student?> getProfile(int studentId) async {
    final url = Uri.parse('$baseUrl/api/student/$studentId');

    try {
      final response = await http.get(url, headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Student(
          userID: data['studentID'] ?? data['userID'] ?? 0,
          username: data['username']?.toString() ?? '',
          fullName: data['fullName']?.toString() ?? data['name']?.toString() ?? '',
          weeklyExp: data['weeklyExp'] ?? 0,
          totalExp: data['totalExp'] ?? 0,
          streak: data['streak'] ?? 0,
          isStreakMaintained: data['isStreakmaintained'] == 1 || data['isStreakmaintained'] == true,
          avatarUrl: data['avatarUrl']?.toString(),
          status: data['status']?.toString(),
        );
      } else {
        debugPrint("❌ Lỗi API GetProfile: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint("❌ Lỗi kết nối mạng tại getProfile: $e");
      return null;
    }
  }

  static Future<List<Student>> getFriends(int userID) async {
    final url = Uri.parse('$baseUrl/api/relationship/friend/$userID');
    try {
      final response = await http.get(url, headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return _mapJsonToStudentList(data);
      } else {
        debugPrint("❌ Lỗi API GetFriends: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<List<Student>> getFollowers(int userID) async {
    final url = Uri.parse('$baseUrl/api/relationship/follower/$userID');
    try {
      final response = await http.get(url, headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return _mapJsonToStudentList(data);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<List<Student>> getFollowing(int userID) async {
    final url = Uri.parse('$baseUrl/api/relationship/following/$userID');
    try {
      final response = await http.get(url, headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return _mapJsonToStudentList(data);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static List<Student> _mapJsonToStudentList(List<dynamic> data) {
    return data.map((json) {
      return Student(
        userID: json['studentID'] is int ? json['studentID'] : int.tryParse(json['studentID']?.toString() ?? '0') ?? 0,
        username: json['username']?.toString() ?? '',
        fullName: json['fullName']?.toString() ?? '',
        weeklyExp: json['weeklyExp'] is int ? json['weeklyExp'] : 0,
        totalExp: json['totalExp'] is int ? json['totalExp'] : 0,
        streak: json['streak'] is int ? json['streak'] : 0,
        isStreakMaintained: json['isStreakmaintained'] == 1 || json['isStreakmaintained'] == true,
        avatarUrl: json['avatarUrl']?.toString(),
        status: json['status']?.toString(),
      );
    }).toList();
  }

  static Future<bool> updateProfile(int studentId, Map<String, dynamic> updateData) async {
    final url = Uri.parse('$baseUrl/api/student/update/$studentId');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updateData),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint("❌ Lỗi API UpdateProfile: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Lỗi kết nối mạng tại updateProfile: $e");
      return false;
    }
  }

  /// TÌM KIẾM NGƯỜI DÙNG BẰNG USERNAME
  static Future<Student?> searchByUsername(String username) async {
    final url = Uri.parse('$baseUrl/api/student/search?username=$username');
    try {
      final response = await http.get(url, headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['user'] != null) {
          final userData = data['user'];
          return Student(
            userID: userData['userID'],
            username: userData['username'],
            fullName: userData['fullName'] ?? 'Người dùng ẩn danh',
            weeklyExp: userData['weeklyExp'] ?? 0,
            totalExp: userData['totalExp'] ?? 0,
            streak: userData['streak'] ?? 0,
            avatarUrl: userData['avatarUrl']?.toString(),
          );
        }
      }
      return null;
    } catch (e) {
      debugPrint("❌ Lỗi mạng tại searchByUsername: $e");
      return null;
    }
  }
}
