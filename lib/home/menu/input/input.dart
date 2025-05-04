import 'package:flutter/material.dart';
import '../../widgets/drawer/CustomDrawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ProjectInput/ProjectInput.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InputPage extends StatefulWidget {
  final User user;

  const InputPage({super.key, required this.user});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  DocumentSnapshot? _selectedProject;
  late String userId;

  @override
  void initState() {
    super.initState();
    userId = widget.user.uid;
  }


  Future<void> _showProjectSelector() async {
    // ユーザードキュメントを取得
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    final List<dynamic> projectIds = userDoc.data()?['project_ids'] ?? [];

    if (projectIds.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('プロジェクトが登録されていません')),
        );
      }
      return;
    }

// プロジェクトIDリストをもとにプロジェクトを取得
    final projectsQuery = await FirebaseFirestore.instance
        .collection('projects')
        .where(FieldPath.documentId, whereIn: projectIds)
        .orderBy('created_at', descending: true)
        .get();

    final projects = projectsQuery.docs;

    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        children: projects.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = data['name'] ?? '名称未設定';
          return ListTile(
            title: Text(name),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _selectedProject = doc;
              });
            },
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final projectName = _selectedProject?.data() != null
        ? (_selectedProject!.data() as Map<String, dynamic>)['name'] ?? 'プロジェクト選択'
        : 'プロジェクト選択';

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _showProjectSelector,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                projectName,
                style: const TextStyle(
                  decoration: TextDecoration.underline,
                  decorationStyle: TextDecorationStyle.dashed,
                  decorationColor: Colors.black54,
                  decorationThickness: 1,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, size: 20, color: Colors.black54),
            ],
          ),
        ),
      ),
      drawer: CustomDrawer(user: widget.user),
      body: _selectedProject == null
          ? const Center(child: Text('プロジェクトを選択してください'))
          : ProjectInputPage(
        user: widget.user,
        projectDoc: _selectedProject,
      ),
    );
  }
}
