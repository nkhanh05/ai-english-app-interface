import 'package:flutter/material.dart';
import 'constants.dart';
import 'login_page.dart';
import 'edit_profile_page.dart'; // Import trang chỉnh sửa

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- 1. HEADER CÓ NÚT TRỞ VỀ ---
      appBar: AppBar(
        backgroundColor: colorTeal,
        elevation: 0,
        // Thêm nút mũi tên quay lại ở góc trái
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: const [
            Icon(Icons.local_fire_department, color: Colors.orange),
            SizedBox(width: 5),
            Text("5", style: TextStyle(color: Colors.white, fontSize: 18)),
            Spacer(),
            Icon(Icons.notifications, color: colorOrange),
          ],
        ),
      ),
      
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: backgroundDecoration,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- NHÓM 1: THÔNG TIN CỦA TÔI ---
              const Text(
                "Thông tin của tôi", 
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorGreen, 
                  borderRadius: BorderRadius.circular(15)
                ),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Tên: Nguyễn Văn A", style: TextStyle(color: Colors.white, fontSize: 16)),
                        SizedBox(height: 8),
                        Text("Email: admin@gmail.com", style: TextStyle(color: Colors.white, fontSize: 16)),
                        SizedBox(height: 40), // Khoảng trống cho nút bên dưới
                      ],
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: ElevatedButton(
                        onPressed: () {
                          // Chuyển sang trang chỉnh sửa thông tin
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const EditProfilePage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorOrange,
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                          minimumSize: Size.zero,
                        ),
                        child: const Text(
                          "Chỉnh sửa", 
                          style: TextStyle(color: Colors.white, fontSize: 12)
                        ),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // --- NHÓM 2: CÀI ĐẶT THÔNG BÁO ---
              const Text(
                "Cài đặt thông báo", 
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorGreen, 
                  borderRadius: BorderRadius.circular(15)
                ),
                child: Column(
                  children: [
                    _buildSwitchOption("Nhắc nhở học tập", true),
                    _buildSwitchOption("Thông báo từ vựng mới", false),
                    const Divider(color: Colors.white38),
                    const Text(
                      "Tần suất: 2 lần / ngày",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // --- NHÓM 3: HỆ THỐNG ---
              _buildSystemButton(
                context, 
                "ĐĂNG XUẤT", 
                () => _handleLogout(context)
              ),
              const SizedBox(height: 15),
              _buildSystemButton(
                context, 
                "XÓA TÀI KHOẢN", 
                () => _showDeleteDialog(context)
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget tạo nút gạt On/Off
  Widget _buildSwitchOption(String title, bool value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
        Switch(
          value: value, 
          onChanged: (v) {}, 
          activeColor: colorOrange
        ),
      ],
    );
  }

  // Widget tạo nút hệ thống (Đăng xuất/Xóa)
  Widget _buildSystemButton(BuildContext context, String text, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: colorOrange,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        text, 
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
      ),
    );
  }

  // Logic Đăng xuất
  void _handleLogout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context, 
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false, // Xóa hết lịch sử để không quay lại được app khi đã logout
    );
  }

  // Logic Xóa tài khoản
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Hành động này không thể hoàn tác. Bạn có chắc chắn muốn xóa tài khoản?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("HỦY")),
          TextButton(
            onPressed: () => Navigator.pop(c), 
            child: const Text("XÓA", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }
}