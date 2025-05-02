import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../menu/kanri/projects/manage/ProjectManage.dart';
import '../../menu/input/ProjectInput/ProjectInput.dart';

class ProjectListView extends StatelessWidget {
  final List<DocumentSnapshot> projectDocs;
  final String currentUserId;
  final bool doManage;

  const ProjectListView({
    super.key,
    required this.projectDocs,
    required this.currentUserId,
    this.doManage = false,
  });

  @override
  Widget build(BuildContext context) {
    if (projectDocs.isEmpty) {
      return const Center(child: Text('プロジェクトがまだありません'));
    }

    return ListView.builder(
      itemCount: projectDocs.length,
      itemBuilder: (context, index) {
        final data = projectDocs[index].data() as Map<String, dynamic>;
        final name = data['name'] ?? '名称未設定';
        final description = data['description'] ?? '';

        return ListTile(
          title: Text(name),
          subtitle: Text(description),
          leading: const Icon(Icons.folder),
          trailing: const Icon(Icons.chevron_right),
            onTap: () {
              final List<String> managers = List<String>.from(data['managers'] ?? []);
              final bool isManager = managers.contains(currentUserId);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                      return ProjectManagePage(
                        projectDoc: projectDocs[index],
                        manage: isManager,
                      );
                  },
                ),
              );
            }
        );
      },
    );
  }
}
