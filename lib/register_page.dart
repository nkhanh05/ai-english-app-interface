import 'package:flutter/material.dart';
import 'constants.dart';
import 'scan_object_page.dart';

// --- TRANG ĐĂNG KÝ ---
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Trạng thái ẩn/hiện mật khẩu cho 2 ô riêng biệt
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
              decoration: BoxDecoration(color: colorGreen, borderRadius: BorderRadius.circular(20)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("SIGN UP", style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  
                  // Các ô nhập liệu bình thường
                  _buildInput("Username"),
                  _buildInput("Email"),
                  
                  // --- Ô MẬT KHẨU CÓ CHỨC NĂNG ẨN/HIỆN ---
                  _buildInputWithToggle(
                    label: "Password",
                    obscureText: _obscurePassword,
                    onToggle: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  
                  // --- Ô NHẬP LẠI MẬT KHẨU (Crucial new line) ---
                  _buildInputWithToggle(
                    label: "Confirm Password",
                    obscureText: _obscureConfirmPassword,
                    onToggle: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),

                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ScanObjectPage())),
                    style: ElevatedButton.styleFrom(backgroundColor: colorOrange),
                    child: const Text("Create Account", style: TextStyle(color: Colors.white)),
                  ),
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text("Quay lại")),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        TextField(decoration: InputDecoration(filled: true, fillColor: colorBeige, border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none))),
        const SizedBox(height: 10),
      ],
    );
  }

  // --- Widget hỗ trợ tạo ô mật khẩu có thể ẩn/hiện ---
  Widget _buildInputWithToggle({
    required String label,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        TextField(
          obscureText: obscureText, // Quản lý ẩn/hiện
          decoration: InputDecoration(
            filled: true,
            fillColor: colorBeige,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
            // Nút con mắt ở góc phải
            suffixIcon: IconButton(
              icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
              onPressed: onToggle,
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}