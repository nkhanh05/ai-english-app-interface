import 'package:flutter/material.dart';
import '/shared_widgets/shared_appbar.dart'; // Import AppBar dùng chung
import '/shared_widgets/shared_endDrawer.dart'; // Import Drawer dùng chung
import 'shared_widgets/constants.dart';
import '/models/user/Student.dart';
import 'service/StudentService.dart'; // Giả định bạn đã tạo file này
import 'state/global_state.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  late Future<List<Student>> _friendsFuture;
  late Future<List<Student>> _globalFuture;

  @override
  void initState() {
    super.initState();
    final userID = currentStudentNotifier.value?.userID ?? 0;
    _friendsFuture = StudentService.getFriends(userID);
    _globalFuture = StudentService.getGlobalRanking();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: const CustomAppBar(showBackButton: true), // AppBar dùng chung
        endDrawer: const CustomEndDrawer(), // Menu trượt dùng chung
        body: Container(
          decoration: backgroundDecoration,
          child: Column(
            children: [
              Container(
                color: colorGreen,
                child: const TabBar(
                  indicatorColor: colorOrange,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: [
                    Tab(text: "Bạn bè"),
                    Tab(text: "Thế giới"),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildFutureRankingList(
                      _friendsFuture,
                      "Bạn chưa kết bạn với ai!",
                    ),
                    _buildFutureRankingList(
                      _globalFuture,
                      "Chưa có dữ liệu xếp hạng!",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFutureRankingList(
    Future<List<Student>> future,
    String emptyMsg,
  ) {
    return FutureBuilder<List<Student>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }
        if (snapshot.hasError)
          return Center(
            child: Text(
              "Lỗi: ${snapshot.error}",
              style: const TextStyle(color: Colors.black),
            ),
          );

        final students = snapshot.data ?? [];
        if (students.isEmpty) {
          return Center(
            child: Text(
              emptyMsg,
              style: const TextStyle(color: Colors.black, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: students.length,
          itemBuilder: (context, index) =>
              _buildRankItem(students[index], index),
        );
      },
    );
  }

  Widget _buildRankItem(Student student, int index) {
    bool isTop3 = index < 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: isTop3 ? colorOrange : colorGreen,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          // Huy chương hoặc thứ hạng
          isTop3
              ? Icon(
                  Icons.workspace_premium,
                  color: index == 0
                      ? Colors.amber
                      : (index == 1 ? Colors.grey[300] : Colors.brown[300]),
                  size: 35,
                )
              : SizedBox(
                  width: 35,
                  child: Text(
                    "${index + 1}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
          const SizedBox(width: 15),
          const CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              student.fullName,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          Text(
            '${student.weeklyExp} EXP',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
