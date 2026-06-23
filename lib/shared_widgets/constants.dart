import 'package:flutter/material.dart';

const Color colorTeal = Color(0xFF6A9C9B);
const Color colorOrange = Color(0xFFD28B6D); // Màu nhấn mạnh
const Color colorBeige = Color(0xFFF1E6D2); // Màu nền chính
const Color colorGreen = Color(0xFFB6C4A6);
const Color colorNavy = Color.fromARGB(
  255,
  62,
  108,
  179,
); // Đổi navy sang tone pastel/trầm cho sang trọng

// THÊM: Màu chữ không đen tuyền/trắng tuyền
const Color colorBrownText = Color(0xFF5D4037); // Nâu pastel đậm cho nền beige
const Color colorLightText = Color(0xFFFDFBF7); // Trắng ngà pastel cho nền đậm

// Đổi background thành màu trơn, bỏ ảnh rối mắt
const backgroundDecoration = BoxDecoration(color: colorBeige);

PreferredSizeWidget _buildHeader(BuildContext context) {
  return AppBar(
    backgroundColor: colorTeal,
    elevation: 0,
    title: const Row(
      children: [
        Icon(Icons.local_fire_department, color: colorOrange),
        Spacer(),
        Icon(Icons.menu, color: colorOrange),
      ],
    ),
  );
}
