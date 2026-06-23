import 'package:flutter/material.dart';

import '/shared_widgets/constants.dart';
import '/models/exercise/Exercise.dart';
import '../models/word/Word.dart';
import '../models/question/GapFillQuestion.dart';
import '../models/question/MultipleChoiceQuestion.dart';
import '../models/question/MatchingQuestion.dart';
import '/service/ExerciseService.dart';
import '../state/global_state.dart';

import '/question_widget/gap_fill_widget.dart';
import '/question_widget/multiple_choice_widget.dart';
import '/question_widget/matching_widget.dart';

class ExerciseContainerPage extends StatefulWidget {
  final Exercise exerciseSession;

  const ExerciseContainerPage({super.key, required this.exerciseSession});

  @override
  State<ExerciseContainerPage> createState() => _ExerciseContainerPageState();
}

class _ExerciseContainerPageState extends State<ExerciseContainerPage> {
  dynamic currentQuestion;
  bool isFinished = false;
  bool isSaving = false;

  List<Word> unansweredWords = [];
  bool _showResultTab = false;
  bool _lastAnswerWasCorrect = false;

  // THÊM: Bộ đếm thời gian làm bài
  final Stopwatch _sessionTimer = Stopwatch();

  @override
  void initState() {
    super.initState();
    unansweredWords = List.from(widget.exerciseSession.wordsToRevise);
    _sessionTimer.start(); // Bắt đầu bấm giờ
    _loadNextQuestion();
  }

  void _loadNextQuestion() {
    setState(() {
      if (unansweredWords.isEmpty) {
        isFinished = true;
        _sessionTimer.stop(); // Dừng bấm giờ khi hết câu
        return;
      }
      currentQuestion = widget.exerciseSession.generateNextQuestion(
        unansweredWords,
        widget.exerciseSession.exerciseType,
      );
      if (currentQuestion == null) {
        isFinished = true;
        _sessionTimer.stop();
      }
    });
  }

  void _handleAnswerSubmitted(bool isCorrect, Word updatedWord) {
    widget.exerciseSession.addResult(isCorrect);
    int index = widget.exerciseSession.wordsToRevise.indexWhere(
      (w) => w.id == updatedWord.id,
    );
    if (index != -1) widget.exerciseSession.wordsToRevise[index] = updatedWord;

    setState(() {
      if (isCorrect) {
        if (currentQuestion is MatchingQuestion) {
          for (var w in (currentQuestion as MatchingQuestion).words) {
            unansweredWords.removeWhere((unanswered) => unanswered.id == w.id);
          }
        } else {
          unansweredWords.removeWhere((w) => w.id == updatedWord.id);
        }
      }
      _showResultTab = true;
      _lastAnswerWasCorrect = isCorrect;
    });
  }

  void _onNextPressed() {
    setState(() => _showResultTab = false);
    _loadNextQuestion();
  }

  void _confirmEndEarly() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorBeige,
        title: const Text(
          "Hoàn thành sớm?",
          style: TextStyle(fontWeight: FontWeight.bold, color: colorBrownText),
        ),
        content: const Text(
          "Kết thúc ngay bây giờ? Các câu đã trả lời sẽ được lưu lại.",
          style: TextStyle(color: colorBrownText),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Tiếp tục làm",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _sessionTimer.stop(); // Dừng bấm giờ
              _saveAndExit();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Thoát & Lưu",
              style: TextStyle(
                color: colorLightText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAndExit() async {
    setState(() => isSaving = true);
    int userID = currentStudentNotifier.value?.userID ?? 0;
    bool success = await ExerciseService.saveExerciseResult(
      widget.exerciseSession,
      userID,
    );
    if (!mounted) return;
    setState(() => isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã lưu kết quả thành công!")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isSaving) {
      return Scaffold(
        backgroundColor: colorBeige,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(color: colorOrange),
              SizedBox(height: 20),
              Text(
                "Đang lưu kết quả...",
                style: TextStyle(
                  color: colorBrownText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (isFinished) return _buildFinishedScreen();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorTeal,
        elevation: 0,
        automaticallyImplyLeading: false, // Ẩn nút quay lại
        title: Text(
          "Bài tập: ${widget.exerciseSession.exerciseType}",
          style: const TextStyle(color: colorLightText),
        ),
        actions: [
          TextButton(
            onPressed: _confirmEndEarly,
            child: const Text(
              "Hoàn thành sớm",
              style: TextStyle(
                color: colorBeige,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: backgroundDecoration, // Màu Beige trơn
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: IgnorePointer(
                    ignoring: _showResultTab,
                    child: _buildQuestionContent(),
                  ),
                ),
              ),
              if (_showResultTab) _buildResultTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultTab() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      decoration: BoxDecoration(
        color: _lastAnswerWasCorrect
            ? colorGreen.withOpacity(0.9)
            : const Color(0xFFE57373).withOpacity(0.9),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                _lastAnswerWasCorrect ? Icons.check_circle : Icons.cancel,
                color: colorLightText,
                size: 30,
              ),
              const SizedBox(width: 10),
              Text(
                _lastAnswerWasCorrect
                    ? "Tuyệt vời! Đáp án chính xác."
                    : "Sai rồi! Cố gắng ở câu sau nhé.",
                style: const TextStyle(
                  color: colorLightText,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 55,
            child: ElevatedButton(
              onPressed: _onNextPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: _lastAnswerWasCorrect
                    ? colorNavy
                    : colorBrownText,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                "TIẾP TỤC",
                style: TextStyle(
                  fontSize: 18,
                  color: colorLightText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // THIẾT KẾ LẠI BẢNG TỔNG KẾT CHI TIẾT
  Widget _buildFinishedScreen() {
    String formattedTime =
        "${_sessionTimer.elapsed.inMinutes.toString().padLeft(2, '0')}:${(_sessionTimer.elapsed.inSeconds % 60).toString().padLeft(2, '0')}";

    return Scaffold(
      backgroundColor: colorBeige,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events, color: colorOrange, size: 100),
                const SizedBox(height: 10),
                const Text(
                  "HOÀN THÀNH!",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: colorNavy,
                  ),
                ),
                const SizedBox(height: 30),

                // Khung chứa số liệu thống kê
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 10),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildStatRow(
                        "Số câu đúng:",
                        "${widget.exerciseSession.nCorrectAnswer}",
                        colorGreen,
                      ),
                      const Divider(),
                      _buildStatRow(
                        "Số câu sai:",
                        "${widget.exerciseSession.nIncorrectAnswer}",
                        Colors.redAccent,
                      ),
                      const Divider(),
                      _buildStatRow(
                        "Thời gian làm bài:",
                        formattedTime,
                        colorTeal,
                      ),
                      const Divider(),
                      _buildStatRow(
                        "Điểm tổng kết:",
                        "${widget.exerciseSession.totalPoint}/100",
                        colorOrange,
                        isBold: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _saveAndExit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "LƯU KẾT QUẢ & THOÁT",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorLightText,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(
    String label,
    String value,
    Color color, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              color: colorBrownText,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 24 : 20,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionContent() {
    if (currentQuestion == null)
      return const Center(child: CircularProgressIndicator(color: colorOrange));
    if (currentQuestion is GapFillQuestion)
      return GapFillWidget(
        key: ValueKey(currentQuestion.id),
        question: currentQuestion as GapFillQuestion,
        onAnswered: _handleAnswerSubmitted,
      );
    if (currentQuestion is MultipleChoiceQuestion)
      return MultipleChoiceWidget(
        key: ValueKey(currentQuestion.id),
        question: currentQuestion as MultipleChoiceQuestion,
        onAnswered: _handleAnswerSubmitted,
      );
    if (currentQuestion is MatchingQuestion)
      return MatchingWidget(
        key: ValueKey(currentQuestion.id),
        question: currentQuestion as MatchingQuestion,
        onAnswered: _handleAnswerSubmitted,
      );
    return const Center(
      child: Text("Lỗi tải câu hỏi", style: TextStyle(color: colorBrownText)),
    );
  }
}
