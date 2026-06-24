import 'package:flutter/material.dart';
import '/models/user/Student.dart';
import 'shared_widgets/constants.dart';
import '/service/StudentService.dart';
import '/shared_widgets/shared_appbar.dart';
import '/shared_widgets/shared_endDrawer.dart';
import 'relationship_detail.dart';
import 'edit_profile_page.dart';

class PersonalProfilePage extends StatefulWidget {
  final Student student;
  final bool isMe;

  const PersonalProfilePage({
    super.key, 
    required this.student, 
    this.isMe = false, 
  });

  @override
  State<PersonalProfilePage> createState() => _PersonalProfilePageState();
}

class _PersonalProfilePageState extends State<PersonalProfilePage> {
  List<Student> friends = [];
  List<Student> followers = [];
  List<Student> following = [];
  bool isLoading = true;

  late Student currentStudent;

  @override
  void initState() {
    super.initState();
    currentStudent = widget.student;
    _loadRelationships();
  }

  Future<void> _loadRelationships() async {
    final int userId = currentStudent.userID;
    final results = await Future.wait([
      StudentService.getFriends(userId),
      StudentService.getFollowers(userId),
      StudentService.getFollowing(userId),
    ]);

    if (mounted) {
      setState(() {
        friends = results[0];
        followers = results[1];
        following = results[2];
        isLoading = false;
      });
    }
  }

  // Hàm load lại Profile từ Server để cập nhật tên/ảnh mới nhất sau khi sửa
  Future<void> _reloadFullProfile() async {
    final freshStudent = await StudentService().getProfile(currentStudent.userID);
    if (freshStudent != null && mounted) {
      setState(() {
        currentStudent = freshStudent;
      });
    }
    _loadRelationships(); // Load lại cả list bạn bè
  }

  // --- HÀM HIỂN THỊ HỘP THOẠI TÌM KIẾM ---
  void _showSearchDialog() {
    final TextEditingController searchController = TextEditingController();
    showDialog(
      context: context, // Đây là context của trang gốc
      builder: (dialogContext) { // ĐỔI TÊN THÀNH dialogContext ĐỂ KHÔNG BỊ TRÙNG
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Thêm bạn bè", style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: "Nhập username (vd: khanh05)",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext), // Đóng bằng dialogContext
              child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: colorOrange),
              onPressed: () async {
                final username = searchController.text.trim();
                if (username.isNotEmpty) {
                  // Đóng hộp thoại ngay lập tức bằng dialogContext
                  Navigator.pop(dialogContext); 
                  
                  // Gọi API Tìm kiếm
                  final foundUser = await StudentService.searchByUsername(username);
                  
                  if (foundUser != null && mounted) {
                    // TÌM THẤY: Dùng "context" của trang gốc để chuyển trang an toàn
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PersonalProfilePage(
                          student: foundUser,
                          isMe: foundUser.userID == currentStudent.userID, 
                        ),
                      ),
                    );
                  } else if (mounted) {
                    // KHÔNG TÌM THẤY: Dùng "context" của trang gốc để hiện thông báo
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Không tìm được người dùng"), 
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
              child: const Text("Tìm kiếm"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBeige,
      appBar: const CustomAppBar(showBackButton: true),
      endDrawer: const CustomEndDrawer(),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            // 1. PHẦN ĐẦU
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
              decoration: const BoxDecoration(
                color: Colors.white54,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        radius: 42,
                        backgroundColor: colorGreen,
                        backgroundImage: currentStudent.avatarUrl?.isNotEmpty == true
                            ? NetworkImage(currentStudent.avatarUrl!)
                            : null,
                        child: currentStudent.avatarUrl?.isEmpty ?? true
                            ? const Icon(Icons.person, size: 45, color: Colors.white)
                            : null,
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            InkWell(onTap: () => _goToDetail(0), child: _buildProfileStat(friends.length.toString(), "bạn bè")),
                            InkWell(onTap: () => _goToDetail(1), child: _buildProfileStat(followers.length.toString(), "người theo dõi")),
                            InkWell(onTap: () => _goToDetail(2), child: _buildProfileStat(following.length.toString(), "đang theo dõi")),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  Text(
                    currentStudent.fullName.isNotEmpty ? currentStudent.fullName : "Người dùng ẩn danh",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colorBrownText),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.05), borderRadius: BorderRadius.circular(15)),
                    child: Text("@${currentStudent.username}", style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                  ),
                  const SizedBox(height: 15),

                  // ĐIỀU KIỆN HIỂN THỊ NÚT
                  if (widget.isMe)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async { 
                              // Chờ EditProfilePage đóng và trả về kết quả
                              final bool? shouldReload = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProfilePage(student: currentStudent),
                                ),
                              );
                              
                              if (shouldReload == true) {
                                _reloadFullProfile(); // Load lại Avatar và Tên mới
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade300,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text("Chỉnh sửa", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
                          child: IconButton(
                            icon: const Icon(Icons.person_add_alt_1, color: Colors.black),
                            onPressed: _showSearchDialog, 
                          ),
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () { 
                          // TODO: Thêm API Add Friend ở đây
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Đã gửi lời mời kết bạn!"))
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E293B), 
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.person_add_alt_1, size: 22),
                        label: const Text("THÊM BẠN BÈ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // 2. PHẦN GIỮA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: colorTeal.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildGameStat(Icons.local_fire_department, colorOrange, currentStudent.streak.toString(), "Streak"),
                    _buildGameStat(Icons.bolt, colorNavy, currentStudent.weeklyExp.toString(), "Weekly EXP"),
                    _buildGameStat(Icons.star_rounded, colorTeal, currentStudent.totalExp.toString(), "Total EXP"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),

            // 3. TAB BAR VÀ DANH SÁCH
            const TabBar(
              indicatorColor: colorOrange,
              labelColor: colorOrange,
              unselectedLabelColor: colorBrownText,
              indicatorWeight: 3,
              tabs: [
                Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.assignment), SizedBox(width: 8), Text("Nhiệm vụ", style: TextStyle(fontWeight: FontWeight.bold))])),
                Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.military_tech), SizedBox(width: 8), Text("Huy hiệu", style: TextStyle(fontWeight: FontWeight.bold))])),
              ],
            ),
            Expanded(
              child: TabBarView(children: [_buildMissionList(), _buildBadgeList()]),
            ),
          ],
        ),
      ),
    );
  }

  void _goToDetail(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RelationshipDetailPage(studentId: currentStudent.userID, initialIndex: index),
      ),
    );
  }

  Widget _buildProfileStat(String count, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(count, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w400)),
      ],
    );
  }

  Widget _buildGameStat(IconData icon, Color iconColor, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: iconColor.withOpacity(0.15), shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorBrownText)),
        Text(label, style: TextStyle(fontSize: 12, color: colorBrownText.withOpacity(0.6), fontWeight: FontWeight.w600)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          color: Colors.white,
          child: ListTile(
            leading: const Icon(Icons.check_circle_outline, color: colorGreen, size: 30),
            title: Text("Nhiệm vụ hàng ngày #${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text("Tiến độ: 5/10 từ"),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          color: Colors.white,
          child: ListTile(
            leading: const Icon(Icons.shield, color: colorOrange, size: 35),
            title: Text("Huy hiệu Chiến binh #${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text("Loại: Streak Badge"),
          ),
        );
      },
    );
  }
}
