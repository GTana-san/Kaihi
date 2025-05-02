import 'package:flutter/material.dart';
import '../../widgets/drawer/CustomDrawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'projects/ProjectCreate.dart';
import 'projects/ProjectHome.dart';

class KanriPage extends StatelessWidget {
  final User user;

  const KanriPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'プロジェクト作成',
            onPressed: () {
              // プロジェクト作成ページへ遷移
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProjectCreatePage(user: user),
                ),
              );
            },
          ),
        ],
      ),
      drawer: CustomDrawer(user: user),
      body: ProjectHome(currentUser: user, doManage: true,),
    );
  }
}