import 'package:flutter/material.dart';
import 'constants.dart'; // Chứa các biến màu và backgroundDecoration
import 'register_page.dart';
import 'scan_object_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Trạng thái để ẩn hoặc hiện mật khẩu
  bool _isPasswordObscured = true;

  // Controller để lấy dữ liệu (nếu cần xử lý logic sau này)
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Chế độ này giúp màn hình không bị đẩy lên lỗi khi hiện bàn phím
      resizeToAvoidBottomInset: true, 
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: backgroundDecoration, // Hình nền pattern lặp lại
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: colorGreen, // Màu xanh nhạt của khung chính
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Đăng nhập",
                    style: TextStyle(
                      fontSize: 35, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- Ô NHẬP EMAIL ---
                  _buildLabel("Email"),
                  TextField(
                    controller: _emailController,
                    decoration: _inputDecoration(hint: "Nhập email của bạn"),
                  ),
                  const SizedBox(height: 15),

                  // --- Ô NHẬP MẬT KHẨU CÓ NÚT ẨN/HIỆN ---
                  _buildLabel("Mật khẩu"),
                  TextField(
                    controller: _passwordController,
                    obscureText: _isPasswordObscured, // Biến điều khiển ẩn/hiện
                    decoration: _inputDecoration(
                      hint: "Nhập mật khẩu",
                      // Nút con mắt ở cuối ô
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordObscured 
                              ? Icons.visibility_off 
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordObscured = !_isPasswordObscured;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // --- NÚT ĐĂNG NHẬP ---
                  ElevatedButton(
                    onPressed: () {
                      // Chuyển thẳng vào trang quét vật thể
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const ScanObjectPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorOrange, // Màu cam chuẩn
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Đăng nhập",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),

                  const SizedBox(height: 15),
                  const Text("Bạn chưa có tài khoản?", style: TextStyle(color: Colors.black54)),

                  // --- NÚT CHUYỂN SANG ĐĂNG KÝ ---
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterPage()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: colorOrange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "Đăng kí ở đây",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Hàm hỗ trợ vẽ Label phía trên ô nhập
  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 10, bottom: 5),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
    );
  }

  // Hàm hỗ trợ định dạng (Style) cho tất cả các ô nhập liệu
  InputDecoration _inputDecoration({required String hint, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: colorBeige, // Màu kem
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
    );
  }
}