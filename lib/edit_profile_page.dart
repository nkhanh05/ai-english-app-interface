import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import thư viện chọn ảnh
import '/models/user/Student.dart';
import '/service/StudentService.dart';
import '/service/ImageService.dart'; // Import hàm upload ảnh của bạn
import 'shared_widgets/constants.dart';

class EditProfilePage extends StatefulWidget {
  final Student student;

  const EditProfilePage({super.key, required this.student});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool isSaving = false;

  File? _selectedImage; 
  final ImagePicker _picker = ImagePicker();
  final ImageService _imageService = ImageService(); 

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student.fullName);
    _emailController = TextEditingController(text: "${widget.student.username}@gmail.com");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Mở thư viện để chọn ảnh
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _handleSave() async {
    setState(() => isSaving = true);

    String? currentAvatarUrl = widget.student.avatarUrl;

    // Nếu có chọn ảnh mới -> Gọi hàm upload lên Supabase
    if (_selectedImage != null) {
      final uploadedUrl = await _imageService.uploadImageToAzure(_selectedImage!, 'avatars');
      if (uploadedUrl != null) {
        currentAvatarUrl = uploadedUrl;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lỗi khi tải ảnh lên, vui lòng thử lại!"))
        );
        setState(() => isSaving = false);
        return;
      }
    }

    // Đẩy thông tin text và url ảnh mới cập nhật
    Map<String, dynamic> updateData = {
      "fullName": _nameController.text.trim(),
      "avatarUrl": currentAvatarUrl,
    };

    bool success = await StudentService.updateProfile(widget.student.userID, updateData);

    setState(() => isSaving = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cập nhật thành công!")));
      Navigator.pop(context, true); // Bắn true về trang Profile để báo hiệu cần Load lại dữ liệu
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lỗi khi cập nhật!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chỉnh sửa thông tin"), backgroundColor: colorTeal),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: backgroundDecoration,
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
                    // Nếu chọn ảnh mới -> hiện ảnh mới. Nếu không -> lấy link URL từ Web
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!) as ImageProvider
                        : (widget.student.avatarUrl?.isNotEmpty == true
                            ? NetworkImage(widget.student.avatarUrl!)
                            : null),
                    child: (_selectedImage == null && (widget.student.avatarUrl == null || widget.student.avatarUrl!.isEmpty))
                        ? const Icon(Icons.person, size: 50, color: Colors.white)
                        : null,
                  ),
                  Container(
                    decoration: const BoxDecoration(color: colorOrange, shape: BoxShape.circle),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      onPressed: _pickImage, // Gán sự kiện chọn ảnh
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              _buildEditField("Tên hiển thị", _nameController),
              _buildEditField("Email (Chỉ đọc)", _emailController, readOnly: true),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: isSaving ? null : _handleSave,
                style: ElevatedButton.styleFrom(backgroundColor: colorOrange, minimumSize: const Size(double.infinity, 50)),
                child: isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("LƯU THAY ĐỔI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditField(String label, TextEditingController controller, {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            readOnly: readOnly,
            decoration: InputDecoration(
              filled: true,
              fillColor: readOnly ? Colors.grey.shade300 : colorBeige,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }
}
