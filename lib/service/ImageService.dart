import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';

class ImageService {
  // Tên bucket bạn vừa tạo trên Supabase
  final String _bucketName = "images";

  // Vẫn giữ tên hàm cũ để code Flutter hiện tại không bị lỗi (dù đang dùng Supabase 😁)
  Future<String?> uploadImageToAzure(File imageFile, String folderName) async {
    try {
      // 1. Tạo tên file duy nhất (VD: wordImage/1678888_anh.jpg)
      String fileName =
          "$folderName/${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}";

      // 2. Upload thẳng lên Supabase Storage
      await Supabase.instance.client.storage
          .from(_bucketName)
          .upload(fileName, imageFile);

      // 3. Lấy Public URL để lưu vào Database
      String publicUrl = Supabase.instance.client.storage
          .from(_bucketName)
          .getPublicUrl(fileName);

      print("✅ Upload ảnh thành công: $publicUrl");
      return publicUrl;
    } catch (e) {
      print("❌ Lỗi upload ảnh lên Supabase: $e");
      return null;
    }
  }
}
