import 'package:flutter/material.dart';
import '/models/user/Student.dart'; // Import lớp Student để ánh xạ dữ liệu từ API
import 'package:http/http.dart' as http;
import 'dart:convert';

class PersonalProfilePage extends StatefulWidget {
  const PersonalProfilePage({super.key});

  @override
  State<PersonalProfilePage> createState() => _PersonalProfilePageState();
}

class _PersonalProfilePageState extends State<PersonalProfilePage> {
  Student? currentStudent;
  bool isLoading = true;

  // Dữ liệu Follow tạm thời (vì trong bảng Student chưa có cột này)
  final int followers = 120;
  final int following = 85;

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  // Hàm gọi API lấy dữ liệu người dùng
  // Hàm gọi API lấy dữ liệu người dùng thật từ Node.js
  Future<void> _fetchStudentData() async {
    try {
      final url = Uri.parse('http://10.0.2.2:3000/api/profile/1');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Nếu Server trả về thành công, giải mã JSON
        final Map<String, dynamic> dataFromApi = jsonDecode(response.body);

        if (mounted) {
          setState(() {
            // Ánh xạ dữ liệu JSON vào object Student
            currentStudent = Student.fromJson(dataFromApi);
            isLoading = false;
          });
        }
      } else {
        print("Lỗi từ server: Mã ${response.statusCode}");
        if (mounted) setState(() => isLoading = false);
      }
    } catch (e) {
      print("Lỗi không thể kết nối tới Node.js: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || currentStudent == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          currentStudent!.username,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black, size: 30),
            onPressed: () {
              // TODO: Điều hướng sang trang Cài Đặt (Settings)
            },
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            // 1. PHẦN ĐẦU: AVATAR, FOLLOWERS, FOLLOWING
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage:
                        currentStudent!.avatarUrl != null &&
                            currentStudent!.avatarUrl!.isNotEmpty
                        ? NetworkImage(currentStudent!.avatarUrl!)
                        : null,
                    child:
                        (currentStudent!.avatarUrl == null ||
                            currentStudent!.avatarUrl!.isEmpty)
                        ? const Icon(Icons.person, size: 40, color: Colors.grey)
                        : null,
                  ),

                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () => print("Mở danh sách Người theo dõi"),
                          child: _buildProfileStat(
                            followers.toString(),
                            "Followers",
                          ),
                        ),
                        InkWell(
                          onTap: () => print("Mở danh sách Đang theo dõi"),
                          child: _buildProfileStat(
                            following.toString(),
                            "Following",
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  currentStudent!.name ?? "Người dùng ẩn danh",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. PHẦN GIỮA: STREAK, WEEKLY EXP, TOTAL EXP
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildGameStat(
                      Icons.local_fire_department,
                      Colors.orange,
                      (currentStudent!.streak ?? 0).toString(),
                      "Streak",
                    ),
                    _buildGameStat(
                      Icons.bolt,
                      Colors.blue,
                      (currentStudent!.weeklyExp ?? 0).toString(),
                      "Weekly EXP",
                    ),
                    _buildGameStat(
                      Icons.star_rounded,
                      Colors.amber,
                      (currentStudent!.totalExp ?? 0).toString(),
                      "Total EXP",
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 3. PHẦN CUỐI: TAB BAR VÀ DANH SÁCH (NHIỆM VỤ / HUY HIỆU)
            const TabBar(
              indicatorColor: Colors.black,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(icon: Icon(Icons.assignment), text: "Nhiệm vụ"),
                Tab(icon: Icon(Icons.military_tech), text: "Huy hiệu"),
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
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
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
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMissionList() {
    return ListView.builder(
      itemCount: 2,
      itemBuilder: (context, index) {
        return ExpansionTile(
          leading: const Icon(Icons.check_circle_outline, color: Colors.green),
          title: Text(
            "Nhiệm vụ hàng ngày #${index + 1}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: const Text("Tiến độ: 5/10 từ"),
          childrenPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Chi tiết: Bạn cần hoàn thành việc ôn tập 10 từ vựng mới trong hôm nay.",
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: 0.5,
              backgroundColor: Colors.grey.shade300,
              color: Colors.green,
            ),
          ],
        );
      },
    );
  }

  Widget _buildBadgeList() {
    return ListView.builder(
      itemCount: 2,
      itemBuilder: (context, index) {
        return ExpansionTile(
          leading: const Icon(Icons.shield, color: Colors.purple, size: 35),
          title: Text(
            "Huy hiệu Chiến binh #${index + 1}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: const Text("Loại: Streak Badge"),
          childrenPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Chi tiết: Đạt được khi bạn duy trì chuỗi học tập.",
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
          ],
        );
      },
    );
  }
}
