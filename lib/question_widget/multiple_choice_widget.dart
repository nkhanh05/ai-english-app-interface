import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/question/MultipleChoiceQuestion.dart';
import '../../models/word/Word.dart';
import '../shared_widgets/constants.dart';

class MultipleChoiceWidget extends StatefulWidget {
  final MultipleChoiceQuestion question;
  final Function(bool isCorrect, Word updatedWord) onAnswered;

  const MultipleChoiceWidget({
    super.key,
    required this.question,
    required this.onAnswered,
  });

  @override
  State<MultipleChoiceWidget> createState() => _MultipleChoiceWidgetState();
}

class _MultipleChoiceWidgetState extends State<MultipleChoiceWidget> {
  String? _selectedOption;
  bool _hasAnswered = false;
  late bool _isCorrect;

  @override
  void initState() {
    super.initState();
    widget.question.startTimer();
  }

  void _selectOption(String option) {
    if (_hasAnswered) return;
    var result = widget.question.checkAnswer(option);
    setState(() {
      _hasAnswered = true;
      _selectedOption = option;
      _isCorrect = result['isCorrect'];
    });
    widget.onAnswered(_isCorrect, result['updatedWord']);
  }

  Color _getButtonColor(String option) {
    if (!_hasAnswered) return Colors.white;
    if (option == _selectedOption)
      return _isCorrect ? colorGreen : Colors.redAccent;

    // Highlight luôn đáp án đúng nếu chọn sai
    if (widget.question.answerType == 'Image' &&
        option == widget.question.targetWord.photoUrl)
      return colorGreen;
    if (widget.question.answerType == 'Definition' &&
        option == widget.question.targetWord.definition)
      return colorGreen;
    if (widget.question.answerType == 'Term' &&
        option == widget.question.targetWord.term)
      return colorGreen;

    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    String title = "Chọn đáp án đúng:";
    if (widget.question.answerType == 'Image') title = "Đâu là hình ảnh của:";
    if (widget.question.questionType == 'Image')
      title = "Hình ảnh này có nghĩa là:";

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 600,
        ), // Không bung toét ra trên iPad
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: colorNavy,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            if (widget.question.questionType == 'Image')
              Expanded(
                flex: 2,
                child: CachedNetworkImage(
                  imageUrl: widget.question.targetWord.photoUrl ?? '',
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(color: colorOrange),
                  ),
                ),
              )
            else
              Expanded(
                flex: 1,
                child: Center(
                  child: Text(
                    widget.question.questionType == 'Term'
                        ? widget.question.targetWord.term
                        : widget.question.targetWord.definition,
                    style: const TextStyle(
                      color: colorBrownText,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            const SizedBox(height: 20),

            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: widget.question.choices.map((option) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: widget.question.answerType == 'Image' ? 120 : 65,
                      child: ElevatedButton(
                        onPressed: () => _selectOption(option),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getButtonColor(option),
                          foregroundColor: colorBrownText,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: widget.question.answerType == 'Image'
                            ? CachedNetworkImage(
                                imageUrl: option,
                                height: 100,
                                fit: BoxFit.cover,
                              )
                            : Text(
                                option,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
