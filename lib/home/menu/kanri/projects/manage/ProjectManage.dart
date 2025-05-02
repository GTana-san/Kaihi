import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'summary/summary.dart';
import 'package:intl/intl.dart';
import 'approve/approve.dart';

class ProjectManagePage extends StatelessWidget {
  final DocumentSnapshot projectDoc;
  final bool manage;

  const ProjectManagePage({
    super.key,
    required this.projectDoc,
    required this.manage,
  });

  @override
  Widget build(BuildContext context) {
    final data = projectDoc.data() as Map<String, dynamic>;

    final String name = data['name'] ?? '名称未設定';
    final Timestamp createdAt = data['created_at'] ?? Timestamp.now();
    final String formattedDate = DateFormat('yyyy/MM/dd HH:mm').format(createdAt.toDate());

    return Scaffold(
      appBar: AppBar(
        title: Text(manage ? '管理者モード' : '閲覧モード'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('作成日: $formattedDate', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            ProjectSummaryCard(data: data),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ApprovePage(projectId: projectDoc.id,)),
                );
              },
              child: Card(
                color: Colors.green.shade50,
                child: const ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.green),
                  title: Text('承認ページ'),
                  subtitle: Text('承認が必要な申請を確認'),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
