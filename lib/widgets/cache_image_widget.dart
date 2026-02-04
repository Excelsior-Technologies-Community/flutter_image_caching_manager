import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_image_caching_manager/core/cache/image_cache_manager.dart';

class CachedImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;

  final dynamic forceRefresh;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.backgroundColor,
    this.forceRefresh = false,
  });

  @override
  State<CachedImage> createState() => CachedImageState();
}

class CachedImageState extends State<CachedImage> {
  final ImageCacheManager cacheManager = ImageCacheManager();
  Uint8List? imageBytes;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    loadImage();
  }

  @override
  @override
  void didUpdateWidget(CachedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.forceRefresh != widget.forceRefresh) {
      loadImage();
    }
  }

  Future<void> loadImage() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final bytes = await cacheManager.loadImage(
        widget.imageUrl,
        ignoreCache: widget.forceRefresh,
      );
      if (mounted) {
        setState(() {
          imageBytes = bytes;
          isLoading = false;
          hasError = bytes == null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (isLoading) {
      child =
          widget.placeholder ??
          Container(
            width: widget.width,
            height: widget.height,
            color: widget.backgroundColor ?? Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          );
    } else if (hasError || imageBytes == null) {
      child =
          widget.errorWidget ??
          Container(
            width: widget.width,
            height: widget.height,
            color: widget.backgroundColor ?? Colors.grey[300],
            child: const Icon(Icons.broken_image, color: Colors.grey, size: 48),
          );
    } else {
      child = Image.memory(
        imageBytes!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) {
          return widget.errorWidget ??
              Container(
                width: widget.width,
                height: widget.height,
                color: widget.backgroundColor ?? Colors.grey[300],
                child: const Icon(
                  Icons.broken_image,
                  color: Colors.grey,
                  size: 48,
                ),
              );
        },
      );
    }

    if (widget.borderRadius != null) {
      child = ClipRRect(borderRadius: widget.borderRadius!, child: child);
    }

    return child;
  }
}
