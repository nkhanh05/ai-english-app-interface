import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'BaseApi.dart';
// Đảm bảo đường dẫn import phù hợp với cấu trúc thư mục của bạn
import '../models/word/Word.dart';
import '../models/exercise/Exercise.dart';

class ExerciseService {
  static String baseUrl = BaseApi.url;
  // ====================================================================
  // 1. LẤY DANH SÁCH TỪ VỰNG CẦN ÔN TẬP DỰA TRÊN THUẬT TOÁN SM-2
  // ====================================================================
  static Future<List<Word>> getWordsToRevise(int userID) async {
    final url = Uri.parse('$baseUrl/api/exercise/revise/$userID');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        return data.map((json) {
          return Word(
            id: json['id'] is int
                ? json['id']
                : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
            term: json['term']?.toString() ?? '',
            definition: json['definition']?.toString() ?? '',
            photoUrl: json['photoUrl']?.toString(),

            // Xử lý an toàn các hệ số của SM-2
            ef: (json['ef'] is num)
                ? (json['ef'] as num).toDouble()
                : double.tryParse(json['ef']?.toString() ?? '2.5') ?? 2.5,

            reviewInterval: json['reviewInterval'] is int
                ? json['reviewInterval']
                : int.tryParse(json['reviewInterval']?.toString() ?? '1') ?? 1,

            numberCorrect: json['numberCorrect'] is int
                ? json['numberCorrect']
                : int.tryParse(json['numberCorrect']?.toString() ?? '0') ?? 0,

            // Xử lý an toàn ngày tháng
            nextReview:
                DateTime.tryParse(json['nextReview'] ?? '') ?? DateTime.now(),
            lastReview:
                DateTime.tryParse(json['lastReview'] ?? '') ?? DateTime.now(),
          );
        }).toList();
      } else {
        debugPrint("❌ Lỗi API GetWordsToRevise: Code ${response.statusCode}");
        return [];
      }
    } catch (e) {
      debugPrint("❌ Lỗi kết nối mạng tại getWordsToRevise: $e");
      return [];
    }
  }

  // ====================================================================
  // 2. LƯU KẾT QUẢ BÀI TẬP VÀ CẬP NHẬT THÔNG SỐ SM-2 LÊN SERVER
  // ====================================================================
  static Future<bool> saveExerciseResult(Exercise exercise, int userID) async {
    final url = Uri.parse('$baseUrl/api/exercise/saveResult');

    try {
      // Chuẩn bị danh sách payload cho từng từ vựng đã được làm
      final List<Map<String, dynamic>>
      wordsPayload = exercise.wordsToRevise.map((w) {
        return {
          'id': w.id, // ID của bảng Word
          'ef': w.ef,
          'reviewInterval': w.reviewInterval,

          // Chuyển DateTime thành chuỗi chuẩn ISO 8601 (VD: "2026-06-20T12:00:00.000")
          'nextReview': w.nextReview.toIso8601String(),
          'lastReview': w.lastReview.toIso8601String(),

          'numberCorrect': w.numberCorrect,

          // Cờ logic cho bảng ExerciseDetail ('true' hoặc 'false')
          // Nếu ef tăng hoặc numberCorrect > 1 (tùy thuộc vào cách hàm submitAnswer xử lý) thì là đúng
          'isCorrect': _determineIfCorrect(w),
        };
      }).toList();

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userID': userID,
          'type': exercise.exerciseType,
          'totalCorrect': exercise.nCorrectAnswer,
          'totalIncorrect': exercise.nIncorrectAnswer,
          'words': wordsPayload,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ Đã lưu kết quả bài tập (Transaction) thành công!");
        return true;
      } else {
        debugPrint(
          "❌ Lỗi API lưu kết quả bài tập: Code ${response.statusCode}",
        );
        debugPrint("Chi tiết từ server: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Lỗi kết nối mạng tại saveExerciseResult: $e");
      return false;
    }
  }

  // --- Hàm hỗ trợ nội bộ ---

  /// Xác định xem câu trả lời của từ vựng này là Đúng hay Sai để lưu vào ExerciseDetail.
  /// Trong thuật toán SM-2 của bạn, trả lời sai thường sẽ reset numberCorrect về 1.
  static bool _determineIfCorrect(Word word) {
    // Nếu bạn có thuộc tính 'isCorrect' riêng trong quá trình làm bài thì sử dụng nó.
    // Nếu không, ta có thể dựa vào numberCorrect. (Tùy chỉnh lại logic này nếu cần).
    if (word.numberCorrect > 1) {
      return true;
    } else if (word.numberCorrect == 1 && word.reviewInterval > 1) {
      // Trường hợp vừa trả lời sai làm tụt streak
      return false;
    }
    return true; // Mặc định
  }
}
