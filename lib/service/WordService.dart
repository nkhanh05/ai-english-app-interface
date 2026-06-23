import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Để dùng debugPrint
import '/state/global_state.dart'; // Để lấy thông tin người dùng hiện tại
// Nhớ import model của bạn cho chuẩn đường dẫn nhé
import '/models/word/Word.dart';
// import '/models/user/User.dart'; // Mở comment dòng này nếu bạn có file model User

class AppConfig {
  static const String baseUrl =
      'https://ai-english-app-fjdhdhe0bzh0faht.eastasia-01.azurewebsites.net';
}

class WordService {
  // --------------------------------------------------------
  // 1. XỬ LÝ ĐĂNG NHẬP (Tương ứng API POST /signin)
  // --------------------------------------------------------
  /// Trả về Map chứa thông tin User nếu thành công, trả về null nếu thất bại.
  /// Nếu bạn đã có class User, hãy đổi kiểu trả về thành Future<User?>

  Future<bool> addWordToLibrary(Word word, int userID) async {
    final url = Uri.parse('${AppConfig.baseUrl}/api/word/addWord');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'userID': userID,
          'term': word.term,
          'definition': word.definition,
          // Kiểm tra xem model Word của bạn có thuộc tính imageUrl chưa.
          // Nếu chưa có, bạn truyền null hoặc chuỗi rỗng vào.
          'photoUrl': word.photoUrl ?? 'ha',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        currentStudentNotifier.value = currentStudentNotifier.value!.copyWith(
          isStreakMaintained: true,
          streak: currentStudentNotifier.value!.streak + 1,
        ); // Cập nhật lại giá trị để UI nhận biết

        debugPrint("✅ Đã lưu từ vựng vào Database thành công!");
        return true;
      } else {
        debugPrint("❌ Lỗi API khi lưu từ: ${response.statusCode}");
        debugPrint("Chi tiết: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Lỗi kết nối mạng khi lưu từ: $e");
      return false;
    }
  }

  ////////////
  ///
  ///
  ///
  Future<List<Word>> getUserWords(int userId) async {
    // Truyền userId thẳng vào URL
    final url = Uri.parse('${AppConfig.baseUrl}/api/word/$userId');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        List<dynamic> rawWords = data['words'];

        // Map thẳng list JSON thành List<Word> ngay tại đây
        List<Word> wordsList = rawWords.map((json) {
          return Word(
            // CHÚ Ý: Chỗ này tao đang xử lý ép kiểu an toàn.
            // Nếu trong file Word.dart mày khai báo wordID là INT:
            id: json['wordID'] is int
                ? json['wordID']
                : int.tryParse(json['wordID']?.toString() ?? '0') ?? 0,

            term: json['term']?.toString() ?? '',
            definition: json['definition']?.toString() ?? '',
            photoUrl: json['photoUrl']?.toString(),
            lastReview:
                DateTime.tryParse(json['lastReview'] ?? '') ?? DateTime.now(),
            nextReview:
                DateTime.tryParse(json['nextReview'] ?? '') ?? DateTime.now(),
          );
        }).toList();

        print("✅ Lấy và parse thành công ${wordsList.length} đối tượng Word!");
        return wordsList;
      } else {
        print("❌ Lỗi từ server: ${data['message']}");
        return [];
      }
    } catch (e) {
      print("❌ Lỗi kết nối mạng tại getUserWords: $e");
      return [];
    }
  }
}
