import 'package:flutter/material.dart';
import '../../widgets/drawer/CustomDrawer.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardPage extends StatelessWidget {
  final User user;

  const DashboardPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ホーム'),
      ),
      drawer: CustomDrawer(user: user),
      //body: const ChatInterface(),
    );
  }
}