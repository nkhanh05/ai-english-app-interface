import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:ai_english_application/classes/self-defined_classes.dart';
import 'data/notifier.dart';
import 'constants.dart';
import 'dataImport/api_services.dart'; // Thay bằng path thực tế của bạn
import 'dataImport/pronunciation.dart';
import 'scan_object_page.dart';
import 'my_library_page.dart';

class WordDetailPage extends StatelessWidget {
  final Word word;
  final Uint8List? imageData; // Dữ liệu ảnh đã được cắt và mã hóa
  const WordDetailPage({super.key, required this.word, this.imageData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildHeader(context),
      body: Container(
        width: double.infinity,
        decoration: backgroundDecoration,
        child: Column(
          children: [
            const SizedBox(height: 30),
            const Text(
              "Thông tin của từ",
              style: TextStyle(fontSize: 28, color: Colors.black87),
            ),
            const SizedBox(height: 20),

            // Hàng biểu tượng danh mục
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCategoryIcon(Icons.font_download, "TỪ"),
                _buildCategoryIcon(Icons.menu_book, "ĐỊNH NGHĨA"),
                _buildCategoryIcon(Icons.volume_up, "PHÁT ÂM"),
                _buildCategoryIcon(Icons.image, "HÌNH ẢNH"),
              ],
            ),

            // Khung nội dung chính hiển thị theo dạng bảng không viền
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 25,
                ),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: colorGreen.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cột TỪ
                    _buildTableColumn(
                      Text(
                        word.term,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Cột ĐỊNH NGHĨA
                    _buildTableColumn(
                      Text(
                        word.definition,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    // Cột PHÁT ÂM
                    _buildTableColumn(
                      IconButton(
                        icon: const Icon(
                          Icons.play_circle_fill,
                          color: Colors.white,
                          size: 35,
                        ),
                        onPressed: () {
                          // Gọi hàm phát âm ở đây (ví dụ: flutter_tts)
                          TTSService.speak(word.term);
                        },
                      ),
                    ),
                    // Cột HÌNH ẢNH
                    _buildTableColumn(
                      (imageData != null)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(imageData!),
                            )
                          : const Icon(
                              Icons.image_not_supported,
                              color: Colors.white70,
                            ),
                    ),
                  ],
                ),
              ),
            ),

            _buildActionButtons(context),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Widget hỗ trợ căn chỉnh cột cho bảng
  Widget _buildTableColumn(Widget child) {
    return Expanded(
      child: Container(
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: child,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        _bottomButton("Lưu từ vào thư viện của tôi", colorOrange, () async {
          // Gọi hàm addWord từ file DB của bạn

          await ApiService.addWordToLibrary(word, userID.value);
          debugPrint("API xong, chuẩn bị chuyển trang...");
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              // Truyền dữ liệu ảnh vào trang quét
              MaterialPageRoute(builder: (context) => const MyLibraryPage()),
            );
          }
        }),
        const SizedBox(height: 15),
        _bottomButton("Loại bỏ và quét vật thể mới", colorOrange, () {
          // Quay lại trang quét mà không lưu
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ScanObjectPage()),
          );
        }),
      ],
    );
  }

  // --- Các Widget phụ giữ nguyên từ code cũ của bạn ---
  PreferredSizeWidget _buildHeader(BuildContext context) {
    return AppBar(
      backgroundColor: colorTeal,
      elevation: 0,
      title: const Row(
        children: [
          Icon(Icons.local_fire_department, color: Colors.orange),
          SizedBox(width: 5),
          Text("5", style: TextStyle(color: Colors.white)),
          Spacer(),
          Icon(Icons.notifications, color: colorOrange),
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorGreen,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _bottomButton(String text, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
