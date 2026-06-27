import '/models/question/Question.dart';
import '/models/word/Word.dart';

/// 3. Matching Question (5 Words paired together)
class MatchingQuestion extends Question {
  final List<Word> words; // Must contain exactly 5 elements

  MatchingQuestion({
    required super.id,
    required this.words,
    super.questionType,
    super.answerType,
  }) : assert(words.length == 5, 'Matching question requires exactly 5 words');

  /// Processes the selection match between an element from Column A and Column B.
  /// Handles the complex internal state adjustments of timing and EF calculation.
  Map<String, dynamic> matchPair({
    required Word itemFromColumnA,
    required Word itemFromColumnB,
  }) {
    bool isCorrectMatch = (itemFromColumnA.id == itemFromColumnB.id);
    double stepElapsedTime = stopTimer();
    DateTime now = DateTime.now();

    if (!isCorrectMatch) {
      // --- KHI NỐI SAI (Phạt cả 2 từ) ---
      int q = 0; // Trả lời sai (Blackout) -> điểm 0

      // Phạt từ ở Cột A
      itemFromColumnA.ef =
          itemFromColumnA.ef + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
      if (itemFromColumnA.ef < 1.3) itemFromColumnA.ef = 1.3;
      itemFromColumnA.numberCorrect = 1; // Bắt đầu lại chu kỳ
      itemFromColumnA.reviewInterval = 1; // I(1) = 1
      itemFromColumnA.lastReview = now;
      itemFromColumnA.nextReview = now.add(const Duration(days: 1));

      // Phạt từ ở Cột B
      itemFromColumnB.ef =
          itemFromColumnB.ef + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
      if (itemFromColumnB.ef < 1.3) itemFromColumnB.ef = 1.3;
      itemFromColumnB.numberCorrect = 1; // Bắt đầu lại chu kỳ
      itemFromColumnB.reviewInterval = 1; // I(1) = 1
      itemFromColumnB.lastReview = now;
      itemFromColumnB.nextReview = now.add(const Duration(days: 1));
    } else {
      // --- KHI NỐI ĐÚNG ---
      // 1. Chấm điểm Quality (q) dựa trên tốc độ nối
      int q = 3;
      if (stepElapsedTime <= 2.0)
        q = 5;
      else if (stepElapsedTime <= 5.0)
        q = 4;

      // 2. Tính lại EF MỚI cho từ đó
      itemFromColumnA.ef =
          itemFromColumnA.ef + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
      if (itemFromColumnA.ef < 1.3) itemFromColumnA.ef = 1.3;

      // 3. Tính toán Interval theo cấp số nhân
      itemFromColumnA.numberCorrect += 1;

      if (itemFromColumnA.numberCorrect == 1) {
        itemFromColumnA.reviewInterval = 1;
      } else if (itemFromColumnA.numberCorrect == 2) {
        itemFromColumnA.reviewInterval = 6;
      } else {
        // I(n) = I(n-1) * EF (Làm tròn lên)
        itemFromColumnA.reviewInterval =
            (itemFromColumnA.reviewInterval * itemFromColumnA.ef).ceil();
      }

      // 4. Gán thời gian ôn tập
      itemFromColumnA.lastReview = now;
      itemFromColumnA.nextReview = now.add(
        Duration(days: itemFromColumnA.reviewInterval),
      );
    }

    // IMMEDIATELY RESET TIMER TO 0 for the next pair matching process
    resetTimer();

    return {
      'isCorrect': isCorrectMatch,
      'elapsedTimeForPair': stepElapsedTime,
      'affectedWords': [itemFromColumnA, itemFromColumnB],
    };
  }

  /// Helper implementation adjusting SM-2 Easiness Factor based on time intervals
  double _calculateNewEF(double currentEF, double reactionTimeSeconds) {
    int qualityScore;

    // Map reaction speed to SM-2 quality grades (3 to 5)
    if (reactionTimeSeconds <= 2.0) {
      qualityScore = 5; // Instant recognition
    } else if (reactionTimeSeconds <= 5.0) {
      qualityScore = 4; // Correct with some hesitation
    } else {
      qualityScore = 3; // Correct, but required significant thought
    }

    // Standard SM-2 formula modifications
    double updatedEF =
        currentEF +
        (0.1 - (5 - qualityScore) * (0.08 + (5 - qualityScore) * 0.02));
    return updatedEF < 1.3 ? 1.3 : updatedEF; // Enforce lower threshold limit
  }
}
