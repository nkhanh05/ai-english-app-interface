import 'package:flutter/material.dart';
import '/models/user/Student.dart';
// Đảm bảo đường dẫn này trỏ đúng đến file constants.dart của bạn
import 'shared_widgets/constants.dart';
import '/service/StudentService.dart';
import '/shared_widgets/shared_appbar.dart';
import '/shared_widgets/shared_endDrawer.dart';

class PersonalProfilePage extends StatefulWidget {
  final Student student;

  const PersonalProfilePage({super.key, required this.student});

  @override
  State<PersonalProfilePage> createState() => _PersonalProfilePageState();
}

class _PersonalProfilePageState extends State<PersonalProfilePage> {
  // 1. Khởi tạo các danh sách rỗng
  List<Student> friends = [];
  List<Student> followers = [];
  List<Student> following = [];

  // Biến để hiển thị vòng xoay loading trong lúc chờ lấy data
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // 2. Gọi hàm lấy dữ liệu ngay khi màn hình vừa được tạo
    _loadRelationships();
  }

  Future<void> _loadRelationships() async {
    // 3. Dùng widget.student.userID để lấy ID
    final int userId = widget.student.userID;

    // Chạy song song 3 API để tiết kiệm thời gian chờ
    final results = await Future.wait([
      StudentService.getFriends(userId),
      StudentService.getFollowers(userId),
      StudentService.getFollowing(userId),
    ]);

    // 4. Cập nhật state để UI render lại với số liệu mới
    if (mounted) {
      setState(() {
        friends = results[0];
        followers = results[1];
        following = results[2];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBeige, // Nền beige tổng thể
      appBar: const CustomAppBar(showBackButton: true), // AppBar dùng chung
      endDrawer: const CustomEndDrawer(), // Menu trượt dùng chung
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            // 1. PHẦN ĐẦU: AVATAR, FOLLOWERS, FOLLOWING
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 15.0,
              ),
              decoration: const BoxDecoration(
                color:
                    Colors.white54, // Nền trắng mờ để tách biệt với nền beige
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor:
                            colorGreen, // Nền avatar xanh lá pastel
                        backgroundImage:
                            widget.student.avatarUrl != null &&
                                widget.student.avatarUrl!.isNotEmpty
                            ? NetworkImage(widget.student.avatarUrl!)
                            : null,
                        child:
                            (widget.student.avatarUrl == null ||
                                widget.student.avatarUrl!.isEmpty)
                            ? const Icon(
                                Icons.person,
                                size: 40,
                                color: colorLightText,
                              )
                            : null,
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            InkWell(
                              onTap: () => print("Mở danh sách Bạn bè"),
                              child: _buildProfileStat(
                                friends.length.toString(),
                                "Bạn bè",
                              ),
                            ),
                            InkWell(
                              onTap: () => print("Mở danh sách Người theo dõi"),
                              child: _buildProfileStat(
                                followers.length.toString(),
                                "Người theo dõi",
                              ),
                            ),
                            InkWell(
                              onTap: () => print("Mở danh sách Đang theo dõi"),
                              child: _buildProfileStat(
                                following.length.toString(),
                                "Đang theo dõi",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.student.fullName.isNotEmpty
                          ? widget.student.fullName
                          : "Người dùng ẩn danh",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: colorBrownText, // Tên màu nâu trầm
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 2. PHẦN GIỮA: STREAK, WEEKLY EXP, TOTAL EXP
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: colorTeal.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildGameStat(
                      Icons.local_fire_department,
                      colorOrange, // Lửa màu cam
                      widget.student.streak.toString(),
                      "Streak",
                    ),
                    _buildGameStat(
                      Icons.bolt,
                      colorNavy, // Tia chớp màu navy
                      widget.student.weeklyExp.toString(),
                      "Weekly EXP",
                    ),
                    _buildGameStat(
                      Icons.star_rounded,
                      colorTeal, // Sao màu teal
                      widget.student.totalExp.toString(),
                      "Total EXP",
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 3. PHẦN CUỐI: TAB BAR VÀ DANH SÁCH
            const TabBar(
              indicatorColor: colorOrange, // Gạch chân tab màu cam
              labelColor: colorOrange, // Text tab đang chọn màu cam
              unselectedLabelColor:
                  colorBrownText, // Text tab không chọn màu nâu
              indicatorWeight: 3,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment),
                      SizedBox(width: 8),
                      Text(
                        "Nhiệm vụ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.military_tech),
                      SizedBox(width: 8),
                      Text(
                        "Huy hiệu",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Expanded(
              child: TabBarView(
                children: [_buildMissionList(), _buildBadgeList()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStat(String count, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: colorBrownText,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: colorBrownText.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildGameStat(
    IconData icon,
    Color iconColor,
    String value,
    String label,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorBrownText,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: colorBrownText.withOpacity(0.6),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMissionList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 2,
      itemBuilder: (context, index) {
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          color: Colors.white,
          child: ExpansionTile(
            collapsedIconColor: colorTeal,
            iconColor: colorOrange,
            leading: const Icon(
              Icons.check_circle_outline,
              color: colorGreen,
              size: 30,
            ),
            title: Text(
              "Nhiệm vụ hàng ngày #${index + 1}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: colorBrownText,
              ),
            ),
            subtitle: Text(
              "Tiến độ: 5/10 từ",
              style: TextStyle(color: colorBrownText.withOpacity(0.7)),
            ),
            childrenPadding: const EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 20,
            ),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Chi tiết: Bạn cần hoàn thành việc ôn tập 10 từ vựng mới trong hôm nay.",
                  style: TextStyle(
                    color: colorBrownText.withOpacity(0.8),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: 0.5,
                  minHeight: 8,
                  backgroundColor: colorBeige,
                  color: colorTeal,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadgeList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 2,
      itemBuilder: (context, index) {
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          color: Colors.white,
          child: ExpansionTile(
            collapsedIconColor: colorTeal,
            iconColor: colorOrange,
            leading: const Icon(Icons.shield, color: colorOrange, size: 35),
            title: Text(
              "Huy hiệu Chiến binh #${index + 1}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: colorBrownText,
              ),
            ),
            subtitle: Text(
              "Loại: Streak Badge",
              style: TextStyle(color: colorBrownText.withOpacity(0.7)),
            ),
            childrenPadding: const EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 20,
            ),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Chi tiết: Đạt được khi bạn duy trì chuỗi học tập đều đặn mỗi ngày.",
                  style: TextStyle(
                    color: colorBrownText.withOpacity(0.8),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
