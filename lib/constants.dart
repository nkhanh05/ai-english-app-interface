import 'package:flutter/material.dart';

const Color colorTeal = Color(0xFF6A9C9B);
const Color colorOrange = Color(0xFFD28B6D);
const Color colorBeige = Color(0xFFF1E6D2);
const Color colorGreen = Color(0xFFB6C4A6);
const Color colorNavy = Color(0xFF0D47A1); // Màu xanh nước biển đậm mới

const backgroundDecoration = BoxDecoration(
  image: DecorationImage(
    image: AssetImage('assets/images/background.jpg'),
    fit: BoxFit.none,
    repeat: ImageRepeat.repeat,
  ),
);

PreferredSizeWidget _buildHeader(BuildContext context) {
    return AppBar(
      backgroundColor: colorTeal,
      elevation: 0,
      title: const Row(
        children: [
          Icon(Icons.local_fire_department, color: Colors.orange),
          Spacer(),
          Icon(Icons.menu, color: colorOrange),
        ],
      ),
    );
  }