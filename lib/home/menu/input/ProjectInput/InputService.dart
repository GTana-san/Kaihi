import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> submitApplication({
  required DocumentReference projectRef,
  required String type,
  required String name,
  required DateTime date,
  required String title,
  required int amount,
  String? memo,
  List<String> imageUrls = const [],
}) async {
  await projectRef.collection('requests').add({
    'type': type,
    'name': name,
    'date': Timestamp.fromDate(date),
    'title': title,
    'amount': amount,
    'memo': memo ?? '',
    'imageUrls': imageUrls,
    'created_at': Timestamp.now(),
  });
}