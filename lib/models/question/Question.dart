abstract class Question {
  final String id;
  final String questionType;
  final String answerType;

  // Stopwatch to handle the built-in timer logic seamlessly
  final Stopwatch _stopwatch = Stopwatch();

  Question({
    required this.id,
    this.questionType = 'Term',
    this.answerType = 'Definition',
  });

  // Starts the timer from 0 when the question renders on screen
  void startTimer() {
    _stopwatch.reset();
    _stopwatch.start();
  }

  // Stops the timer and returns the elapsed time in seconds
  double stopTimer() {
    _stopwatch.stop();
    return _stopwatch.elapsedMilliseconds / 1000.0;
  }

  // Force reset the timer to 0 midway if needed
  void resetTimer() {
    _stopwatch.reset();
    _stopwatch.start();
  }
}
//
//
//