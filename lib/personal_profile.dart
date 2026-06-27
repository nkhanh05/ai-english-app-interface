import 'package:flutter/material.dart' hide Badge;
import '/models/user/Student.dart';
import 'shared_widgets/constants.dart';
import '/service/StudentService.dart';
import '/shared_widgets/shared_appbar.dart';
import '/shared_widgets/shared_endDrawer.dart';
import 'relationship_detail.dart';
import 'edit_profile_page.dart';
import '/state/global_state.dart'; // <--- IMPORT GLOBAL STATE ĐỂ LẤY ID USER ĐANG ĐĂNG NHẬP
import 'models/badge/Badge.dart';
import 'models/badge/ExpBadge.dart';
import 'models/badge/FriendBadge.dart';
import 'models/badge/StreakBadge.dart';
import 'models/mission/FriendMission.dart';
import 'models/mission/Mission.dart';
import 'models/mission/WordMission.dart';

// THÊM IMPORT CHO SERVICE
import '/service/BadgeService.dart';
import '/service/MissionService.dart';

// Định nghĩa các trạng thái quan hệ để dễ quản lý logic UI
enum RelationshipStatus {
  friends, // Cả 2 cùng follow nhau -> Bạn bè
  requestSent, // Mình đã follow họ, nhưng họ chưa follow mình -> Đã gửi lời mời
  pendingAccept, // Họ follow mình, nhưng mình chưa follow lại -> Chấp nhận lời mời
  none, // Chưa ai follow ai -> Thêm bạn bè
}

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
  bool isActionLoading = false; // Biến chặn bấm nút liên tục khi đang call API

  // Khai báo thêm biến chứa dữ liệu huy hiệu và nhiệm vụ
  List<Badge> myBadges = [];
  List<StudentMissionDetail> myMissions = [];

  late Student currentStudent;

  @override
  void initState() {
    super.initState();
    currentStudent = widget.student;

    // Gọi tải dữ liệu khi mở màn hình
    _loadRelationships();
    _loadBadgesAndMissions();
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
            // 1. PHẦN ĐẦU (AVATAR VÀ CHỈ SỐ BẠN BÈ)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 15.0,
              ),
              decoration: const BoxDecoration(
                color: Colors.white54,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
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
                        backgroundImage:
                            currentStudent.avatarUrl?.isNotEmpty == true
                            ? NetworkImage(currentStudent.avatarUrl!)
                            : null,
                        child: currentStudent.avatarUrl?.isEmpty ?? true
                            ? const Icon(
                                Icons.person,
                                size: 45,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            InkWell(
                              onTap: () => _goToDetail(0),
                              child: _buildProfileStat(
                                friends.length.toString(),
                                "bạn bè",
                              ),
                            ),
                            InkWell(
                              onTap: () => _goToDetail(1),
                              child: _buildProfileStat(
                                followers.length.toString(),
                                "người theo dõi",
                              ),
                            ),
                            InkWell(
                              onTap: () => _goToDetail(2),
                              child: _buildProfileStat(
                                following.length.toString(),
                                "đang theo dõi",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Text(
                    currentStudent.fullName.isNotEmpty
                        ? currentStudent.fullName
                        : "Người dùng ẩn danh",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: colorBrownText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      "@${currentStudent.username}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // ĐIỀU KIỆN HIỂN THỊ NÚT
                  if (widget.isMe)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final bool? shouldReload = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditProfilePage(student: currentStudent),
                                ),
                              );
                              if (shouldReload == true) _reloadFullProfile();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade300,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "Chỉnh sửa",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.person_add_alt_1,
                              color: Colors.black,
                            ),
                            onPressed: _showSearchDialog,
                          ),
                        ),
                      ],
                    )
                  else
                    _buildRelationshipButton(),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // 2. PHẦN GIỮA (CHỈ SỐ GAME)
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
                      colorOrange,
                      currentStudent.streak.toString(),
                      "Streak",
                    ),
                    _buildGameStat(
                      Icons.bolt,
                      colorNavy,
                      currentStudent.weeklyExp.toString(),
                      "Weekly EXP",
                    ),
                    _buildGameStat(
                      Icons.star_rounded,
                      colorTeal,
                      currentStudent.totalExp.toString(),
                      "Total EXP",
                    ),
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

  // ==================== LOGIC TẢI DỮ LIỆU ====================

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
        isActionLoading = false;
      });
    }
  }

  Future<void> _loadBadgesAndMissions() async {
    try {
      final int studentId = currentStudent.userID;

      final results = await Future.wait([
        BadgeService.getOwnedBadges(studentId),
        MissionService.getStudentMissions(studentId),
      ]);

      if (mounted) {
        setState(() {
          myBadges = results[0] as List<Badge>;
          myMissions = results[1] as List<StudentMissionDetail>;
        });
      }
    } catch (e) {
      debugPrint("❌ Lỗi khi tải badges và missions: $e");
    }
  }

  Future<void> _reloadFullProfile() async {
    final freshStudent = await StudentService().getProfile(
      currentStudent.userID,
    );
    if (freshStudent != null && mounted) {
      setState(() {
        currentStudent = freshStudent;
      });
    }
    _loadRelationships();
    _loadBadgesAndMissions();
  }

  // ==================== LOGIC XỬ LÝ RELATIONSHIP ====================

  RelationshipStatus _getRelationshipStatus() {
    final myId = currentStudentNotifier.value?.userID;
    if (myId == null) return RelationshipStatus.none;

    bool iFollowThem = followers.any((user) => user.userID == myId);
    bool theyFollowMe = following.any((user) => user.userID == myId);

    if (iFollowThem && theyFollowMe) return RelationshipStatus.friends;
    if (iFollowThem && !theyFollowMe) return RelationshipStatus.requestSent;
    if (!iFollowThem && theyFollowMe) return RelationshipStatus.pendingAccept;

    return RelationshipStatus.none;
  }

  Future<void> _handleRelationshipAction(
    RelationshipStatus currentStatus,
  ) async {
    final myId = currentStudentNotifier.value?.userID;
    if (myId == null) return;

    final targetId = currentStudent.userID;
    bool success = false;

    setState(() => isActionLoading = true);

    if (currentStatus == RelationshipStatus.none ||
        currentStatus == RelationshipStatus.pendingAccept) {
      success = await StudentService.followUser(myId, targetId);
    } else if (currentStatus == RelationshipStatus.requestSent ||
        currentStatus == RelationshipStatus.friends) {
      success = await StudentService.unfollowUser(myId, targetId);
    }

    if (success) {
      await _loadRelationships();
    } else {
      setState(() => isActionLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lỗi hệ thống, vui lòng thử lại!")),
        );
      }
    }
  }

  Widget _buildRelationshipButton() {
    if (isActionLoading) {
      return const Center(child: CircularProgressIndicator(color: colorOrange));
    }

    final status = _getRelationshipStatus();

    String text = "";
    IconData icon = Icons.person_add_alt_1;
    Color bgColor = const Color(0xFF1E293B);
    Color textColor = Colors.white;

    switch (status) {
      case RelationshipStatus.friends:
        text = "BẠN BÈ";
        icon = Icons.people;
        bgColor = colorTeal;
        break;
      case RelationshipStatus.requestSent:
        text = "ĐÃ GỬI LỜI MỜI";
        icon = Icons.how_to_reg;
        bgColor = Colors.grey.shade400;
        textColor = Colors.black87;
        break;
      case RelationshipStatus.pendingAccept:
        text = "CHẤP NHẬN LỜI MỜI";
        icon = Icons.person_add;
        bgColor = colorOrange;
        break;
      case RelationshipStatus.none:
      default:
        text = "THÊM BẠN BÈ";
        icon = Icons.person_add_alt_1;
        break;
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _handleRelationshipAction(status),
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        icon: Icon(icon, size: 22),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  // ==================================================================

  void _showSearchDialog() {
    final TextEditingController searchController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            "Thêm bạn bè",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: "Nhập username (vd: khanh05)",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: colorOrange),
              onPressed: () async {
                final username = searchController.text.trim();
                if (username.isNotEmpty) {
                  Navigator.pop(dialogContext);

                  final foundUser = await StudentService.searchByUsername(
                    username,
                  );

                  if (foundUser != null && mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PersonalProfilePage(
                          student: foundUser,
                          isMe:
                              foundUser.userID ==
                              currentStudentNotifier.value?.userID,
                        ),
                      ),
                    );
                  } else if (mounted) {
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

  void _goToDetail(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RelationshipDetailPage(
          studentId: currentStudent.userID,
          initialIndex: index,
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black87,
            fontWeight: FontWeight.w400,
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

  // ==================== WIDGET BUILDER ====================

  Widget _buildMissionList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: colorOrange));
    }

    if (myMissions.isEmpty) {
      return const Center(child: Text('Chưa có nhiệm vụ nào.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myMissions.length,
      itemBuilder: (context, index) {
        final detail = myMissions[index];
        final mission = detail.mission;

        String progressText = "Tiến độ: ${detail.progress}";
        if (mission is WordMission) {
          progressText += "/${mission.wordRequire} từ";
        } else if (mission is FriendMission) {
          progressText += "/${mission.friendRequire} bạn";
        }

        final isFinished = detail.status == 'finished';

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          color: Colors.white,
          child: ListTile(
            leading: Icon(
              isFinished ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isFinished ? colorGreen : Colors.grey,
              size: 30,
            ),
            title: Text(
              mission.missionName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mission.description),
                const SizedBox(height: 4),
                Text(
                  progressText,
                  style: TextStyle(
                    color: isFinished ? colorGreen : Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadgeList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: colorOrange));
    }

    if (myBadges.isEmpty) {
      return const Center(child: Text('Bạn chưa sở hữu huy hiệu nào.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myBadges.length,
      itemBuilder: (context, index) {
        final badge = myBadges[index];

        String specificRequirement = "";

        if (badge is ExpBadge) {
          specificRequirement = "Yêu cầu: Đạt từ ${badge.expRequire} EXP";
        } else if (badge is FriendBadge) {
          specificRequirement =
              "Yêu cầu: Kết bạn với ${badge.friendRequire} người";
        } else if (badge is StreakBadge) {
          specificRequirement =
              "Yêu cầu: Duy trì chuỗi ${badge.streakCount} ngày";
        }

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          color: Colors.white,
          child: ListTile(
            leading: const Icon(Icons.shield, color: colorOrange, size: 35),
            title: Text(
              badge.badgeName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(badge.description),
                const SizedBox(height: 4),
                if (specificRequirement.isNotEmpty) ...[
                  Text(
                    specificRequirement,
                    style: const TextStyle(
                      color: colorOrange,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  "Phân loại: ${badge.type}",
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
