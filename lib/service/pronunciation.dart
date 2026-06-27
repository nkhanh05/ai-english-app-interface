import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final FlutterTts _flutterTts = FlutterTts();

  static Future<void> speak(String text) async {
    // Cấu hình ngôn ngữ (en-US cho tiếng Anh)
    await _flutterTts.setLanguage("en-US");
    // Tốc độ nói (0.5 là vừa phải)
    await _flutterTts.setSpeechRate(0.5);
    // Độ cao của giọng
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }
}
