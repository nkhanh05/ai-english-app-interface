import 'package:flutter/material.dart';
import 'shared_widgets/constants.dart';
import 'login_page.dart';
import '/service/UserService.dart'; // Import service của bạn

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // 1. Khai báo các Controller để lấy dữ liệu
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false; // Trạng thái loading khi đang gọi API

  // Hàm xử lý đăng ký
  Future<void> _handleRegister() async {
    // Validate cơ bản
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mật khẩu xác nhận không khớp!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // 2. Gọi UserService
    final result = await UserService().addNewStudent(
      _usernameController.text,
      _passwordController.text,
      _emailController.text,
      _fullNameController.text,
    );

    setState(() => _isLoading = false);

    if (result != null) {
      // Đăng ký thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đăng ký thành công! Hãy đăng nhập.")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } else {
      // Đăng ký thất bại
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đăng ký thất bại, vui lòng kiểm tra lại thông tin."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: backgroundDecoration,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: colorGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "SIGN UP",
                    style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Truyền controller vào từng ô
                  _buildInput("Username", _usernameController),
                  _buildInput("Email", _emailController),
                  _buildInput("Full Name", _fullNameController),
                  _buildInputWithToggle(
                    "Password",
                    _obscurePassword,
                    _passwordController,
                    () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  _buildInputWithToggle(
                    "Confirm Password",
                    _obscureConfirmPassword,
                    _confirmPasswordController,
                    () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    ),
                  ),

                  const SizedBox(height: 20),
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : ElevatedButton(
                          onPressed: _handleRegister, // Gọi hàm xử lý
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorOrange,
                          ),
                          child: const Text(
                            "Create Account",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Quay lại"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Cập nhật hàm _buildInput để nhận controller
  Widget _buildInput(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        TextField(
          controller: controller, // Gán controller
          decoration: InputDecoration(
            filled: true,
            fillColor: colorBeige,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildInputWithToggle(
    String label,
    bool obscure,
    TextEditingController controller,
    VoidCallback onToggle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        TextField(
          controller: controller, // Gán controller
          obscureText: obscure,
          decoration: InputDecoration(
            filled: true,
            fillColor: colorBeige,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
              onPressed: onToggle,
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
