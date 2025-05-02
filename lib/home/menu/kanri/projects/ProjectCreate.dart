import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestoreを使うために必要

class ProjectCreatePage extends StatefulWidget {
  final User user;

  const ProjectCreatePage({super.key, required this.user});

  @override
  State<ProjectCreatePage> createState() => _ProjectCreatePageState();
}

class _ProjectCreatePageState extends State<ProjectCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _projectNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final name = _projectNameController.text.trim();
      final description = _descriptionController.text.trim();

      try {
        final DocumentReference docRef = await FirebaseFirestore.instance.collection('projects').add({
          'name': name,
          'description': description,
          'created_by': widget.user.uid,
          'created_at': Timestamp.now(),
          'managers': [widget.user.uid],
        });

        // ユーザーの project_ids に追加
        final userDocRef = FirebaseFirestore.instance.collection('users').doc(widget.user.uid);
        await userDocRef.set({
          'project_ids': FieldValue.arrayUnion([docRef.id]),
        }, SetOptions(merge: true)); // ← 上書きでなくマージ！

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('プロジェクト「$name」を作成しました')),
        );

        Navigator.pop(context); // 成功したら前の画面に戻る
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('作成に失敗しました: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プロジェクト作成'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _projectNameController,
                decoration: const InputDecoration(
                  labelText: 'プロジェクト名',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? '入力してください' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '説明（任意）',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.check),
                label: const Text('作成する'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
