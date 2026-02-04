import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

/// Core class that manages image caching operations
class ImageCacheManager {
  static final ImageCacheManager instance = ImageCacheManager._internal();
  factory ImageCacheManager() => instance;
  ImageCacheManager._internal();

  // Memory cache for quick access
  final Map<String, Uint8List> memoryCache = {};

  // Maximum memory cache size (in number of images)
  final int maxMemoryCacheSize = 50;

  // Cache duration in days
  final int cacheDurationInDays = 7;

  /// Get the cache directory
  Future<Directory> getCacheDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${directory.path}/image_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  /// Generate a cache key from URL
  String generateCacheKey(String url) {
    final bytes = utf8.encode(url);
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  /// Get cached file path
  Future<File> getCacheFile(String url) async {
    final cacheDir = await getCacheDirectory();
    final cacheKey = generateCacheKey(url);
    return File('${cacheDir.path}/$cacheKey.cache');
  }

  /// Check if cache is valid (not expired)
  Future<bool> isCacheValid(File file) async {
    if (!await file.exists()) return false;

    final lastModified = await file.lastModified();
    final now = DateTime.now();
    final difference = now.difference(lastModified);

    return difference.inDays < cacheDurationInDays;
  }

  /// Load image from URL with caching
  Future<Uint8List?> loadImage(String url, {bool ignoreCache = false}) async {
    // If not forcing refresh, check memory cache
    if (!ignoreCache && memoryCache.containsKey(url)) {
      return memoryCache[url];
    }

    // Check disk cache
    final cacheFile = await getCacheFile(url);
    if (!ignoreCache && await isCacheValid(cacheFile)) {
      final bytes = await cacheFile.readAsBytes();
      addToMemoryCache(url, bytes);
      return bytes;
    }

    // Download from network
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        // Save to disk
        await cacheFile.writeAsBytes(bytes);

        // Save to memory
        addToMemoryCache(url, bytes);

        return bytes;
      }
    } catch (e) {
      return null;
    }

    return null;
  }

  /// Add image to memory cache with size limit
  void addToMemoryCache(String url, Uint8List bytes) {
    if (memoryCache.length >= maxMemoryCacheSize) {
      // Remove oldest entry (first key)
      final firstKey = memoryCache.keys.first;
      memoryCache.remove(firstKey);
    }
    memoryCache[url] = bytes;
  }

  /// Clear all cached images
  Future<void> clearCache() async {
    memoryCache.clear();
    final cacheDir = await getCacheDirectory();
    if (await cacheDir.exists()) {
      await cacheDir.delete(recursive: true);
    }
  }

  /// Get cache size in bytes
  Future<int> getCacheSize() async {
    final cacheDir = await getCacheDirectory();
    if (!await cacheDir.exists()) return 0;

    int totalSize = 0;
    await for (var entity in cacheDir.list(recursive: true)) {
      if (entity is File) {
        totalSize += await entity.length();
      }
    }
    return totalSize;
  }

  /// Remove expired cache files
  Future<void> cleanExpiredCache() async {
    final cacheDir = await getCacheDirectory();
    if (!await cacheDir.exists()) return;

    await for (var entity in cacheDir.list()) {
      if (entity is File) {
        if (!await isCacheValid(entity)) {
          await entity.delete();
        }
      }
    }
  }
}