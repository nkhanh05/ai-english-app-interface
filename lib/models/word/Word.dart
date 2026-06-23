import 'dart:core';
import 'dart:ffi';

class Word {
  // Các thuộc tính cơ bản của Từ vựng
  final int id; // Thường cần thêm ID để quản lý trong DB (MongoDB/Firebase)
  String term;
  String definition;
  String? photoUrl; // Sử dụng String? vì có thể từ không có ảnh minh họa

  // Các hệ số phục vụ thuật toán Spaced Repetition (SM-2)
  double ef;
  int reviewInterval; // Khoảng thời gian giãn cách (tính theo ngày)
  int numberCorrect; // Số lần trả lời đúng liên tiếp (tương đương biến n)

  // Quản lý mốc thời gian
  DateTime lastReview;
  DateTime nextReview;
  DateTime createdAt;

  // Constructor
  Word({
    this.id = 0,
    required this.term,
    required this.definition,
    this.photoUrl,
    this.ef = 2.5, // Mặc định ban đầu của SM-2 là 2.5
    this.reviewInterval = 0, // Chưa ôn tập lần nào
    this.numberCorrect = 0, // Khởi tạo chuỗi đúng bằng 0
    required this.lastReview,
    required this.nextReview,
    DateTime? createdAt, // Nếu không truyền thì lấy thời gian hiện tại
  }) : createdAt = createdAt ?? DateTime.now();

  Word copyWith({
    int? id,
    String? term,
    String? definition,
    String? photoUrl,
    double? ef,
    int? reviewInterval,
    int? numberCorrect,
    DateTime? lastReview,
    DateTime? nextReview,
    DateTime? createdAt,
  }) {
    return Word(
      id: id ?? this.id,
      term: term ?? this.term,
      definition: definition ?? this.definition,
      photoUrl: photoUrl ?? this.photoUrl,
      ef: ef ?? this.ef,
      reviewInterval: reviewInterval ?? this.reviewInterval,
      numberCorrect: numberCorrect ?? this.numberCorrect,
      lastReview: lastReview ?? this.lastReview,
      nextReview: nextReview ?? this.nextReview,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
