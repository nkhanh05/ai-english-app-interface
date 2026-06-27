import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/question/MatchingQuestion.dart';
import '../../models/word/Word.dart';
import '../shared_widgets/constants.dart';

class MatchingWidget extends StatefulWidget {
  final MatchingQuestion question;
  final Function(bool isCorrect, Word updatedWord) onAnswered;

  const MatchingWidget({
    super.key,
    required this.question,
    required this.onAnswered,
  });

  @override
  State<MatchingWidget> createState() => _MatchingWidgetState();
}

class _MatchingWidgetState extends State<MatchingWidget>
    with SingleTickerProviderStateMixin {
  late List<Word> colA;
  late List<Word> colB;
  Word? _selectedA;
  Word? _selectedB;

  final Set<String> _matchedIds = {};

  // Animation Rung
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  Set<String> _errorIds = {}; // Chứa ID của các ô nối sai để bôi đỏ

  @override
  void initState() {
    super.initState();
    colA = List.from(widget.question.words)..shuffle();
    colB = List.from(widget.question.words)..shuffle();
    widget.question.startTimer();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: 0.0), weight: 1),
    ]).animate(_shakeController);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _handleTap(Word word, bool isColA) {
    if (_matchedIds.contains(word.id.toString()) || _errorIds.isNotEmpty)
      return;

    setState(() {
      if (isColA)
        _selectedA = word;
      else
        _selectedB = word;
    });

    if (_selectedA != null && _selectedB != null) {
      var result = widget.question.matchPair(
        itemFromColumnA: _selectedA!,
        itemFromColumnB: _selectedB!,
      );

      if (result['isCorrect']) {
        setState(() {
          _matchedIds.add(_selectedA!.id.toString());
          _selectedA = null;
          _selectedB = null;
        });
        if (_matchedIds.length == colA.length)
          widget.onAnswered(true, result['affectedWords'][0]);
      } else {
        // HIỆU ỨNG SAI: Đỏ & Rung
        setState(() {
          _errorIds.add(_selectedA!.id.toString());
          _errorIds.add(_selectedB!.id.toString());
        });
        _shakeController.forward(from: 0.0);

        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) {
            setState(() {
              _errorIds.clear();
              _selectedA = null;
              _selectedB = null;
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Nối các cặp từ tương ứng",
          style: TextStyle(
            color: colorNavy,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Center(
            // RESPONSIVE CHO IPAD: Giới hạn chiều rộng tối đa không quá 600px
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Row(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: colA.length,
                      itemBuilder: (context, index) {
                        Word w = colA[index];
                        bool isSelected = _selectedA == w;
                        bool isError =
                            _errorIds.contains(w.id.toString()) && isSelected;
                        return Visibility(
                          visible: !_matchedIds.contains(w.id.toString()),
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: _buildAnimatedCard(
                            w.term,
                            false,
                            isSelected,
                            isError,
                            () => _handleTap(w, true),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: colB.length,
                      itemBuilder: (context, index) {
                        Word w = colB[index];
                        bool isSelected = _selectedB == w;
                        bool isError =
                            _errorIds.contains(w.id.toString()) && isSelected;
                        bool isImageCol = widget.question.answerType == 'Image';
                        return Visibility(
                          visible: !_matchedIds.contains(w.id.toString()),
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: _buildAnimatedCard(
                            isImageCol ? (w.photoUrl ?? '') : w.definition,
                            isImageCol,
                            isSelected,
                            isError,
                            () => _handleTap(w, false),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedCard(
    String content,
    bool isImage,
    bool isSelected,
    bool isError,
    VoidCallback onTap,
  ) {
    // Nếu đang bị lỗi, bọc thêm widget Animation Rung
    Widget card = GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        height: 80,
        decoration: BoxDecoration(
          color: isError
              ? Colors.red[100]
              : (isSelected ? colorTeal.withOpacity(0.2) : Colors.white),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isError
                ? Colors.red
                : (isSelected ? colorTeal : Colors.transparent),
            width: 3,
          ),
          boxShadow: [
            if (!isSelected && !isError)
              const BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
          ],
        ),
        child: Center(
          child: isImage
              ? CachedNetworkImage(
                  imageUrl: content,
                  height: 60,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => const Icon(Icons.image),
                )
              : Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorBrownText,
                  ),
                  textAlign: TextAlign.center,
                ),
        ),
      ),
    );

    if (isError) {
      return AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) => Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        ),
        child: card,
      );
    }
    return card;
  }
}
