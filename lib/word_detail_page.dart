import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

// Các import của bạn (nhớ kiểm tra lại đường dẫn cho chuẩn)
import 'service/pronunciation.dart';
import 'shared_widgets/constants.dart';
import 'models/word/Word.dart';
import 'scan_object_page.dart';
import '/service/ImageService.dart'; // File ImageService bạn vừa tạo
import '/service/WordService.dart'; // File WordService của bạn
import 'state/global_state.dart'; // Import global state để lấy thông tin người dùng
import 'my_library_page.dart'; // Trang thư viện của tôi
import 'shared_widgets/shared_endDrawer.dart'; // Import Drawer tùy chỉnh
import 'shared_widgets/shared_appbar.dart';

class WordDetailPage extends StatefulWidget {
  final Word word;
  final Uint8List? imageData; // Dữ liệu ảnh đã được cắt và mã hóa

  const WordDetailPage({super.key, required this.word, this.imageData});

  @override
  State<WordDetailPage> createState() => _WordDetailPageState();
}

class _WordDetailPageState extends State<WordDetailPage> {
  // Biến quản lý trạng thái loading khi đang upload
  bool _isLoading = false;

  // Khởi tạo các Service
  final ImageService _imageService = ImageService();
  final WordService _wordService = WordService(); // Giả định tên class của bạn

  // --------------------------------------------------------
  // HÀM XỬ LÝ LƯU TỪ VÀO THƯ VIỆN
  // --------------------------------------------------------
  Future<void> _saveWordToLibrary() async {
    if (_isLoading) return; // Chặn bấm nhiều lần

    setState(() {
      _isLoading = true;
    });

    try {
      String? finalImageUrl;

      // 1. NẾU CÓ ẢNH -> UPLOAD LÊN AZURE TRƯỚC
      if (widget.imageData != null) {
        debugPrint("Đang tạo file tạm từ imageData...");
        // Tạo một file tạm trên thiết bị để chứa Uint8List
        final tempDir = await getTemporaryDirectory();
        File tempFile = await File(
          '${tempDir.path}/temp_word_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ).create();
        tempFile.writeAsBytesSync(widget.imageData!);

        debugPrint("Đang upload ảnh lên Azure...");
        // Gọi ImageService up lên thư mục 'wordImage'
        finalImageUrl = await _imageService.uploadImageToAzure(
          tempFile,
          "wordImage",
        );

        debugPrint("Link ảnh trả về: $finalImageUrl");
      }

      // 2. CẬP NHẬT LINK ẢNH VÀO OBJECT WORD
      Word wordToSave = widget.word;
      if (finalImageUrl != null) {
        // Giả sử class Word của bạn có thuộc tính imageUrl
        // Nếu không có, bạn cần thêm thuộc tính này vào model Word nhé!
        wordToSave.photoUrl = finalImageUrl;
      }

      // 3. GỌI WORDSERVICE ĐỂ LƯU VÀO DATABASE
      debugPrint("Đang lưu thông tin từ vựng vào Database...");
      // Giả sử bạn truyền object wordToSave vào hàm của WordService
      await _wordService.addWordToLibrary(
        wordToSave,
        currentStudentNotifier.value!.userID,
      ); // Lấy userID từ global state

      debugPrint("✅ Lưu thành công!");

      // 4. CHUYỂN TRANG SAU KHI THÀNH CÔNG
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã lưu từ vựng thành công!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyLibraryPage()),
        );
      }
    } catch (e) {
      debugPrint("❌ Lỗi khi lưu từ: $e");
      debugPrint("${currentStudentNotifier.value?.username}");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Đã xảy ra lỗi: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(showBackButton: false),
      endDrawer: const CustomEndDrawer(),
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
                        widget.word.term,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Cột ĐỊNH NGHĨA
                    _buildTableColumn(
                      Text(
                        widget.word.definition,
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
                          TTSService.speak(widget.word.term);
                        },
                      ),
                    ),
                    // Cột HÌNH ẢNH
                    _buildTableColumn(
                      (widget.imageData != null)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(widget.imageData!),
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
        // Nút Lưu từ (Tích hợp hiệu ứng Loading)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: ElevatedButton(
            onPressed: _isLoading
                ? null
                : _saveWordToLibrary, // Khóa nút khi đang tải
            style: ElevatedButton.styleFrom(
              backgroundColor: colorOrange,
              disabledBackgroundColor: Colors.grey, // Màu khi bị khóa
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 25,
                    width: 25,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : const Text(
                    "Lưu từ vào thư viện của tôi",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
          ),
        ),
        const SizedBox(height: 15),

        // Nút Loại bỏ
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
