import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';

import 'dashBoard/dashBoard.dart';
import 'input/input.dart';
import 'kanri/kanri.dart';

class MenuPage extends StatefulWidget {
  final User user;

  MenuPage({super.key, required this.user});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildNavItem({
    required bool selected,
    required IconData filledIcon,
    required IconData outlinedIcon,
    required String label,
    required int index,
  }) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            selected ? filledIcon : outlinedIcon,
            size: 28,
            color: Colors.black,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(user: widget.user),
      InputPage(user: widget.user,),
      KanriPage(user: widget.user,),
    ];

    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // ← タップでキーボードを閉じる
    child: Scaffold(
      body:IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, -1),
              blurRadius: 4,
            ),
          ],
        ),
        padding: const EdgeInsets.only(top: 12, bottom: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              selected: _selectedIndex == 0,
              filledIcon: Icons.home,
              outlinedIcon: Icons.home_outlined,
              label: 'ホーム',
              index: 0,
            ),
            _buildNavItem(
              selected: _selectedIndex == 1,
              filledIcon: Icons.assignment,
              outlinedIcon: Icons.assignment_outlined,
              label: '申請',
              index: 1,
            ),
            _buildNavItem(
              selected: _selectedIndex == 2,
              filledIcon: Icons.admin_panel_settings,
              outlinedIcon: Icons.admin_panel_settings_outlined,
              label: '管理',
              index: 2,
            ),
          ],
        ),
      ),
    ),
    );
  }
}