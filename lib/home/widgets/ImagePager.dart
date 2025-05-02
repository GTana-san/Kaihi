import 'package:flutter/material.dart';
import 'widgets.dart';

class ImagePager<T> extends StatelessWidget {
  final List<T> imageUrls;
  final void Function(String url)? onTap;
  final BoxFit fit;
  final double height;
  final bool enableFullscreen;

  final Widget Function(BuildContext context, List<T> imageUrls, int index)? customBuilder;

  const ImagePager({
    super.key,
    required this.imageUrls,
    this.onTap,
    this.fit = BoxFit.cover,
    this.height = 250,
    this.enableFullscreen = false,
    this.customBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: height,
      width: MediaQuery.of(context).size.width,
      child: PageView.builder(
        itemCount: imageUrls.length,
        controller: PageController(viewportFraction: 0.95),
        itemBuilder: (context, index) {
          final dynamic data = imageUrls[index];
          final String? url = data is String ? data : null;
          //final url = imageUrls[index];

          Widget imageContent;

          if (customBuilder != null) {
            imageContent = customBuilder!(context, imageUrls, index);
          } else {
            imageContent = InteractiveViewer(
              panEnabled: true,
              minScale: 1.0,
              maxScale: 4.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  url ?? '',
                  fit: fit,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) =>
                  const Center(child: Text('画像を読み込めません')),
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                if (onTap != null && url != null) {
                  onTap!(url);
                } else if (enableFullscreen && url != null) {
                  showFullscreenImagePagerDialog(
                    context: context,
                    imageUrls: imageUrls.cast<String>(),
                    initialIndex: index,
                  );
                }
              },
              child: imageContent,
            ),
          );
        },
      ),
    );
  }
}