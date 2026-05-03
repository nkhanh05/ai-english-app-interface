import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:ai_english_application/dataImport/Translate.dart';
import 'package:flutter/material.dart';
import 'package:ultralytics_yolo/models/yolo_result.dart';
import 'package:ultralytics_yolo/models/yolo_task.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import 'package:ultralytics_yolo/widgets/yolo_controller.dart';
import 'package:ultralytics_yolo/yolo_view.dart';
import 'constants.dart';
import 'classes/self-defined_classes.dart';
import 'word_detail_page.dart'; // Import trang chi tiết từ vựng

class ScanObjectPage extends StatefulWidget {
  const ScanObjectPage({super.key});

  @override
  State<ScanObjectPage> createState() => _ScanObjectPageState();
}

class _ScanObjectPageState extends State<ScanObjectPage> {
  List<YOLOResult> detectedObjects = [];
  final YOLOViewController _yoloController = YOLOViewController();

  @override
  void dispose() {
    _yoloController.stop();
    // 2. Xóa danh sách vật thể đang lưu trong RAM
    detectedObjects.clear();
    super.dispose();
  }

  Widget build(BuildContext context) {
    // Tính toán kích thước hiển thị thực tế
    final double viewWidth = MediaQuery.of(context).size.width;
    final double viewHeight = viewWidth * (4 / 3);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorTeal,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: const [
            Icon(Icons.local_fire_department, color: Colors.orange, size: 28),
            SizedBox(width: 5),
            Text("5", style: TextStyle(color: Colors.white, fontSize: 18)),
            Spacer(),
            Icon(Icons.notifications, color: colorOrange, size: 30),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: colorOrange, size: 35),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: viewWidth,
          height: viewWidth, // Giữ khung hình vuông như bạn đã thiết lập
          child: ClipRect(
            child: OverflowBox(
              alignment: Alignment.center,
              maxWidth: viewWidth,
              maxHeight: viewHeight,
              child: Stack(
                // Sử dụng Stack để GestureDetector nằm trên cùng
                children: [
                  YOLOView(
                    controller: _yoloController,
                    confidenceThreshold: 0.5,
                    modelPath: 'assets/models/yolov8n_int8.tflite',
                    showOverlays: true,
                    onResult: (result) {
                      // Cập nhật danh sách vật thể vào state
                      setState(() {
                        detectedObjects = result;
                      });
                    },

                    task: YOLOTask.detect,
                  ),

                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior
                          .opaque, // Đảm bảo nhận diện chạm ở cả vùng trống
                      onTapUp: (details) async {
                        _yoloController.setShowOverlays(false);
                        final tapPosition = details.localPosition;

                        for (final obj in detectedObjects) {
                          // Chuyển đổi tọa độ chuẩn hóa (0.0 - 1.0) sang tọa độ pixel
                          final boxRect = Rect.fromLTWH(
                            obj.normalizedBox.left * viewWidth,
                            obj.normalizedBox.top * viewHeight,
                            obj.normalizedBox.width * viewWidth,
                            obj.normalizedBox.height * viewHeight,
                          );
                          Uint8List imgResult = Uint8List(0);
                          if (boxRect.contains(tapPosition)) {
                            final imageBytes = await _yoloController
                                .captureFrame();
                            if (imageBytes != null) {
                              img.Image? originalImage = img.decodeImage(
                                imageBytes,
                              );
                              final box = obj.normalizedBox;
                              int x = (box.left * originalImage!.width).toInt();
                              int y = (box.top * originalImage.height).toInt();
                              int width = (box.width * originalImage.width)
                                  .toInt();
                              int height = (box.height * originalImage.height)
                                  .toInt();

                              img.Image croppedImage = img.copyCrop(
                                originalImage,
                                x: x,
                                y: y,
                                width: width,
                                height: height,
                              );
                              imgResult = img.encodeJpg(croppedImage);
                            }

                            await _navigateToDetail(obj, imgResult);
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToDetail(YOLOResult obj, Uint8List croppedImage) async {
    debugPrint('🎯 Đã click trúng: ${obj.className}');

    // Tạo đối tượng Word theo cấu trúc dự án của bạn
    Word w = Word(
      term: obj.className,
      definition: await TranslationService.translateEnToVi(obj.className),
    );
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => WordDetailPage(word: w, imageData: croppedImage),
      ),
    );
  }
}
