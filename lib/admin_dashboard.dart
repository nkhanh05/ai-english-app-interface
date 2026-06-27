import 'package:flutter/material.dart';
import 'mission_management_tab.dart';
import 'badge_management_tab.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bảng điều khiển (Dashboard)'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.task), text: 'Quản lý Nhiệm vụ'),
              Tab(icon: Icon(Icons.shield), text: 'Quản lý Huy hiệu'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [MissionManagementTab(), BadgeManagementTab()],
        ),
      ),
    );
  }
}
