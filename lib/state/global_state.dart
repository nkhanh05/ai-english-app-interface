import 'package:flutter/material.dart';
import '../models/user/Student.dart'; // Import model Student của bạn
import '../models/user/Admin.dart'; // Import UserService để gọi API

// Tạo một Notifier toàn cục. Ban đầu chưa đăng nhập nên giá trị là null
final ValueNotifier<Student?> currentStudentNotifier = ValueNotifier<Student?>(
  null,
);
final ValueNotifier<Admin?> currentAdminNotifier = ValueNotifier<Admin?>(null);
