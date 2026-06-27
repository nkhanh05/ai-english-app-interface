import '/models/question/Question.dart';
import '/models/word/Word.dart';

class MultipleChoiceQuestion extends Question {
  final Word targetWord;
  final List<String> choices; // List of choices compiled based on answerType

  MultipleChoiceQuestion({
    required super.id,
    required this.targetWord,
    required this.choices,
    super.questionType,
    super.answerType,
  });

  /// Validates the chosen answer and updates the Word data metrics.
  /// Returns a Map containing the updated word and the reaction time.
  Map<String, dynamic> checkAnswer(String selectedAnswer) {
    double elapsedSeconds = stopTimer();
    bool isCorrect = false;

    // Determine correctness based on what kind of answer was expected
    if (super.answerType == 'Term' && selectedAnswer == targetWord.term)
      isCorrect = true;
    if (super.answerType == 'Definition' &&
        selectedAnswer == targetWord.definition)
      isCorrect = true;
    if (super.answerType == 'Image' && selectedAnswer == targetWord.photoUrl)
      isCorrect = true;

    // --- BỔ SUNG LOGIC SM-2 CHUẨN ---
    int q = 0;
    if (isCorrect) {
      if (elapsedSeconds <= 2.0)
        q = 5;
      else if (elapsedSeconds <= 5.0)
        q = 4;
      else
        q = 3;
    }

    // Công thức tính EF (Cho cả đúng và sai)
    targetWord.ef = targetWord.ef + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
    if (targetWord.ef < 1.3) targetWord.ef = 1.3;

    if (q >= 3) {
      targetWord.numberCorrect += 1;
      if (targetWord.numberCorrect == 1) {
        targetWord.reviewInterval = 1;
      } else if (targetWord.numberCorrect == 2) {
        targetWord.reviewInterval = 6;
      } else {
        // I(n) = I(n-1) * EF
        targetWord.reviewInterval = (targetWord.reviewInterval * targetWord.ef)
            .ceil();
      }
    } else {
      targetWord.numberCorrect = 1;
      targetWord.reviewInterval = 1;
    }

    DateTime now = DateTime.now();
    targetWord.lastReview = now;
    targetWord.nextReview = now.add(Duration(days: targetWord.reviewInterval));

    return {
      'isCorrect': isCorrect,
      'elapsedTime': elapsedSeconds,
      'updatedWord': targetWord,
    };
  }
}
