import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'shared_widgets/constants.dart';
import '/models/word/Word.dart';
import '/state/global_state.dart';
import '/service/WordService.dart';
import '/service/ImageService.dart';
import '/service/pronunciation.dart';
import 'shared_widgets/shared_endDrawer.dart';
import 'shared_widgets/shared_appbar.dart';

class MyLibraryPage extends StatefulWidget {
  const MyLibraryPage({super.key});

  @override
  State<MyLibraryPage> createState() => _MyLibraryPageState();
}

class _MyLibraryPageState extends State<MyLibraryPage> {
  ValueNotifier<List<Word>> myWords = ValueNotifier<List<Word>>([]);
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWordsFromApi();
  }

  Future<void> _loadWordsFromApi() async {
    try {
      final currentStudent = currentStudentNotifier.value;

      if (currentStudent == null) {
        print("❌ Chưa đăng nhập, không thể lấy từ vựng!");
        if (mounted) setState(() => isLoading = false);
        return;
      }

      final wordService = WordService();
      List<Word> wordsList = await wordService.getUserWords(
        currentStudent.userID,
      );

      myWords.value = wordsList;
    } catch (e) {
      print("❌ Lỗi tải từ vựng tại UI: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // --- HÀM MỞ HỘP THOẠI THÊM/SỬA TỪ ---
  void _openWordDialog(Word? word) async {
    final result = await showDialog(
      context: context,
      barrierDismissible: false, // Bắt buộc bấm Hủy/Lưu để thoát
      builder: (context) => WordFormDialog(word: word),
    );

    // Nếu hộp thoại trả về true (đã lưu/xóa thành công), load lại danh sách
    if (result == true) {
      if (mounted) setState(() => isLoading = true);
      _loadWordsFromApi();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(showBackButton: false),
      endDrawer: const CustomEndDrawer(),
      // Nút dấu cộng thêm từ mới
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openWordDialog(null), // null = Chế độ Thêm mới
        backgroundColor: colorOrange,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      body: Container(
        width: double.infinity,
        decoration: backgroundDecoration,
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "THƯ VIỆN CỦA TÔI",
              style: TextStyle(
                fontSize: 44,
                color: Color(0xFF800000),
                fontWeight: FontWeight.bold,
              ),
            ),

            // Dòng hướng dẫn mờ
            const Text(
              "(Chạm vào thẻ từ vựng để sửa hoặc xóa)",
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),

            const SizedBox(height: 20),

            // THANH HEADER GỐC (GIỮ NGUYÊN)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.center,
                        child: _icon(Icons.font_download),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.center,
                        child: _icon(Icons.menu_book),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(child: _icon(Icons.volume_up)),
                    ),
                    Expanded(flex: 2, child: Center(child: _icon(Icons.image))),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: colorOrange),
                    )
                  : ValueListenableBuilder<List<Word>>(
                      valueListenable: myWords,
                      builder: (context, value, child) {
                        if (value.isEmpty) {
                          return const Center(
                            child: Text(
                              "Bạn chưa có từ vựng nào!",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }
                        return _wordList(value);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _wordList(List<Word> words) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80), // Chừa chỗ cho FAB
      itemCount: words.length,
      itemBuilder: (BuildContext c, int i) {
        final word = words[i];

        return Card(
          color: colorGreen,
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
          child: InkWell(
            onTap: () => _openWordDialog(word), // Mở form Edit khi bấm vào Card
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              // THANH NỘI DUNG GỐC (GIỮ NGUYÊN TỈ LỆ VÀ CĂN LỀ 100%)
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Text(
                        word.term,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Text(
                        word.definition,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () {
                        TTSService.speak(
                          word.term,
                        ); // Icon loa vẫn bấm được bình thường
                      },
                      child: Center(child: _icon(Icons.volume_up)),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child:
                            (word.photoUrl != null &&
                                word.photoUrl!.isNotEmpty &&
                                word.photoUrl != 'ha')
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Image.network(
                                  word.photoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _fallbackImage(),
                                ),
                              )
                            : _fallbackImage(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _fallbackImage() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(5),
      ),
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }

  Widget _icon(IconData icon) => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: colorGreen,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(icon, color: Colors.white),
  );
}

// =========================================================================
// WIDGET HỘP THOẠI (DIALOG) CHỨA FORM THÊM/SỬA
// =========================================================================
class WordFormDialog extends StatefulWidget {
  final Word? word; // Nếu null là Thêm mới, nếu có data là Sửa

  const WordFormDialog({super.key, this.word});

  @override
  State<WordFormDialog> createState() => _WordFormDialogState();
}

class _WordFormDialogState extends State<WordFormDialog> {
  late TextEditingController termController;
  late TextEditingController defController;
  File? _selectedImageLocal;
  final ImagePicker _picker = ImagePicker();
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    termController = TextEditingController(text: widget.word?.term ?? '');
    defController = TextEditingController(text: widget.word?.definition ?? '');
  }

  @override
  void dispose() {
    termController.dispose();
    defController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImageLocal = File(pickedFile.path);
      });
    }
  }

  Future<void> _handleSave() async {
    final term = termController.text.trim();
    final def = defController.text.trim();

    // CHỐNHT NGU: Chưa đủ thông tin tuyệt đối không cho lưu
    if (term.isEmpty || def.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tuyệt đối không được để trống Từ hoặc Nghĩa!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isSaving = true);
    String finalPhotoUrl = widget.word?.photoUrl ?? 'ha';

    // Xử lý up ảnh nếu có chọn ảnh mới
    if (_selectedImageLocal != null) {
      final uploadedUrl = await ImageService().uploadImageToAzure(
        _selectedImageLocal!,
        'words',
      );
      if (uploadedUrl != null) {
        finalPhotoUrl = uploadedUrl;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Lỗi tải ảnh lên, vui lòng thử lại!"),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => isSaving = false);
        return;
      }
    }

    final userID = currentStudentNotifier.value?.userID;
    if (userID == null) return;

    bool success = false;
    if (widget.word == null) {
      // THÊM MỚI
      final newWord = Word(
        id: 0,
        term: term,
        definition: def,
        photoUrl: finalPhotoUrl,
        lastReview: DateTime.now(),
        nextReview: DateTime.now(),
      );
      success = await WordService().addWordToLibrary(newWord, userID);
    } else {
      // SỬA TỪ
      success = await WordService().updateWord(
        userID,
        widget.word!.id,
        term,
        def,
        finalPhotoUrl,
      );
    }

    setState(() => isSaving = false);
    if (success && mounted) {
      Navigator.pop(context, true); // Trả về true để load lại list
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lỗi khi lưu!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleDelete() async {
    final userID = currentStudentNotifier.value?.userID;
    if (userID == null || widget.word == null) return;

    setState(() => isSaving = true);
    bool success = await WordService().deleteWord(userID, widget.word!.id);

    if (success && mounted) {
      Navigator.pop(context, true);
    } else if (mounted) {
      setState(() => isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lỗi khi xóa!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditMode = widget.word != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text(
        isEditMode ? "Sửa từ vựng" : "Thêm từ vựng mới",
        style: const TextStyle(fontWeight: FontWeight.bold, color: colorOrange),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: termController,
              decoration: const InputDecoration(
                labelText: "Từ vựng (Tiếng Anh)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: defController,
              decoration: const InputDecoration(
                labelText: "Định nghĩa (Tiếng Việt)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // Khu vực chọn ảnh
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.grey.shade400,
                    style: BorderStyle.solid,
                  ),
                ),
                child: _selectedImageLocal != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          _selectedImageLocal!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : (isEditMode &&
                          widget.word!.photoUrl != null &&
                          widget.word!.photoUrl != 'ha')
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          widget.word!.photoUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, color: Colors.grey, size: 40),
                          SizedBox(height: 5),
                          Text(
                            "Bấm để chọn ảnh",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (isEditMode) // Nút Xóa chỉ hiện khi đang sửa
          TextButton(
            onPressed: isSaving ? null : _handleDelete,
            child: const Text(
              "XÓA TỪ",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        TextButton(
          onPressed: isSaving
              ? null
              : () => Navigator.pop(context, false), // Đóng form không lưu
          child: const Text("HỦY", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: colorGreen),
          onPressed: isSaving ? null : _handleSave,
          child: isSaving
              ? const SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text("LƯU", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
