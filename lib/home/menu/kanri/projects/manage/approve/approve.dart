import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ApproveService.dart';
import '../../../../../widgets/ImagePager.dart';

class ApprovePage extends StatelessWidget {
  final String projectId;

  const ApprovePage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    final requestRef = FirebaseFirestore.instance
        .collection('projects')
        .doc(projectId)
        .collection('requests');

    return Scaffold(
      appBar: AppBar(title: const Text('申請の承認')),
      body: StreamBuilder<QuerySnapshot>(
        stream: requestRef.orderBy('created_at', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('エラーが発生しました'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('申請はありません'));
          }

          return ListView(
            padding: const EdgeInsets.all(8),
            children: docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final type = data['type'] ?? 'タイプなし';
              final title = data['title'] ?? '無題';
              final name = data['name'] ?? '名前なし';
              final amount = data['amount']?.toString() ?? '-';
              final memo = data['memo'] ?? '';
              final status = data['status'] ?? 'pending';
              final imageUrls = List<String>.from(data['imageUrls'] ?? []);

              final isExpense = type == '支出';
              final cardColor = isExpense ? Colors.yellow[100] : Colors.blue[100];
              final typeColor = isExpense ? Colors.orange[800] : Colors.blue[800];

              final isDenied = status == '否認';
              final isApproved = status == '承認';
              final isPending = status == 'pending';

              final cardBackground = isPending
                  ? cardColor
                  : Colors.grey[200];

              final borderSide = isDenied
                  ? BorderSide.none
                  : BorderSide(
                color: isExpense ? Colors.orange : Colors.blue,
                width: 2,
              );

              return Card(
                color: cardBackground,
                shape: RoundedRectangleBorder(
                  side: borderSide,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: DefaultTextStyle.merge(
              style: isDenied
              ? const TextStyle(color: Colors.grey)
                  : const TextStyle(color: Colors.black),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 左側：テキスト情報
                  Expanded(
                    child: DefaultTextStyle.merge(
                      style: isDenied
                          ? const TextStyle(color: Colors.grey)
                          : const TextStyle(color: Colors.black),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            type,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDenied ? Colors.grey : typeColor,
                            ),
                          ),
                          Text('申請者: $name'),
                          Text('題名: $title'),
                          Text('金額: ¥$amount'),
                          if (memo.isNotEmpty) Text('メモ: $memo'),
                          const SizedBox(height: 8),
                          ...(
                          isPending
                          ?[
                            Row(
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  onPressed: () async {
                                    await ApproveService.approveRequest(
                                      projectId: projectId,
                                      requestId: doc.id,
                                    );
                                  },
                                  child: const Text('承認',
                                      style: TextStyle(color: Colors.white)),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: () async {
                                    await ApproveService.rejectRequest(
                                      projectId: projectId,
                                      requestId: doc.id,
                                    );
                                  },
                                  child: const Text('否認',
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            )
            ] : [
                              Text(
                                '$status',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isApproved
                                      ? Colors.green
                                      : isDenied
                                      ? Colors.red
                                      : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size(0, 0),
                                    tapTargetSize: MaterialTapTargetSize
                                        .shrinkWrap,
                                  ),
                                  onPressed: () async {
                                    await ApproveService.resetRequestStatus(
                                      projectId: projectId,
                                      requestId: doc.id,
                                    );
                                  },
                                  child: Text(
                                    isApproved
                                        ? '承認を解除する'
                                        : '否認を解除する',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                            ]
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 右側：画像
                  if (imageUrls.isNotEmpty)
                    SizedBox(
                      width: 120,
                      child: ImagePager<String>(
                        imageUrls: imageUrls,
                        height: 100,
                        fit: BoxFit.cover,
                        enableFullscreen: true,
                        customBuilder: (context, urls, index) {
                          final url = urls[index];
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  url,
                                  fit: BoxFit.cover,
                                  height: 100,
                                  width: double.infinity,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return SizedBox(
                                      height: 100,
                                      child: Stack(
                                        children: [
                                          Container(
                                            color: Colors.grey[200], // 背景色
                                            width: double.infinity,
                                            height: 100,
                                          ),
                                          const Center(
                                            child: SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  errorBuilder: (_, __, ___) =>
                                  const Center(child: Text('画像を読み込めません')),
                                ),
                              ),
                              if (isDenied)
                                Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                ],
              ),
                ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

