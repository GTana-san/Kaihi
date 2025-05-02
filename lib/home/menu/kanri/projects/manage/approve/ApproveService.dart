import 'package:cloud_firestore/cloud_firestore.dart';

class ApproveService {
  static Future<void> approveRequest({
    required String projectId,
    required String requestId,
  }) async {
    final ref = FirebaseFirestore.instance
        .collection('projects')
        .doc(projectId)
        .collection('requests')
        .doc(requestId);

    await ref.update({
      'status': '承認',
      'approved_at': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> rejectRequest({
    required String projectId,
    required String requestId,
  }) async {
    final ref = FirebaseFirestore.instance
        .collection('projects')
        .doc(projectId)
        .collection('requests')
        .doc(requestId);

    await ref.update({
      'status': '否認',
      'rejected_at': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> resetRequestStatus({
    required String projectId,
    required String requestId,
  }) async {
    final docRef = FirebaseFirestore.instance
        .collection('projects')
        .doc(projectId)
        .collection('requests')
        .doc(requestId);

    await docRef.update({'status': null});
  }
}
