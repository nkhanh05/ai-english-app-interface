import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class ImageService {
  // --------------------------------------------------------
  // CẤU HÌNH AZURE
  // --------------------------------------------------------
  final String _accountName = "namkhanh060905";
  final String _containerName = "images";

  // Token dùng tạm để test (Sau này sẽ xóa đi)
  final String _testSasToken =
      "sp=rw&st=2026-06-19T10:26:12Z&se=2027-06-19T18:41:12Z&spr=https&sv=2026-02-06&sr=c&sig=jaYZM83mkQWs2nZikwqAzUUSpiA8nmjyNysgstM2Lns%3D";

  // --------------------------------------------------------
  // HÀM UPLOAD CHÍNH
  // --------------------------------------------------------
  /// Hàm upload ảnh lên Azure.
  /// Trả về chuỗi URL (nếu thành công) hoặc null (nếu thất bại).
  /// [imageFile]: File ảnh được chọn từ ImagePicker
  /// [folderName]: Tên thư mục ảo trên Azure (vd: 'avatarImage' hoặc 'wordImage')
  Future<String?> uploadImageToAzure(File imageFile, String folderName) async {
    try {
      // 1. Lấy SAS Token
      // TODO (Giai đoạn 2): Viết hàm gọi API NodeJS ở đây để lấy token mới
      // String currentSasToken = await fetchSasTokenFromApi();
      String currentSasToken = _testSasToken;

      // 2. Định dạng tên file (Thư mục + Thời gian + Tên file gốc)
      // Ví dụ: avatarImage/1678888_anh.jpg
      String fileName =
          "$folderName/${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}";

      // 3. Tạo URL upload (URL gốc + SAS Token)
      String blobUrl =
          "https://$_accountName.blob.core.windows.net/$_containerName/$fileName?$currentSasToken";

      // 4. Chuyển file ảnh thành byte
      List<int> imageBytes = await imageFile.readAsBytes();

      // 5. Bắn HTTP PUT request lên Azure
      var response = await http.put(
        Uri.parse(blobUrl),
        headers: {
          'x-ms-blob-type': 'BlockBlob', // Header bắt buộc của Azure
          'Content-Type': 'image/jpeg', // Header định dạng file
        },
        body: imageBytes,
      );

      // 6. Kiểm tra kết quả
      if (response.statusCode == 201) {
        // Upload thành công, trả về link ảnh sạch (không có token) để lưu vào Database
        String cleanUrl =
            "https://$_accountName.blob.core.windows.net/$_containerName/$fileName";
        return cleanUrl;
      } else {
        print("❌ Lỗi Azure: Code ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Lỗi Exception khi upload: $e");
      return null;
    }
  }
}
