import 'package:flutter/material.dart';
import '/models/user/Student.dart';
import '/service/StudentService.dart';
import 'shared_widgets/constants.dart'; // Đảm bảo import file màu sắc của bạn

class EditProfilePage extends StatefulWidget {
  final Student student;

  const EditProfilePage({super.key, required this.student});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController
  _emailController; // Có thể bỏ nếu DB không hỗ trợ đổi Email
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student.fullName);
    _emailController = TextEditingController(
      text: "${widget.student.username}@gmail.com",
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => isSaving = true);

    // Chuẩn bị dữ liệu gửi lên Node.js
    Map<String, dynamic> updateData = {"fullName": _nameController.text.trim()};

    bool success = await StudentService.updateProfile(
      widget.student.userID,
      updateData,
    );

    setState(() => isSaving = false);

    if (success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Cập nhật thành công!")));
      Navigator.pop(context); // Trở về trang Profile
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lỗi khi cập nhật!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chỉnh sửa thông tin"),
        backgroundColor: colorTeal,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: backgroundDecoration, // Từ file constants.dart
        padding: const EdgeInsets.all(25),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: colorGreen,
                    backgroundImage:
                        widget.student.avatarUrl?.isNotEmpty == true
                        ? NetworkImage(widget.student.avatarUrl!)
                        : null,
                    child: widget.student.avatarUrl?.isEmpty ?? true
                        ? const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      color: colorOrange,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        // TODO: Tích hợp thư viện image_picker để đổi ảnh
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              _buildEditField("Tên hiển thị", _nameController),
              _buildEditField("Email", _emailController),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: isSaving ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorOrange,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "LƯU THAY ĐỔI",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: colorBeige,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
