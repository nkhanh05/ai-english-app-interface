import 'dart:convert';
import 'package:http/http.dart' as http;
import '/models/user/User.dart';
import '/models/user/Student.dart'; // Thêm import này
import '/models/user/Admin.dart'; // Thêm import này
import 'BaseApi.dart';

class UserService {
  /// Xử lý Đăng nhập
  String baseUrl = BaseApi.url;

  /// Trả về đối tượng Student hoặc Admin (đều kế thừa từ User)
  Future<User?> checkLogin(String username, String password) async {
    final url = Uri.parse('${baseUrl}/api/user/signin');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final userData = data['user'];
        final role = userData['role']; // Lấy role từ database trả về

        // PHÂN LOẠI ĐỐI TƯỢNG TRẢ VỀ DỰA VÀO ROLE
        if (role == 'admin') {
          return Admin(
            userID: userData['userID'],
            username: userData['username'],
            fullName: userData['fullName'] ?? 'Chưa cập nhật',
          );
        } else if (role == 'student') {
          // Xử lý giá trị null từ DB (nếu có) thành 0
          return Student(
            userID: userData['userID'],
            username: userData['username'],
            fullName: userData['fullName'] ?? 'Chưa cập nhật',
            weeklyExp: userData['weeklyExp'] ?? 0,
            totalExp: userData['totalExp'] ?? 0,
            streak: userData['streak'] ?? 0,
            isStreakMaintained: userData['isStreakMaintained'] ?? false,
            avatarUrl: userData['avatarUrl'] ?? '',
          );
        } else {
          // Đề phòng trường hợp lỗi data role không khớp
          return User(
            userID: userData['userID'],
            username: userData['username'],
            fullName: userData['fullName'] ?? 'Chưa cập nhật',
            role: role ?? 'unknown',
          );
        }
      } else if (response.statusCode == 401) {
        print("❌ Cảnh báo từ Server: ${data['message']}");
        return null;
      } else {
        print("❌ Lỗi khác: ${data['message']}");
        return null;
      }
    } catch (e) {
      print("❌ Lỗi kết nối mạng tại checkLogin: $e");
      return null;
    }
  }

  // ... (Phần code addNewStudent giữ nguyên) ...
  Future<int?> addNewStudent(
    String username,
    String password,
    String email,
    String fullName,
  ) async {
    final url = Uri.parse('${baseUrl}/api/user/signup');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'email': email,
          'fullName': fullName,
          'status': "Inactive",
        }),
      );

      final data = jsonDecode(response.body);

      // Backend trả về 201 Created khi đăng ký thành công
      if (response.statusCode == 201 && data['success'] == true) {
        print("✅ ${data['message']}"); // "Đăng ký tài khoản thành công!"
        return data['userID'];
      }
      // Xử lý mã lỗi 409 (Trùng username)
      else if (response.statusCode == 409) {
        print("❌ Cảnh báo từ Server: ${data['message']}");
        return null;
      }
      // Các lỗi khác (400 thiếu dữ liệu, 500 lỗi DB)
      else {
        print("❌ Lỗi tạo tài khoản: ${data['message']}");
        return null;
      }
    } catch (e) {
      print("❌ Lỗi kết nối mạng tại addNewStudent: $e");
      return null;
    }
  }
}
