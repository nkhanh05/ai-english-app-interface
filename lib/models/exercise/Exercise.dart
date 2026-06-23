import 'dart:math';
import '/models/word/Word.dart';
import '/models/question/GapFillQuestion.dart';
import '/models/question/MatchingQuestion.dart';
import '/models/question/MultipleChoiceQuestion.dart';
import '/models/question/Question.dart';

class Exercise {
  final String id;
  String exerciseType; // 'GapFill', 'MultipleChoice', 'Matching', 'Mixed'
  List<Word> wordsToRevise;

  int nCorrectAnswer;
  int nIncorrectAnswer;
  int totalPoint;
  DateTime revisedTime;

  Exercise({
    required this.id,
    required this.exerciseType,
    required this.wordsToRevise,
    this.nCorrectAnswer = 0,
    this.nIncorrectAnswer = 0,
    this.totalPoint = 0,
    DateTime? revisedTime,
  }) : revisedTime = revisedTime ?? DateTime.now();

  void addResult(bool isCorrect) {
    if (isCorrect) {
      nCorrectAnswer++;
    } else {
      nIncorrectAnswer++;
    }
    int totalQuestions = nCorrectAnswer + nIncorrectAnswer;
    if (totalQuestions > 0) {
      totalPoint = ((nCorrectAnswer / totalQuestions) * 100).round();
    }
  }

  // --- HÀM ĐIỀU PHỐI (QUYẾT ĐỊNH LOẠI CÂU HỎI VÀ ĐỊNH DẠNG) ---
  dynamic generateNextQuestion(List<Word> w, String currentExerciseType) {
    if (w.isEmpty) return null;

    final random = Random();
    String format = currentExerciseType;

    // 1. Random loại câu hỏi nếu chế độ là Mixed
    if (format == 'Mixed') {
      final formats = ['GapFill', 'MultipleChoice', 'Matching'];
      format = formats[random.nextInt(formats.length)];
    }

    // 2. Chặn lỗi Matching: Nếu không đủ 5 từ, ép về MultipleChoice
    if (format == 'Matching' && w.length < 5) {
      format = random.nextBool() ? 'MultipleChoice' : 'GapFill';
    }

    // 3. Xử lý GapFill: Cố định là hỏi Definition, trả lời Term
    if (format == 'GapFill') {
      return generateGapFillQuestion(w);
    }

    // 4. Định nghĩa các cặp Question - Answer hợp lệ
    // Quy tắc: Không ghép Definition (Tiếng Việt) với Image và không ghép Image với Image.
    final List<Map<String, String>> validPairs = [
      {'q': 'Term', 'a': 'Definition'}, // Hỏi Tiếng Anh - Chọn Tiếng Việt
      {'q': 'Definition', 'a': 'Term'}, // Hỏi Tiếng Việt - Chọn Tiếng Anh
      {'q': 'Term', 'a': 'Image'}, // Hỏi Tiếng Anh - Chọn Ảnh
      {'q': 'Image', 'a': 'Term'}, // Hỏi Ảnh - Chọn Tiếng Anh
    ];

    // Lọc bỏ cặp có Image nếu từ vựng không hỗ trợ ảnh (phòng hờ dữ liệu lỗi)
    final availablePairs = validPairs.where((pair) {
      if ((pair['q'] == 'Image' || pair['a'] == 'Image') &&
          !_hasEnoughImages(w, format)) {
        return false;
      }
      return true;
    }).toList();

    // Chọn ngẫu nhiên 1 cặp định dạng
    final selectedPair = availablePairs[random.nextInt(availablePairs.length)];
    String qType = selectedPair['q']!;
    String aType = selectedPair['a']!;

    // 5. Trả về đúng loại câu hỏi
    if (format == 'MultipleChoice') {
      return generateMultipleChoiceQuestion(w, qType, aType);
    } else {
      return generateMatchingQuestion(w, qType, aType);
    }
  }

  // --- CÁC HÀM TẠO CÂU HỎI CHI TIẾT ---

  GapFillQuestion generateGapFillQuestion(List<Word> w) {
    // GapFill luôn là hỏi Definition (Tiếng Việt) và bắt gõ Term (Tiếng Anh)
    final word = (List<Word>.from(w)..shuffle()).first;
    return GapFillQuestion(
      id: _generateUniqueId(),
      targetWord: word,
      questionType: 'Definition',
      answerType: 'Term',
    );
  }

  MultipleChoiceQuestion generateMultipleChoiceQuestion(
    List<Word> w,
    String qType,
    String aType,
  ) {
    final shuffled = List<Word>.from(w)..shuffle();
    final targetWord = _findValidWord(shuffled, qType, aType);

    // Lấy 3 đáp án nhiễu (distractors)
    final distractors = shuffled
        .where((word) => word.id != targetWord.id)
        .take(3)
        .toList();

    // Ánh xạ ra chuỗi để hiển thị
    List<String> options = distractors
        .map((word) => _extractDataByType(word, aType))
        .toList();
    options.add(_extractDataByType(targetWord, aType));
    options.shuffle();

    return MultipleChoiceQuestion(
      id: _generateUniqueId(),
      targetWord: targetWord,
      choices: options,
      questionType: qType,
      answerType: aType,
    );
  }

  MatchingQuestion generateMatchingQuestion(
    List<Word> w,
    String qType,
    String aType,
  ) {
    // Đã được bảo vệ ở hàm điều phối: List w chắc chắn có >= 5 phần tử
    final subset = (List<Word>.from(w)..shuffle()).take(5).toList();

    return MatchingQuestion(
      id: _generateUniqueId(),
      words: subset,
      questionType: qType,
      answerType: aType,
    );
  }

  // --- CÁC HÀM TIỆN ÍCH DÙNG CHUNG ---

  String _generateUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Trích xuất dữ liệu của Word dựa trên type
  String _extractDataByType(Word word, String type) {
    if (type == 'Image') return word.photoUrl ?? '';
    if (type == 'Definition') return word.definition;
    return word.term;
  }

  // Đảm bảo chọn được từ đích hợp lệ (ví dụ: cần hình ảnh thì từ đó phải có hình ảnh)
  Word _findValidWord(List<Word> shuffledList, String qType, String aType) {
    if (qType == 'Image' || aType == 'Image') {
      return shuffledList.firstWhere(
        (w) => w.photoUrl != null && w.photoUrl!.isNotEmpty,
        orElse: () => shuffledList.first,
      );
    }
    return shuffledList.first;
  }

  // Kiểm tra xem danh sách có đủ số lượng từ có ảnh để tạo câu hỏi không
  bool _hasEnoughImages(List<Word> list, String format) {
    int requiredImages = (format == 'MultipleChoice') ? 4 : 5;
    int count = list
        .where((w) => w.photoUrl != null && w.photoUrl!.isNotEmpty)
        .length;
    return count >= requiredImages;
  }
}
