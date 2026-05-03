import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Hàm nhận vào dữ liệu ảnh ĐÃ LÀ ĐỊNH DẠNG JPEG (Uint8List)
  /// Đẩy lên Firebase và trả về đường link ảnh
  Future<String?> uploadObjectPhoto(Uint8List jpegPhoto) async {
    try {
      // 1. Tạo tên file duy nhất (không chia folder theo ý bạn)
      String fileName =
          'objects/ai_english_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // 2. Trỏ đến vị trí lưu trữ trên Firebase Storage
      Reference ref = _storage.ref().child(fileName);

      // 3. Thiết lập Content Type là image/jpeg để các trình duyệt mở được trực tiếp
      SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'picked-by': 'Student', // Bạn có thể thêm meta để biết ai up
          'project': 'AI-english-App',
        },
      );

      debugPrint("Đang đẩy ảnh JPEG lên database...");

      // 4. Đẩy dữ liệu lên bằng phương thức putData
      // Lưu ý: putData cực kỳ nhanh vì nó xử lý trực tiếp mảng byte trong bộ nhớ
      UploadTask uploadTask = ref.putData(jpegPhoto, metadata);

      // Đợi quá trình tải lên hoàn tất
      TaskSnapshot snapshot = await uploadTask;

      // 5. Lấy URL công khai để trả về
      String downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint("Tải lên thành công!");
      return downloadUrl;
    } catch (e) {
      debugPrint("Lỗi khi đẩy ảnh lên Firebase: $e");
      return null;
    }
  }
}
