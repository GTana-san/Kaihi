import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../widgets/lists/ProjectListView.dart';

class ProjectHome extends StatelessWidget {
  final User? currentUser;
  final bool doManage;

  const ProjectHome({super.key, required this.currentUser, this.doManage = false});

  Future<List<DocumentSnapshot>> _fetchUserProjects() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception("ユーザーがログインしていません");

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final projectIds = List<String>.from(userDoc.data()?['project_ids'] ?? []);

    if (projectIds.length > 10) {
      throw Exception("プロジェクト数が多すぎます（最大10件まで表示可能）");
    }

    if (projectIds.isEmpty) return [];

    // 最大10件まで
    final query = await FirebaseFirestore.instance
        .collection('projects')
        .where(FieldPath.documentId, whereIn: projectIds.take(10).toList())
        .orderBy('created_at', descending: true)
        .get();

    return query.docs;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DocumentSnapshot>>(
      future: _fetchUserProjects(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('エラーが発生しました'));
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data ?? [];

        if (docs.isEmpty) {
          return const Center(child: Text('プロジェクトがまだありません'));
        }

        return ProjectListView(
          projectDocs: docs,
          currentUserId: currentUser!.uid,
          doManage: doManage,
        );
      },
    );
  }
}

