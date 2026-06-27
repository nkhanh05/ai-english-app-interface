import 'package:flutter/material.dart' hide Badge;

// Đảm bảo import đúng đường dẫn tới các file Model và Service của bạn
import '../../models/badge/Badge.dart';
import '../../models/badge/ExpBadge.dart';
import '../../models/badge/FriendBadge.dart';
import '../../models/badge/StreakBadge.dart';
import '../../service/BadgeService.dart';
import 'state/global_state.dart';

class BadgeManagementTab extends StatefulWidget {
  const BadgeManagementTab({Key? key}) : super(key: key);

  @override
  State<BadgeManagementTab> createState() => _BadgeManagementTabState();
}

class _BadgeManagementTabState extends State<BadgeManagementTab> {
  List<Badge> allBadges = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    allBadges = await BadgeService.getAllBadges();
    setState(() => isLoading = false);
  }

  void _showForm(BuildContext context, String type, [Badge? badge]) {
    final isEditing = badge != null;
    final nameCtrl = TextEditingController(text: badge?.badgeName ?? '');
    final descCtrl = TextEditingController(text: badge?.description ?? '');

    int requireValue = 0;
    if (badge is ExpBadge) requireValue = badge.expRequire;
    if (badge is FriendBadge) requireValue = badge.friendRequire;
    if (badge is StreakBadge) requireValue = badge.streakCount;

    final requireCtrl = TextEditingController(
      text: requireValue > 0 ? requireValue.toString() : '',
    );

    String requireLabel = 'Giá trị yêu cầu';
    if (type == 'Exp') requireLabel = 'Số kinh nghiệm yêu cầu';
    if (type == 'Friend') requireLabel = 'Số bạn bè yêu cầu';
    if (type == 'Streak') requireLabel = 'Số streak yêu cầu';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Sửa Huy Hiệu' : 'Thêm Huy Hiệu'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Tên huy hiệu'),
              ),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Mô tả'),
              ),
              TextField(
                controller: requireCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: requireLabel),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty || requireCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Dữ liệu không hợp lệ!')),
                );
                return;
              }

              // Hiện vòng xoay chờ API
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    const Center(child: CircularProgressIndicator()),
              );

              bool success = false;
              int requireVal = int.tryParse(requireCtrl.text) ?? 0;

              // NẾU LÀ SỬA (UPDATE)
              if (isEditing && badge?.badgeID != null) {
                success = await BadgeService.updateBadge(
                  badge!.badgeID!, // Truyền ID vào đây
                  badgeName: nameCtrl.text,
                  description: descCtrl.text,
                  category: type,
                  type: type,
                  expRequire: type == 'Exp' ? requireVal : null,
                  friendRequire: type == 'Friend' ? requireVal : null,
                  streakCount: type == 'Streak' ? requireVal : null,
                );
              }
              // NẾU LÀ THÊM MỚI (CREATE)
              else {
                success = await BadgeService.addBadge(
                  badgeName: nameCtrl.text,
                  description: descCtrl.text,
                  category: type,
                  type: type,
                  adminID: currentAdminNotifier.value!.userID,
                  expRequire: type == 'Exp' ? requireVal : null,
                  friendRequire: type == 'Friend' ? requireVal : null,
                  streakCount: type == 'Streak' ? requireVal : null,
                );
              }

              Navigator.pop(context); // Tắt loading xoay xoay
              Navigator.pop(ctx); // Đóng Dialog form

              if (success) {
                _loadData(); // Load lại bảng danh sách
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cập nhật huy hiệu thành công!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lỗi khi cập nhật!'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Phát hành'),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeTable(String type, List<Badge> badges) {
    if (badges.isEmpty)
      return const Center(child: Text('Không có huy hiệu nào'));

    String reqColName = 'Yêu cầu';
    if (type == 'Exp') reqColName = 'Số kinh nghiệm yêu cầu';
    if (type == 'Friend') reqColName = 'Số bạn bè yêu cầu';
    if (type == 'Streak') reqColName = 'Số streak yêu cầu';

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          const DataColumn(label: Text('STT')),
          const DataColumn(label: Text('Tên huy hiệu')),
          const DataColumn(label: Text('Mô tả')),
          DataColumn(label: Text(reqColName)),
          const DataColumn(label: Text('Hành động')),
        ],
        rows: badges.asMap().entries.map((entry) {
          int idx = entry.key + 1;
          Badge b = entry.value;

          String requireText = '';
          if (b is ExpBadge) requireText = b.expRequire.toString();
          if (b is FriendBadge) requireText = b.friendRequire.toString();
          if (b is StreakBadge) requireText = b.streakCount.toString();

          return DataRow(
            cells: [
              DataCell(Text(idx.toString())),
              DataCell(Text(b.badgeName)),
              DataCell(Text(b.description)),
              DataCell(Text(requireText)),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showForm(context, type, b),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        // Xác nhận xóa
                        bool confirm =
                            await showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Xác nhận xóa'),
                                content: const Text(
                                  'Bạn có chắc chắn muốn xóa huy hiệu này?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Hủy'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Xóa'),
                                  ),
                                ],
                              ),
                            ) ??
                            false;

                        if (confirm && b.badgeID != null) {
                          bool success = await BadgeService.deleteBadge(
                            b.badgeID!,
                          );
                          if (success) _loadData();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expBadges = allBadges.whereType<ExpBadge>().toList();
    final friendBadges = allBadges.whereType<FriendBadge>().toList();
    final streakBadges = allBadges.whereType<StreakBadge>().toList();

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Huy hiệu kinh nghiệm'),
              Tab(text: 'Huy hiệu bạn bè'),
              Tab(text: 'Huy hiệu Streak'),
            ],
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    children: [
                      Scaffold(
                        body: _buildBadgeTable('Exp', expBadges),
                        floatingActionButton: FloatingActionButton.extended(
                          onPressed: () => _showForm(context, 'Exp'),
                          label: const Text('Thêm mới'),
                          icon: const Icon(Icons.add),
                        ),
                      ),
                      Scaffold(
                        body: _buildBadgeTable('Friend', friendBadges),
                        floatingActionButton: FloatingActionButton.extended(
                          onPressed: () => _showForm(context, 'Friend'),
                          label: const Text('Thêm mới'),
                          icon: const Icon(Icons.add),
                        ),
                      ),
                      Scaffold(
                        body: _buildBadgeTable('Streak', streakBadges),
                        floatingActionButton: FloatingActionButton.extended(
                          onPressed: () => _showForm(context, 'Streak'),
                          label: const Text('Thêm mới'),
                          icon: const Icon(Icons.add),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
