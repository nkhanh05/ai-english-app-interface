import '/models/question/Question.dart';
import '/models/word/Word.dart';

class GapFillQuestion extends Question {
  final Word targetWord;

  GapFillQuestion({
    required super.id,
    required this.targetWord,
    super.questionType,
    super.answerType,
  });

  int _calculateQualityScore(double seconds) {
    if (seconds <= 2.0) return 5; // Trả lời siêu nhanh, nhớ rất kỹ
    if (seconds <= 5.0) return 4; // Tốc độ bình thường
    return 3; // Trả lời đúng nhưng mất nhiều thời gian suy nghĩ
  }

  double _getNewEF(double currentEF, int q) {
    double updatedEF = currentEF + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
    return updatedEF < 1.3
        ? 1.3
        : updatedEF; // Giới hạn EF không bao giờ thấp hơn 1.3
  }

  int _getNewInterval(int currentNumberCorrect, double newEF) {
    if (currentNumberCorrect == 1) return 1;
    if (currentNumberCorrect == 2) return 6;
    return (currentNumberCorrect * newEF)
        .round(); // Công thức tịnh tiến SM-2 cơ bản
  }

  /// Xử lý kết quả câu hỏi điền từ

  Word submitAnswer(String userInput) {
    double elapsedSeconds = stopTimer();
    String cleanInput = userInput.trim().toLowerCase();

    String correctAnswer = (super.answerType == 'Definition')
        ? targetWord.definition.toLowerCase()
        : targetWord.term.toLowerCase();

    bool isCorrect = (cleanInput == correctAnswer);

    // 1. Chấm điểm Quality (q) từ 0-5
    int q;
    if (isCorrect) {
      q = _calculateQualityScore(elapsedSeconds); // 3, 4, hoặc 5
    } else {
      q = 0; // Trả lời sai (Blackout) -> điểm 0
    }

    // 2. Tính lại EF MỚI cho CẢ ĐÚNG VÀ SAI theo công thức chuẩn
    double newEF = _getNewEF(targetWord.ef, q);

    // 3. Tính Interval (I) mới
    int newNumberCorrect;
    int newInterval;

    if (q >= 3) {
      // Nếu trả lời đúng
      newNumberCorrect = targetWord.numberCorrect + 1;

      if (newNumberCorrect == 1) {
        newInterval = 1;
      } else if (newNumberCorrect == 2) {
        newInterval = 6;
      } else {
        // I(n) := I(n-1) * EF (Làm tròn lên)
        newInterval = (targetWord.reviewInterval * newEF).ceil();
      }
    } else {
      // Nếu trả lời sai (q < 3)
      newNumberCorrect = 1; // Start repetitions from the beginning
      newInterval = 1; // I(1) := 1
    }

    DateTime now = DateTime.now();
    DateTime calculatedNextReview = now.add(Duration(days: newInterval));

    Word updatedWord = targetWord.copyWith(
      numberCorrect: newNumberCorrect,
      ef: newEF,
      reviewInterval: newInterval,
      lastReview: now,
      nextReview: calculatedNextReview,
    );

    return updatedWord;
  }
}
