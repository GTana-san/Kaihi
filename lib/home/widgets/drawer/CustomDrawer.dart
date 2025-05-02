import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDrawer extends StatelessWidget {
  final User? user;

  const CustomDrawer({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue[100]),
            child: Text('メニュー', style: GoogleFonts.pacifico(fontSize: 24)),
          ),

          ListTile(
            leading: const Icon(Icons.home),
            title: Text('ホーム', style: GoogleFonts.roboto()),
            onTap: () {
              Navigator.of(context).pop(); // Drawerを閉じる
              Navigator.of(context).popUntil((route) => route.isFirst); // 最初の画面まで戻る
            },
          ),

          ListTile(
            leading: const Icon(Icons.person),
            title: Text('マイページ', style: GoogleFonts.roboto()),
            onTap: () {
              /*if (user != null) {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => MyPage(currentUser: user, userId: user!.uid),
                ));
              }*/
            },
          ),

          ListTile(
            leading: const Icon(Icons.search),
            title: Text('ユーザー検索', style: GoogleFonts.roboto()), // ← 新規追加
            onTap: () {
              /*Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => UserSearchPage(user: user),
              ));*/
            },
          ),

          ListTile(
            leading: const Icon(Icons.casino),
            title: Text('チンチロ', style: GoogleFonts.roboto()),
            onTap: () {
              /*Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const ChinchiroPage(), // ChinchiroPage は chinchiro.dart に定義されていると仮定
              ));*/
            },
          ),

          ListTile(
            leading: const Icon(Icons.logout),
            title: Text('ログアウト', style: GoogleFonts.roboto()),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
      ),
    );
  }
}