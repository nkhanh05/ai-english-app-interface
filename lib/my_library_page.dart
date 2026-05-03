import 'package:flutter/material.dart';
import 'constants.dart';
import 'classes/self-defined_classes.dart';
import 'dataImport/api_services.dart';
import 'data/notifier.dart';

class MyLibraryPage extends StatefulWidget {
  const MyLibraryPage({super.key});

  @override
  State<MyLibraryPage> createState() => _MyLibraryPageState();
}

class _MyLibraryPageState extends State<MyLibraryPage> {
  ValueNotifier<List<Word>> myWords = ValueNotifier<List<Word>>([]);
  int id = userID.value; // Lấy userID từ notifier.dart
  @override
  void initState() {
    super.initState();
    _loadWordsFromApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorTeal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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

            // Icon filter
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 25),
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

            //
            const SizedBox(height: 20),

            // Hàng hiển thị các icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _icon(Icons.font_download),
                _icon(Icons.menu_book),
                _icon(Icons.volume_up),
                _icon(Icons.image),
              ],
            ),

            ValueListenableBuilder(
              valueListenable: myWords,
              builder: (context, value, child) {
                return _wordList(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _wordList(List<Word> words) {
    int n = words.length;
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: n,
      itemBuilder: (BuildContext c, int i) => Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(words.elementAt(i).term),
            Text(words.elementAt(i).definition),
            _icon(Icons.volume_up),
            (words.elementAt(i).photoUrl ?? '').isNotEmpty
                ? Image.network(
                    words.elementAt(i).photoUrl!,
                    width: 50,
                    height: 50,
                  )
                : Container(width: 50, height: 50, color: Colors.white24),
          ],
        ),
      ),
    );
  }

  // widget icon tự định nghĩa, sẽ bọc cái icon trong một hình vuông màu Xanh lá được bo góc
  Future<void> _loadWordsFromApi() async {
    try {
      // Dùng await để đợi API trả về dữ liệu thật
      final wordsList = await ApiService.getWords(userID.value);

      // Sau khi có dữ liệu, cập nhật lại vào ValueNotifier
      myWords.value = wordsList;
    } catch (e) {
      // Nhớ bắt lỗi (try-catch) để app không bị crash đỏ màn hình nếu mất mạng
      print("Lỗi tải từ vựng: $e");
    }
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
