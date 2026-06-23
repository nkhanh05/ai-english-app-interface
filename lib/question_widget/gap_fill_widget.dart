import 'package:flutter/material.dart';
import '../../models/question/GapFillQuestion.dart';
import '../../models/word/Word.dart';
import '../shared_widgets/constants.dart';

class GapFillWidget extends StatefulWidget {
  final GapFillQuestion question;
  final Function(bool isCorrect, Word updatedWord) onAnswered;

  const GapFillWidget({
    super.key,
    required this.question,
    required this.onAnswered,
  });

  @override
  State<GapFillWidget> createState() => _GapFillWidgetState();
}

class _GapFillWidgetState extends State<GapFillWidget>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasSubmitted = false;
  bool _isCorrect = false;

  // Animation Rung lắc
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  bool _showEmptyError = false;

  @override
  void initState() {
    super.initState();
    widget.question.startTimer();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _focusNode.requestFocus();
    });

    // Cài đặt hiệu ứng rung
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: 0.0), weight: 1),
    ]).animate(_shakeController);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_hasSubmitted) return;

    // HIỆU ỨNG: Rung & Đỏ nếu để trống
    if (_controller.text.trim().isEmpty) {
      setState(() => _showEmptyError = true);
      _shakeController.forward(from: 0.0);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _showEmptyError = false);
      });
      return;
    }

    setState(() {
      _hasSubmitted = true;
      _isCorrect =
          _controller.text.trim().toLowerCase() ==
          widget.question.targetWord.term.toLowerCase();
    });

    Word updatedWord = widget.question.submitAnswer(_controller.text);
    widget.onAnswered(_isCorrect, updatedWord);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Gõ từ vựng tiếng Anh tương ứng với nghĩa sau:",
          style: TextStyle(color: colorNavy, fontSize: 16),
        ),
        const SizedBox(height: 20),
        Text(
          widget.question.targetWord.definition,
          style: const TextStyle(
            color: colorBrownText,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),

        // Widget Bọc hiệu ứng Rung
        AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) => Transform.translate(
            offset: Offset(_shakeAnimation.value, 0),
            child: child,
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorBrownText,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: _showEmptyError
                  ? Colors.red[100]
                  : (_hasSubmitted
                        ? (_isCorrect ? Colors.green[100] : Colors.red[100])
                        : Colors.white),
              hintText: "Nhập từ vựng...",
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: _showEmptyError ? Colors.red : colorTeal,
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: _showEmptyError ? Colors.red : colorOrange,
                  width: 3,
                ),
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),
        ),
        const SizedBox(height: 30),

        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: _hasSubmitted ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              "KIỂM TRA",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorLightText,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
