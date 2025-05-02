import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_fonts/google_fonts.dart';
import 'menu/MenuPage.dart';
import 'widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _email = '';
  String _password = '';

  Future<void> createUserDoc(User user) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({
        'created_at': FieldValue.serverTimestamp(),
        'email': user.email,
        'uid': user.uid,
        'is_anonymous': user.isAnonymous,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue[100]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final userCredential = await FirebaseAuth.instance.signInAnonymously();
                      final user = userCredential.user;
                      showCustomSnackBar(context, "ゲストとしてログインしました", isError: false);
                      if(user != null) {
                        await createUserDoc(user);

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => MenuPage(user: user,)),
                        );
                      }
                    } catch (e) {
                      showCustomSnackBar(context, "ゲストログインエラー: ${e.toString()}");
                    }
                  },
                  child: Text('ゲストモードで続ける', style: GoogleFonts.roboto()),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
                      if (googleUser == null) return;

                      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

                      final credential = GoogleAuthProvider.credential(
                        accessToken: googleAuth.accessToken,
                        idToken: googleAuth.idToken,
                      );

                      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
                      final user = userCredential.user;

                      if(user != null) {
                        await createUserDoc(user);

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => MenuPage(user:user)),
                        );
                      }
                    } catch (e) {
                      showCustomSnackBar(context, "Googleログインエラー");
                    }
                  },
                  child: Text('Googleアカウントでログイン', style: GoogleFonts.roboto()),
                ),
                SizedBox(height: 24),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'メールアドレス'),
                  onChanged: (String value) {
                    setState(() {
                      _email = value;
                    });
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'パスワード'),
                  obscureText: true,
                  onChanged: (String value) {
                    setState(() {
                      _password = value;
                    });
                  },
                ),
                ElevatedButton(
                  child: const Text('ユーザ登録'),
                  onPressed: () async {
                    if (_email.isEmpty || _password.isEmpty) {
                      showCustomSnackBar(context, "メールアドレスとパスワードを入力してください");
                      return;
                    }
                    try {
                      final User? user = (await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(email: _email, password: _password))
                          .user;
                      if (user != null) {
                        await createUserDoc(user);
                        showCustomSnackBar(context, "ユーザ登録しました: ${user.email}", isError: false);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => MenuPage(user: user,)),
                        );
                      }
                    } catch (e) {
                      showCustomSnackBar(context, "ユーザ登録エラー: ${e.toString()}");
                    }
                  },
                ),
                ElevatedButton(
                  child: Text(
                    'ログイン',
                    style: GoogleFonts.lobster(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  onPressed: () async {
                    if (_email.isEmpty || _password.isEmpty) {
                      showCustomSnackBar(context, "メールアドレスとパスワードを入力してください");
                      return;
                    }
                    try {
                      final User? user = (await FirebaseAuth.instance
                          .signInWithEmailAndPassword(email: _email, password: _password))
                          .user;
                      if (user != null) {
                        showCustomSnackBar(context, "ログインしました: ${user.email}", isError: false);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => MenuPage(user: user,)),
                        );
                      }
                    } catch (e) {
                      showCustomSnackBar(context, "ログインエラー: ${e.toString()}");
                    }
                  },
                ),
                TextButton(
                  onPressed: () async {
                    if (_email.isEmpty) {
                      showCustomSnackBar(context, "メールアドレスを入力してください");
                      return;
                    }
                    try {
                      await FirebaseAuth.instance.sendPasswordResetEmail(email: _email);
                      showCustomSnackBar(context, "パスワードリセットメールを送信しました", isError: false);
                    } catch (e) {
                      showCustomSnackBar(context, "パスワードリセットエラー: ${e.toString()}");
                    }
                  },
                  child: Text(
                    'パスワードを忘れた場合はこちら',
                    style: GoogleFonts.roboto(
                      color: Colors.blue[700],
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}