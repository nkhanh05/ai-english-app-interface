import 'package:flutter/material.dart';
import 'constants.dart';

class ExerciseMenuPage extends StatelessWidget {
  const ExerciseMenuPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: colorTeal, leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context))),
      body: Container(
        width: double.infinity, decoration: backgroundDecoration,
        child: Column(children: [
          const SizedBox(height: 40),
          const Text("ÔN LUYỆN TỪ MỚI", style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: Color(0xFF800000))),
          const SizedBox(height: 40),
          Expanded(child: GridView.count(padding: const EdgeInsets.symmetric(horizontal: 30), crossAxisCount: 2, mainAxisSpacing: 20, crossAxisSpacing: 20, children: [
            _btn("TRẮC NGHIỆM"), _btn("NỐI HÌNH"), _btn("ĐIỀN TỪ"), _btn("HỖN HỢP"),
          ])),
        ]),
      ),
    );
  }
  Widget _btn(String t) => Container(decoration: BoxDecoration(color: colorOrange, borderRadius: BorderRadius.circular(15)), child: Center(child: Text(t, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))));
}