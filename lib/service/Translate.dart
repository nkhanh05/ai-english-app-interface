import 'package:http/http.dart' as http;
import 'dart:convert';

class TranslationService {
  static Future<String> translateEnToVi(String text) async {
    if (text.isEmpty) return "";
    
    // API dịch miễn phí
    final url = Uri.parse(
      "https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=vi&dt=t&q=${Uri.encodeComponent(text)}"
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // Cấu trúc trả về của Google khá loằng ngoằng, phải lấy đúng vị trí này:
        var data = jsonDecode(response.body);
        return data[0][0][0]; // Đây là nghĩa tiếng Việt
      }
    } catch (e) {
      print("Lỗi dịch thuật: $e");
    }
    return ""; // Thất bại thì trả về rỗng
  }
}