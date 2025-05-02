import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

void showCustomSnackBar(BuildContext context, String message, {bool isError = true}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: const TextStyle(fontSize: 18)),
      backgroundColor: isError ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 4),
    ),
  );
}

class HelpIconOverlay extends StatelessWidget {
  final VoidCallback onTap;

  const HelpIconOverlay({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      right: 8,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(4),
          child: const Icon(Icons.help_outline, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class HelpDialog extends StatelessWidget {
  final String imagePath;
  final String description;

  const HelpDialog({
    super.key,
    required this.imagePath,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(imagePath, fit: BoxFit.contain),
          const SizedBox(height: 12),
          Text(description),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('閉じる'),
        ),
      ],
    );
  }
}

class FullscreenImage extends StatelessWidget {
  final String imageUrl;

  const FullscreenImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => Scaffold(
            backgroundColor: Colors.black,
            body: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Center(
                child: InteractiveViewer(
                  child: Image.network(imageUrl),
                ),
              ),
            ),
          ),
        ));
      },
      child: Image.network(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
        const Center(child: Text('画像を読み込めません')),
      ),
    );
  }
}

/// タップでダイアログ全画面表示する画像ウィジェット
class TappableFullscreenImage extends StatelessWidget {
  final String imageUrl;
  final List<String> imageUrls;
  final int initialIndex;

  const TappableFullscreenImage({
    super.key,
    required this.imageUrl,
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showFullscreenImagePagerDialog(
          context: context,
          imageUrls: imageUrls,
          initialIndex: initialIndex,
        );
      },
      child: Image.network(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
        const Center(child: Text('画像を読み込めません')),
      ),
    );
  }
}

/// 半透明背景で画像全画面表示するモーダル
void showFullscreenImagePagerDialog({
  required BuildContext context,
  required List<String> imageUrls,
  required int initialIndex,

  Widget Function(BuildContext context, List<String> imageUrls, int index)? customBuilder,
}) {

  final controller = PageController(initialPage: initialIndex);

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    barrierColor: Colors.black.withOpacity(0.7),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, anim1, anim2) {
      return GestureDetector(
        onTap: () => Navigator.pop(context), // 背景タップで閉じる
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Stack(
              children: [
                PageView.builder(
                  controller: controller,
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    // 🔽 customBuilder が指定されていたら、それを使ってビルド
                    if (customBuilder != null) {
                      return customBuilder(context, imageUrls, index);
                    }

                    return GestureDetector(
                      onVerticalDragUpdate: (details) {
                        if (details.primaryDelta != null && details.primaryDelta! > 20) {
                          Navigator.pop(context);
                        }
                      },
                      onTap: () {}, // 無反応にする
                      child: InteractiveViewer(
                        panEnabled: true,
                        minScale: 1.0,
                        maxScale: 5.0,
                        child: Image.network(
                          imageUrls[index],
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (_, __, ___) =>
                          const Center(child: Text('画像を読み込めません')),
                        ),
                      ),
                    );

                    /*return GestureDetector(
                      onVerticalDragUpdate: (details) {
                        if (details.primaryDelta != null && details.primaryDelta! > 20) {
                          Navigator.pop(context); // 下スワイプで閉じる
                        }
                      },
                      onTap: () {}, // 画像タップは何もしない
                      child: Center(
                        child: InteractiveViewer(
                          child: Image.network(
                            imageUrls[index],
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    );*/
                  },
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class LoadingIndicator extends StatelessWidget {
  final String? message;

  const LoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(
              message!,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }
}

class TimeAgoText extends StatelessWidget {
  final dynamic timestamp;

  const TimeAgoText({super.key, required this.timestamp});

  @override
  Widget build(BuildContext context) {
    DateTime time;

    if (timestamp is Timestamp) {
      time = (timestamp as Timestamp).toDate();
    } else if (timestamp is DateTime) {
      time = timestamp as DateTime;
    } else {
      return const SizedBox(); // timestampがない場合は空表示
    }

    final now = DateTime.now();
    final diff = now.difference(time);

    String text;
    if (diff.inSeconds < 60) {
      text = '${diff.inSeconds}秒前';
    } else if (diff.inMinutes < 60) {
      text = '${diff.inMinutes}分前';
    } else if (diff.inHours < 24) {
      text = '${diff.inHours}時間前';
    } else if (diff.inDays < 7) {
      text = '${diff.inDays}日前';
    } else {
      text = DateFormat('yyyy/MM/dd').format(time); // 7日以上なら日付表示
    }

    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        color: Colors.grey,
      ),
    );
  }
}