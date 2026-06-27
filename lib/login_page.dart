import 'package:flutter/material.dart';
import 'shared_widgets/constants.dart';
import 'register_page.dart';
import 'models/user/Student.dart'; // Import model User của bạn
import 'service/UserService.dart';
import 'models/user/Admin.dart'; // Import model Admin của bạn
import 'scan_object_page.dart'; // Import trang quét vật thể
import 'state/global_state.dart'; // Import global state để lưu thông tin người dùng
import 'admin_dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordObscured = true;
  bool _isLoading = false; // Biến trạng thái để tạo hiệu ứng loading

  // Controller để lấy dữ liệu người dùng nhập
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Khởi tạo UserService để gọi API
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: backgroundDecoration, // Lấy từ file constants.dart
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: colorGreen, // Lấy từ file constants.dart
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

                  // --- Ô NHẬP USERNAME ---
                  _buildLabel("Tên đăng nhập"),
                  TextField(
                    controller: _usernameController,
                    decoration: _inputDecoration(
                      hint: "Nhập tên đăng nhập của bạn",
                    ),
                  ),
                  const SizedBox(height: 15),

                  // --- Ô NHẬP MẬT KHẨU ---
                  _buildLabel("Mật khẩu"),
                  TextField(
                    controller: _passwordController,
                    obscureText: _isPasswordObscured,
                    decoration: _inputDecoration(
                      hint: "Nhập mật khẩu",
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

                  // --- NÚT ĐĂNG NHẬP (TEST KẾT NỐI DATABASE) ---
                  ElevatedButton(
                    // Nếu đang loading thì vô hiệu hóa nút
                    onPressed: _isLoading
                        ? null
                        : () async {
                            // 1. Kiểm tra không được để trống
                            if (_usernameController.text.isEmpty ||
                                _passwordController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Vui lòng nhập đủ thông tin!'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }

                            // 2. Bật trạng thái loading (hiện vòng xoay)
                            setState(() {
                              _isLoading = true;
                            });

                            // 3. Gọi hàm checkLogin từ UserService
                            final user = await _userService.checkLogin(
                              _usernameController.text.trim(),
                              _passwordController.text.trim(),
                            );

                            // 4. Tắt trạng thái loading sau khi API trả kết quả
                            if (mounted) {
                              setState(() {
                                _isLoading = false;
                              });

                              // =========================================================
                              // XỬ LÝ ĐIỀU HƯỚNG PHÂN QUYỀN NGAY TẠI ĐÂY
                              // =========================================================
                              if (user != null) {
                                // Đăng nhập thành công
                                if (user is Student) {
                                  currentStudentNotifier.value = user;
                                  print(
                                    "Đăng nhập với vai trò: Học sinh (${user.fullName})",
                                  );
                                  print(
                                    "Chuỗi Streak hiện tại: ${user.streak}",
                                  );

                                  // Chuyển hướng sang màn hình của Học sinh (Ví dụ: StudentMainPage)
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ScanObjectPage(),
                                    ),
                                  );
                                } else if (user is Admin) {
                                  currentAdminNotifier.value = user;
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AdminDashboard(),
                                    ),
                                  );

                                  // Chuyển hướng sang màn hình của Admin (Ví dụ: AdminDashboardPage)
                                }
                              } else {
                                // Đăng nhập thất bại (user == null)
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Sai tên đăng nhập hoặc mật khẩu!',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorOrange, // Lấy từ constants.dart
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    // Đổi giao diện nút khi đang loading
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Đăng nhập",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                  ),

                  const SizedBox(height: 15),
                  const Text(
                    "Bạn chưa có tài khoản?",
                    style: TextStyle(color: Colors.black54),
                  ),

                  // --- NÚT CHUYỂN SANG TRANG ĐĂNG KÝ ---
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: colorOrange, // Lấy từ constants.dart
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

  // --- HÀM PHỤ TRỢ XÂY DỰNG GIAO DIỆN ---

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 10, bottom: 5),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
  //
  //
  //

  InputDecoration _inputDecoration({required String hint, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: colorBeige, // Lấy từ constants.dart
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
    );
  }
}
