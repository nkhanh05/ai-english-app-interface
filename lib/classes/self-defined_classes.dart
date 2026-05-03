class Word {
  int? wordID;
  String term;
  String definition;
  String? photoUrl;
  DateTime? createdAt;
  int? repetition;
  int? reviewInterval;
  int? lastReview;
  int? nextReview;
  int? ef;
  String? topic;

  Word({
    required this.term,
    required this.definition,
    this.wordID,
    this.photoUrl,
    this.createdAt,
    this.ef,
    this.lastReview,
    this.nextReview,
    this.reviewInterval,
    this.topic,
    this.repetition,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      wordID: json['wordID'],
      term: json['term'],
      definition: json['definition'],
      photoUrl: json['photoUrl'],
      createdAt: json['createdAt'],
      ef: json['ef'],
      lastReview: json['lastReview'],
      nextReview: json['nextReview'],
      reviewInterval: json['reviewInterval'],
      topic: json['topic'],
      repetition: json['repetition'],
    );
  }
}

class User {
  int? userID;
  String username;
  String? passwordHash;
  String? email;
  String? name;
  String? role;
  DateTime? createdAt;
  String? avatarUrl;
  String? status;

  User({
    this.userID,
    required this.username,
    this.passwordHash,
    this.email,
    this.name,
    this.role,
    this.createdAt,
    this.avatarUrl,
    this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userID: json['userID'],
      username: json['username'],
      passwordHash: json['passwordHash'],
      email: json['email'],
      name: json['name'],
      role: json['role'],
      // Parse chuỗi thời gian từ SQL sang đối tượng DateTime của Dart
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      avatarUrl: json['avatarUrl'],
      status: json['status'],
    );
  }
}

class Student extends User {
  int? studentID;
  int? weeklyExp;
  int? totalExp;
  int? streak;
  bool? isStreakmaintained;

  Student({
    // Các thuộc tính kế thừa từ User
    int? userID,
    String? username,
    String? passwordHash,
    String? email,
    String? name,
    String? role,
    DateTime? createdAt,
    String? avatarUrl,
    String? status,
    // Các thuộc tính riêng của Student
    this.studentID,
    this.weeklyExp,
    this.totalExp,
    this.streak,
    this.isStreakmaintained,
  }) : super(
         userID: userID,
         username: username!,
         passwordHash: passwordHash,
         email: email,
         name: name,
         role: role,
         createdAt: createdAt,
         avatarUrl: avatarUrl,
         status: status,
       );

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      userID: json['userID'],
      username: json['username'] ?? '',
      passwordHash: json['passwordHash'],
      email: json['email'],
      name: json['name'],
      role: json['role'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      avatarUrl: json['avatarUrl'],
      status: json['status'],

      // Ánh xạ dữ liệu của Student
      studentID: json['studentID'],
      weeklyExp: json['weeklyExp'] ?? 0,
      totalExp: json['totalExp'] ?? 0,
      streak: json['streak'] ?? 0,
      isStreakmaintained:
          json['isStreakmaintained'] == 1 || json['isStreakmaintained'] == true,
    );
  }
}
