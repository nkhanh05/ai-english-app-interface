import 'package:flutter/material.dart';
import 'login_page.dart'; // Import trang đăng nhập để làm trang chủ
// Import lớp kết nối SQL để khởi tạo ngay khi app chạy

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Tắt biểu tượng "Debug" ở góc màn hình
      debugShowCheckedModeBanner: false,

      title: 'English App',

      theme: ThemeData(
        fontFamily: 'Roboto', // Sử dụng font chữ bạn mong muốn
        primarySwatch: Colors.teal,
        useMaterial3: true, // Bật Material 3 để giao diện trông hiện đại hơn
      ),

      // home: quy định trang web/app sẽ mở ra đầu tiên.
      // Ở đây chúng ta chọn LoginPage.
      home: const LoginPage(),
    );
  }
}
