import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home/menu/input/ProjectInput/ProjectInput.dart';

class ProjectInputPageWithId extends StatelessWidget {
  final String? projectId;
  const ProjectInputPageWithId({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    if (projectId == null) {
      return const Scaffold(body: Center(child: Text('プロジェクトIDが指定されていません')));
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('projects').doc(projectId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(body: Center(child: Text('プロジェクトが見つかりません')));
        }

        final projectData = snapshot.data!;
        final projectName = projectData['name'] ?? '無名プロジェクト';

        final user = FirebaseAuth.instance.currentUser;
        return Scaffold(
          appBar: AppBar(title: Text('$projectName')),
          body: ProjectInputPage(
            projectDoc: snapshot.data!,
            user: user,
          ),
        );
      },
    );
  }
}
