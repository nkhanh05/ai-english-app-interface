import 'package:flutter/material.dart';
import 'shared_widgets/constants.dart';
import '/models/word/Word.dart';
import '/state/global_state.dart';
import '/service/WordService.dart';
import '/service/pronunciation.dart'; // Import service phát âm
import 'shared_widgets/shared_endDrawer.dart'; // Import Drawer tùy chỉnh
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(showBackButton: false),
      endDrawer: const CustomEndDrawer(),
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

            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorOrange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.filter_alt, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // THAY ĐỔI 1: Thanh Header chia đúng 4 cột tỷ lệ 3:4:2:2
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
                  ? const Center(child: CircularProgressIndicator())
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
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: words.length,
      itemBuilder: (BuildContext c, int i) {
        final word = words[i];

        return Card(
          color: colorGreen,
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            // THAY ĐỔI 2: Thanh danh sách cũng chia đúng 4 cột tỷ lệ 3:4:2:2
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

                // Nút loa nằm trong 1 không gian cố định, dóng thẳng tắp với bên trên
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () {
                      TTSService.speak(word.term);
                    },
                    child: Center(child: _icon(Icons.volume_up)),
                  ),
                ),

                // Khung ảnh nằm gọn gàng bên phải
                Expanded(
                  flex: 2,
                  child: Center(
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child:
                          (word.photoUrl != null && word.photoUrl!.isNotEmpty)
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
