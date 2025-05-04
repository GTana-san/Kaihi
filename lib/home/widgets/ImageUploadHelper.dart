import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class ImageUploadHelper {
  static final _picker = ImagePicker();

  /// 画像を複数選んで、圧縮して、Firebaseにアップロード（Web 対応）
  static Future<List<String>> pickAndUploadImages({required String uploadPath}) async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles == null || pickedFiles.isEmpty) {
      return [];
    }

    List<String> downloadUrls = [];

    for (var picked in pickedFiles) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        final fileSize = bytes.length;
        const maxFileSize = 2 * 1024 * 1024;
        if (fileSize > maxFileSize) continue;
        final url = await uploadBytesToFirebase(bytes: bytes, uploadPath: uploadPath);
        if (url != null) downloadUrls.add(url);
      } else {
        final file = File(picked.path);
        final compressed = await compressImage(file);
        final fileSize = await compressed.length();
        const maxFileSize = 2 * 1024 * 1024;
        if (fileSize > maxFileSize) continue;
        final url = await uploadToFirebase(file: compressed, uploadPath: uploadPath);
        if (url != null) downloadUrls.add(url);
      }
    }

    return downloadUrls;
  }

  static Future<File> compressImage(File file) async {
    final dir = await Directory.systemTemp.createTemp();
    final targetPath = '${dir.path}/${const Uuid().v4()}.jpg';

    final XFile? compressedXFile = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
    );

    return compressedXFile != null ? File(compressedXFile.path) : file;
  }

  static Future<String?> uploadToFirebase({required File file, required String uploadPath}) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child(uploadPath)
          .child('${const Uuid().v4()}.jpg');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Upload failed: $e');
      return null;
    }
  }

  static Future<String?> uploadBytesToFirebase({required Uint8List bytes, required String uploadPath}) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child(uploadPath)
          .child('${const Uuid().v4()}.jpg');
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      return await ref.getDownloadURL();
    } catch (e) {
      print('Web upload failed: $e');
      return null;
    }
  }

  static Future<String?> uploadImage(File file, {required String uploadPath}) async {
    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      final fileSize = bytes.length;
      const maxFileSize = 2 * 1024 * 1024;
      if (fileSize > maxFileSize) {
        throw Exception('画像サイズが2MBを超えています');
      }
      return await uploadBytesToFirebase(bytes: bytes, uploadPath: uploadPath);
    } else {
      final compressed = await compressImage(file);
      final fileSize = await compressed.length();
      const maxFileSize = 2 * 1024 * 1024;
      if (fileSize > maxFileSize) {
        throw Exception('画像サイズが2MBを超えています');
      }
      return await uploadToFirebase(file: compressed, uploadPath: uploadPath);
    }
  }

  static Future<String?> uploadImageBytes(Uint8List bytes, {required String uploadPath}) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child(uploadPath)
          .child('${const Uuid().v4()}.jpg');
      await ref.putData(bytes);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Upload failed: $e');
      return null;
    }
  }
}

/*import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class ImageUploadHelper {
  static final _picker = ImagePicker();

  /// 画像を複数選んで、圧縮して、Firebaseにアップロード
  static Future<List<String>> pickAndUploadImages({required String uploadPath}) async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles == null || pickedFiles.isEmpty) {
      return [];
    }

    List<String> downloadUrls = [];

    for (var picked in pickedFiles) {
      final file = File(picked.path);
      final compressed = await compressImage(file);

      final fileSize = await compressed.length();
      const maxFileSize = 2 * 1024 * 1024; // 2MB
      if (fileSize > maxFileSize) {
        continue; // デカすぎたらスキップ
      }

      final url = await uploadToFirebase(file: compressed, uploadPath: uploadPath);
      if (url != null) {
        downloadUrls.add(url);
      }
    }

    return downloadUrls;
  }

  static Future<File> compressImage(File file) async {
    final dir = await Directory.systemTemp.createTemp();
    final targetPath = '${dir.path}/${const Uuid().v4()}.jpg';

    final XFile? compressedXFile = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
    );

    return compressedXFile != null ? File(compressedXFile.path) : file;
  }

  static Future<String?> uploadToFirebase({required File file, required String uploadPath}) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child(uploadPath)
          .child('${const Uuid().v4()}.jpg');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Upload failed: $e');
      return null;
    }
  }

  static Future<String?> uploadImage(File file, {required String uploadPath}) async {
    final compressed = await compressImage(file);

    final fileSize = await compressed.length();
    const maxFileSize = 2 * 1024 * 1024; // 2MB

    if (fileSize > maxFileSize) {
      throw Exception('画像サイズが2MBを超えています');
    }

    return await uploadToFirebase(file: compressed, uploadPath: uploadPath);
  }
}*/