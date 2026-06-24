import 'package:flutter/material.dart';
import '/models/user/Student.dart';
import '/service/StudentService.dart';
import 'personal_profile.dart';

class RelationshipDetailPage extends StatefulWidget {
  final int studentId;
  final int initialIndex;

  const RelationshipDetailPage({
    super.key,
    required this.studentId,
    required this.initialIndex,
  });

  @override
  State<RelationshipDetailPage> createState() => _RelationshipDetailPageState();
}

class _RelationshipDetailPageState extends State<RelationshipDetailPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: widget.initialIndex,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          title: const Text(
            "Kết nối",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.black,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "Bạn bè"),
              Tab(text: "Người theo dõi"),
              Tab(text: "Đang theo dõi"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUserList(() => StudentService.getFriends(widget.studentId)),
            _buildUserList(() => StudentService.getFollowers(widget.studentId)),
            _buildUserList(() => StudentService.getFollowing(widget.studentId)),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList(Future<List<Student>> Function() fetchFunction) {
    return FutureBuilder<List<Student>>(
      future: fetchFunction(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Đã xảy ra lỗi khi tải dữ liệu."));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Danh sách trống."));
        }

        final users = snapshot.data!;

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];

            return ListTile(
              leading: CircleAvatar(
                backgroundImage: user.avatarUrl?.isNotEmpty == true
                    ? NetworkImage(user.avatarUrl!)
                    : null,
                child: user.avatarUrl?.isEmpty ?? true
                    ? const Icon(Icons.person)
                    : null,
              ),
              title: Text(
                user.fullName.isNotEmpty ? user.fullName : user.username,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text("EXP Tuần: ${user.weeklyExp}"),
              onTap: () {
                // Điều hướng đến Profile của User được click
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PersonalProfilePage(student: user),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
