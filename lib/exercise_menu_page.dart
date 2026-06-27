import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Bắt buộc import thư viện này

import '/shared_widgets/constants.dart';
// Thay đổi đường dẫn import bên dưới cho khớp với project của bạn
import '../service/ExerciseService.dart';
import '/models/exercise/Exercise.dart';
import '../models/word/Word.dart';
import '../state/global_state.dart'; // Để lấy currentStudentNotifier.value.userID
import 'ExerciseContainerPage.dart';
import '/shared_widgets/shared_appbar.dart';
import '/shared_widgets/shared_endDrawer.dart';

class ExerciseMenuPage extends StatelessWidget {
  const ExerciseMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(showBackButton: true), // AppBar dùng chung
      endDrawer: const CustomEndDrawer(),
      body: Container(
        width: double.infinity,
        decoration: backgroundDecoration,
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text(
              "ÔN LUYỆN TỪ MỚI",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  // Gắn sự kiện và map đúng Type cho từng nút
                  _buildMenuButton(context, "TRẮC NGHIỆM", "MultipleChoice"),
                  _buildMenuButton(context, "NỐI HÌNH", "Matching"),
                  _buildMenuButton(context, "ĐIỀN TỪ", "GapFill"),
                  _buildMenuButton(context, "HỖN HỢP", "Mixed"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Chuyển nút thành InkWell/GestureDetector để bắt sự kiện Tap
  Widget _buildMenuButton(
    BuildContext context,
    String title,
    String exerciseType,
  ) {
    return InkWell(
      onTap: () => _startExercise(context, exerciseType),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: colorOrange,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 4),
              blurRadius: 5,
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _startExercise(BuildContext context, String exerciseType) async {
    // 1. Hiển thị màn hình Loading (Dialog không thể bấm tắt ngang)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          color: Colors.white,

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: colorOrange),
              SizedBox(height: 20),
              Text(
                "Đang tạo bài tập\nVui lòng đợi...",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorTeal,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // 2. Lấy userID hiện tại (Xử lý an toàn nếu chưa đăng nhập)
      int userID = currentStudentNotifier.value?.userID ?? 0;

      // 3. Gọi API lấy danh sách từ vựng từ Azure
      List<Word> wordsToRevise = await ExerciseService.getWordsToRevise(userID);

      // Kiểm tra xem context có còn tồn tại không sau khi chạy async (Luật an toàn của Flutter)
      if (!context.mounted) return;

      if (wordsToRevise.isEmpty) {
        Navigator.pop(context); // Tắt Dialog loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Chúc mừng! Bạn không có từ nào cần ôn tập lúc này."),
          ),
        );
        return;
      }

      // 4. PRE-CACHE HÌNH ẢNH: Tải ngầm tất cả ảnh vào bộ nhớ máy
      for (var word in wordsToRevise) {
        if (word.photoUrl != null && word.photoUrl!.isNotEmpty) {
          // Hàm này ép Flutter tải ảnh từ link và ném thẳng vào CachedNetworkImageProvider
          await precacheImage(
            CachedNetworkImageProvider(word.photoUrl!),
            context,
          );
        }
      }

      // Kiểm tra lại context một lần nữa trước khi chuyển trang
      if (!context.mounted) return;

      // 5. Khởi tạo phiên làm bài tập
      Exercise session = Exercise(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        exerciseType: exerciseType,
        wordsToRevise: wordsToRevise,
      );

      // 6. Đóng Loading Dialog và Chuyển hướng sang trang Container
      Navigator.pop(context); // Đóng Loading
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ExerciseContainerPage(exerciseSession: session),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Tắt Dialog
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi tải dữ liệu: $e")));
    }
  }
}
