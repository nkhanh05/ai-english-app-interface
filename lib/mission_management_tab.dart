import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Đảm bảo import đúng đường dẫn tới các file Model và Service của bạn
import '../../models/mission/Mission.dart';
import '../../models/mission/FriendMission.dart';
import '../../models/mission/WordMission.dart';
import '/service/MissionService.dart';

class MissionManagementTab extends StatefulWidget {
  const MissionManagementTab({Key? key}) : super(key: key);

  @override
  State<MissionManagementTab> createState() => _MissionManagementTabState();
}

class _MissionManagementTabState extends State<MissionManagementTab> {
  List<Mission> allMissions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    allMissions = await MissionService.getAllMissions();
    setState(() => isLoading = false);
  }

  void _showForm(BuildContext context, String type, [Mission? mission]) {
    final isEditing = mission != null;
    final nameCtrl = TextEditingController(text: mission?.missionName ?? '');
    final descCtrl = TextEditingController(text: mission?.description ?? '');

    DateTime? startDate = mission?.startAt;
    DateTime? endDate = mission?.endAt;
    final startCtrl = TextEditingController(
      text: startDate != null ? DateFormat('yyyy-MM-dd').format(startDate) : '',
    );
    final endCtrl = TextEditingController(
      text: endDate != null ? DateFormat('yyyy-MM-dd').format(endDate) : '',
    );

    int requireValue = 0;
    if (mission is WordMission) requireValue = mission.wordRequire;
    if (mission is FriendMission) requireValue = mission.friendRequire;
    final requireCtrl = TextEditingController(
      text: requireValue > 0 ? requireValue.toString() : '',
    );
    final expCtrl = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> pickDate(
            TextEditingController ctrl,
            bool isStart,
          ) async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              setDialogState(() {
                ctrl.text = DateFormat('yyyy-MM-dd').format(picked);
                if (isStart)
                  startDate = picked;
                else
                  endDate = picked;
              });
            }
          }

          return AlertDialog(
            title: Text(
              isEditing ? 'Sửa Nhiệm Vụ $type' : 'Thêm Nhiệm Vụ $type',
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Tên nhiệm vụ',
                    ),
                  ),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: 'Mô tả'),
                  ),
                  TextField(
                    controller: startCtrl,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Ngày bắt đầu',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () => pickDate(startCtrl, true),
                  ),
                  TextField(
                    controller: endCtrl,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Ngày kết thúc',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () => pickDate(endCtrl, false),
                  ),
                  TextField(
                    controller: requireCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: type == 'Word'
                          ? 'Số từ yêu cầu'
                          : 'Số bạn bè yêu cầu',
                    ),
                  ),
                  TextField(
                    controller: expCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'EXP Thưởng'),
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

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) =>
                        const Center(child: CircularProgressIndicator()),
                  );

                  bool success = false;
                  int requireVal = int.tryParse(requireCtrl.text) ?? 0;

                  if (isEditing) {
                    success = await MissionService.updateMission(
                      mission!.missionID ?? 0,
                      missionName: nameCtrl.text,
                      description: descCtrl.text,
                      type: type,
                      startAt: startCtrl.text,
                      endAt: endCtrl.text,
                      wordRequire: type == 'Word' ? requireVal : null,
                      friendRequire: type == 'Friend' ? requireVal : null,
                    );
                  } else {
                    success = await MissionService.addMission(
                      missionName: nameCtrl.text,
                      description: descCtrl.text,
                      type: type,
                      adminID: 1,
                      startAt: startCtrl.text,
                      endAt: endCtrl.text,
                      wordRequire: type == 'Word' ? requireVal : null,
                      friendRequire: type == 'Friend' ? requireVal : null,
                    );
                  }

                  Navigator.pop(context); // Tắt loading
                  Navigator.pop(ctx); // Đóng form

                  if (success) _loadData();
                },
                child: const Text('Phát hành'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMissionTable(String type, List<Mission> missions) {
    if (missions.isEmpty)
      return const Center(child: Text('Không có nhiệm vụ nào'));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          const DataColumn(label: Text('STT')),
          const DataColumn(label: Text('Tên nhiệm vụ')),
          const DataColumn(label: Text('Mô tả')),
          const DataColumn(label: Text('Ngày bắt đầu')),
          const DataColumn(label: Text('Ngày kết thúc')),
          DataColumn(
            label: Text(type == 'Word' ? 'Số từ yêu cầu' : 'Số bạn bè yêu cầu'),
          ),
          const DataColumn(label: Text('Hành động')),
        ],
        rows: missions.asMap().entries.map((entry) {
          int idx = entry.key + 1;
          Mission m = entry.value;

          String requireText = '';
          if (m is WordMission) requireText = m.wordRequire.toString();
          if (m is FriendMission) requireText = m.friendRequire.toString();

          return DataRow(
            cells: [
              DataCell(Text(idx.toString())),
              DataCell(Text(m.missionName)),
              DataCell(Text(m.description)),
              DataCell(
                Text(
                  m.startAt != null
                      ? DateFormat('dd/MM/yyyy').format(m.startAt!)
                      : '',
                ),
              ),
              DataCell(
                Text(
                  m.endAt != null
                      ? DateFormat('dd/MM/yyyy').format(m.endAt!)
                      : '',
                ),
              ),
              DataCell(Text(requireText)),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showForm(context, type, m),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        bool confirm =
                            await showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Xác nhận xóa'),
                                content: const Text(
                                  'Bạn có chắc chắn muốn xóa nhiệm vụ này?',
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

                        if (confirm && m.missionID != null) {
                          bool success = await MissionService.deleteMission(
                            m.missionID!,
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
    final wordMissions = allMissions.whereType<WordMission>().toList();
    final friendMissions = allMissions.whereType<FriendMission>().toList();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Nhiệm vụ từ'),
              Tab(text: 'Nhiệm vụ bạn bè'),
            ],
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    children: [
                      Scaffold(
                        body: _buildMissionTable('Word', wordMissions),
                        floatingActionButton: FloatingActionButton.extended(
                          onPressed: () => _showForm(context, 'Word'),
                          label: const Text('Thêm mới'),
                          icon: const Icon(Icons.add),
                        ),
                      ),
                      Scaffold(
                        body: _buildMissionTable('Friend', friendMissions),
                        floatingActionButton: FloatingActionButton.extended(
                          onPressed: () => _showForm(context, 'Friend'),
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
