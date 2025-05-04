/*import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:typed_data';
import 'dart:io' as io;
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'InputService.dart';

class ProjectInputPage extends StatefulWidget {
  final DocumentSnapshot? projectDoc;
  final User? user;

  const ProjectInputPage({super.key, this.user, this.projectDoc});

  @override
  State<ProjectInputPage> createState() => _ProjectInputPageState();
}

class _ProjectInputPageState extends State<ProjectInputPage> {
  String type = '支出';
  String? selectedName;
  DateTime selectedDate = DateTime.now();
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final memoController = TextEditingController();
  bool isSubmitting = false;

  List<String> nameOptions = [];

  // 画像関連（Web or Mobile）
  Uint8List? selectedImageBytes;
  io.File? selectedImageFile;

  @override
  void initState() {
    super.initState();
    _loadNameOptions();
  }

  Future<void> _loadNameOptions() async {
    final data = widget.projectDoc?.data() as Map<String, dynamic>?;
    if (data != null && data.containsKey('nameOptions')) {
      final List<dynamic> rawOptions = data['nameOptions'];
      setState(() {
        nameOptions = rawOptions.cast<String>();
      });
    }
  }

  Future<void> _addNewName() async {
    String? newName = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('名前を追加'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: '新しい名前を入力'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('キャンセル')),
            ElevatedButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) Navigator.of(context).pop(name);
              },
              child: const Text('追加'),
            ),
          ],
        );
      },
    );

    if (newName != null && newName.isNotEmpty) {
      setState(() {
        nameOptions.add(newName);
        selectedName = newName;
      });

      await widget.projectDoc!.reference.update({
        'nameOptions': FieldValue.arrayUnion([newName]),
      });
    }
  }

  void _resetForm() {
    setState(() {
      selectedDate = DateTime.now();
      titleController.clear();
      amountController.clear();
      memoController.clear();
      selectedImageBytes = null;
      selectedImageFile = null;
    });
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
      if (result != null && result.files.single.bytes != null) {
        setState(() {
          selectedImageBytes = result.files.single.bytes;
        });
      }
    } else {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          selectedImageFile = io.File(pickedFile.path);
        });
      }
    }
  }

  Future<String?> _uploadImage() async {
    try {
      final ref = FirebaseStorage.instance
          .ref('applications/${widget.projectDoc!.id}/${DateTime.now().millisecondsSinceEpoch}.jpg');

      UploadTask uploadTask;

      if (kIsWeb && selectedImageBytes != null) {
        uploadTask = ref.putData(selectedImageBytes!);
      } else if (selectedImageFile != null) {
        uploadTask = ref.putFile(selectedImageFile!);
      } else {
        return null;
      }

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectDoc = widget.projectDoc;

    if (projectDoc == null) {
      return const Center(
        child: Text('プロジェクトが選択されていません。', textAlign: TextAlign.center, style: TextStyle(color: Colors.redAccent)),
      );
    }

    final data = projectDoc.data() as Map<String, dynamic>;
    final String projectName = data['name'] ?? '名称未設定';
    final Timestamp createdAt = data['created_at'] ?? Timestamp.now();
    final String formattedDate = DateFormat('yyyy/MM/dd HH:mm').format(createdAt.toDate());

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // 区分
            Row(
              children: [
                const Text('区分:'),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: type,
                  items: ['支出', '収入']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => type = value);
                  },
                ),
              ],
            ),

            // 名前選択
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: '名前（必須）'),
              value: selectedName,
              items: [
                ...nameOptions.map((name) => DropdownMenuItem(value: name, child: Text(name))),
                const DropdownMenuItem(value: '__add__', child: Text('＋ 名前を追加')),
              ],
              onChanged: (value) async {
                if (value == '__add__') {
                  await _addNewName();
                } else {
                  setState(() {
                    selectedName = value;
                  });
                }
              },
            ),

            // 日付
            ListTile(
              title: Text('日付: ${DateFormat('yyyy/MM/dd').format(selectedDate)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => selectedDate = picked);
              },
            ),

            // 題名・金額・メモ
            TextFormField(controller: titleController, decoration: const InputDecoration(labelText: '題名（必須）')),
            TextFormField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '金額（必須）'),
            ),
            TextFormField(
              controller: memoController,
              decoration: const InputDecoration(labelText: 'メモ（任意）'),
              maxLines: 3,
            ),

            const SizedBox(height: 16),

            // 画像添付ボタン
            ElevatedButton.icon(
              icon: const Icon(Icons.attach_file),
              label: const Text('画像を添付'),
              onPressed: _pickImage,
            ),

            // プレビュー
            if (selectedImageBytes != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Image.memory(selectedImageBytes!, height: 100, width: 100, fit: BoxFit.cover),
              ),
            if (selectedImageFile != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Image.file(selectedImageFile!, height: 100, width: 100, fit: BoxFit.cover),
              ),

            // 登録ボタン
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                if (selectedName == null || titleController.text.isEmpty || amountController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('必須項目をすべて入力してください')));
                  return;
                }

                int amount;
                try {
                  amount = int.parse(amountController.text);
                } catch (_) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('金額は数字で入力してください')));
                  return;
                }

                setState(() => isSubmitting = true);

                String? imageUrl = await _uploadImage();

                try {
                  await submitApplication(
                    projectRef: widget.projectDoc!.reference,
                    type: type,
                    name: selectedName!,
                    date: selectedDate,
                    title: titleController.text,
                    amount: amount,
                    memo: memoController.text,
                    imageUrls: imageUrl != null ? [imageUrl] : [],
                  );

                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('申請が登録されました')));
                  _resetForm();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('エラーが発生しました: $e')));
                }

                setState(() => isSubmitting = false);
              },
              child: isSubmitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('申請を登録'),
            ),
          ],
        ),
      ),
    );
  }
}*/


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'InputService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../widgets/ImageUploadHelper.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProjectInputPage extends StatefulWidget {
  final DocumentSnapshot? projectDoc;
  final User? user;

  const ProjectInputPage({
    super.key,
    this.user,
    required this.projectDoc,
  });

  @override
  State<ProjectInputPage> createState() => _ProjectInputPageState();
}

class _ProjectInputPageState extends State<ProjectInputPage> {
  String type = '支出';
  String? selectedName;
  DateTime selectedDate = DateTime.now();
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final memoController = TextEditingController();
  bool isSubmitting = false;

  List<String> imageUrls = [];
  List<File> selectedImages = [];

  List<String> nameOptions = [];

  bool _isFirstLoad = true; // ← 一度だけ読み込むためのフラグ

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstLoad && widget.projectDoc != null) {
      _isFirstLoad = false;
      _loadNameOptions(); // ← projectDoc が読み込まれた後に実行されるように変更
    }else {
      debugPrint('projectDoc is null OR already loaded');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadNameOptions() async {
    final data = widget.projectDoc?.data() as Map<String, dynamic>?;

    debugPrint('Firestore data: $data');

    if (data != null && data.containsKey('nameOptions')) {
      final List<dynamic> rawOptions = data['nameOptions'];
      debugPrint('rawOptions: $rawOptions');

      setState(() {
        nameOptions = rawOptions.cast<String>();
      });
    }else{
      debugPrint('nameOptions が存在しない、または空です');
    }
  }

  Future<void> _addNewName() async {
    String? newName = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('名前を追加'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: '新しい名前を入力'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  Navigator.of(context).pop(name);
                }
              },
              child: const Text('追加'),
            ),
          ],
        );
      },
    );

    if (newName != null && newName.isNotEmpty) {
      setState(() {
        nameOptions.add(newName);
        selectedName = newName;
      });

      // Firestoreに保存
      await widget.projectDoc!.reference.update({
        'nameOptions': FieldValue.arrayUnion([newName]),
      });
    }
  }

  void _resetForm() {
    setState(() {
      selectedDate = DateTime.now();
      titleController.clear();
      amountController.clear();
      memoController.clear();
      selectedImages.clear();
    });
  }



  @override
  Widget build(BuildContext context) {
    final projectDoc = widget.projectDoc;

    if (projectDoc == null) {
      return const Center(
        child: Text(
          'プロジェクトが選択されていません。\n上の「プロジェクト選択」から選んでください。',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.redAccent),
        ),
      );
    }

    final data = projectDoc!.data() as Map<String, dynamic>;
    final String projectName = data['name'] ?? '名称未設定';
    final Timestamp createdAt = data['created_at'] ?? Timestamp.now();
    final String formattedDate = DateFormat('yyyy/MM/dd HH:mm').format(createdAt.toDate());

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // 区分（支出・収入）
            Row(
              children: [
                const Text('区分:'),
                const SizedBox(width: 16),
                StatefulBuilder(
                  builder: (context, setState) => DropdownButton<String>(
                    value: type,
                    items: ['支出', '収入']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => type = value);
                    },
                  ),
                ),
              ],
            ),

            // 名前
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: '名前（必須）'),
              value: selectedName,
              items: [
                ...nameOptions.map(
                      (name) => DropdownMenuItem(value: name, child: Text(name)),
                ),
                const DropdownMenuItem(
                  value: '__add__',
                  child: Text('＋ 名前を追加'),
                ),
              ],
              onChanged: (value) async {
                if (value == '__add__') {
                  await _addNewName();
                } else {
                  setState(() {
                    selectedName = value;
                  });
                }
              },
            ),

            // 日付
            StatefulBuilder(
              builder: (context, setState) => ListTile(
                title: Text('日付: ${DateFormat('yyyy/MM/dd').format(selectedDate)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => selectedDate = picked);
                  }
                },
              ),
            ),

            // 題名
            TextFormField(
              controller: titleController,
              decoration: const InputDecoration(labelText: '題名（必須）'),
            ),

            // 金額
            TextFormField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '金額（必須）'),
            ),

            // メモ
            TextFormField(
              controller: memoController,
              decoration: const InputDecoration(labelText: 'メモ（任意）'),
              maxLines: 3,
            ),

            const SizedBox(height: 16),

            // 画像添付ボタン（1枚のみ許可）
            ElevatedButton.icon(
              icon: const Icon(Icons.attach_file),
              label: const Text('画像を添付'),
              onPressed: () async {
                final picker = ImagePicker();
                final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    selectedImages = [File(pickedFile.path)]; // 1枚だけに制限
                  });
                }
              },
            ),

            // プレビュー表示
            if (selectedImages.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: selectedImages.asMap().entries.map((entry) {
                  final index = entry.key;
                  final file = entry.value;
                  return Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Image.file(file, height: 100, width: 100, fit: BoxFit.cover),
                      Positioned(
                        top: -8,
                        right: -8,
                        child: IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              selectedImages.removeAt(index);
                            });
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
              )
            ],

            // 登録ボタン
            ElevatedButton(
              onPressed: isSubmitting
                  ? null // ローディング中は無効化
                  : () async {
                if (selectedName == null ||
                    titleController.text.isEmpty ||
                    amountController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('必須項目をすべて入力してください')),
                  );
                  return;
                }

                int amount;
                try {
                  amount = int.parse(amountController.text);
                } catch (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('金額は数字で入力してください')),
                  );
                  return;
                }

                setState(() => isSubmitting = true); // ローディング開始

                imageUrls = [];
                for (final file in selectedImages) {
                  final url = await ImageUploadHelper.uploadImage(
                    file,
                    uploadPath: 'applications/${widget.projectDoc!.id}',
                  );
                  if (url != null) {
                    imageUrls.add(url);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('画像のアップロードに失敗しました')),
                    );
                    setState(() => isSubmitting = false);
                    return;
                  }
                }

                try {
                  await submitApplication(
                    projectRef: widget.projectDoc!.reference,
                    type: type,
                    name: selectedName!,
                    date: selectedDate,
                    title: titleController.text,
                    amount: amount,
                    memo: memoController.text,
                    imageUrls: imageUrls,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('申請が登録されました')),
                  );
                  _resetForm();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('エラーが発生しました: $e')),
                  );
                }

                setState(() => isSubmitting = false); // ローディング終了
              },
              child: isSubmitting
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
                  : const Text('申請を登録'),
            ),
          ],
        ),
      ),
    );
  }
}


