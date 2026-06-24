import 'package:flutter/material.dart';
import 'constants.dart';
import '../scan_object_page.dart';
import '../my_library_page.dart';
import '../leaderboard_page.dart';
import '../exercise_menu_page.dart';
import '../personal_profile.dart';
import '/state/global_state.dart';

class CustomEndDrawer extends StatelessWidget {
  const CustomEndDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: colorTeal),
            child: Center(
              child: Text(
                'Điều hướng',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Quét vật thể'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ScanObjectPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.library_books),
            title: const Text('Thư viện'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MyLibraryPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.emoji_events),
            title: const Text('Bảng xếp hạng'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LeaderboardPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.home_work),
            title: const Text('Trang chủ bài tập'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExerciseMenuPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text(
              'Trang cá nhân',
            ), // (1) Đổi tên lại cho khớp logic UX
            onTap: () {
              Navigator.pop(context); // Đóng Drawer (nếu đang ở trong Drawer)
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PersonalProfilePage(
                    student: currentStudentNotifier.value!,// (2) Bỏ const, thêm "student:"
                    isMe:true, // (3) Thêm isMe:true để biết đây là trang cá nhân của chính mình                  
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
