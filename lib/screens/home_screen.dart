import 'package:flutter/material.dart';
import 'package:flutter_image_caching_manager/widgets/cache_image_widget.dart';
import 'package:flutter_image_caching_manager/core/cache/image_cache_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImageCacheManager cacheManager = ImageCacheManager();
  String cacheSize = 'Calculating...';

  // Sample image URLs for demo
  final List<String> sampleImages = [
    'https://picsum.photos/400/300?random=1',
    'https://picsum.photos/400/300?random=2',
    'https://picsum.photos/400/300?random=3',
    'https://picsum.photos/400/300?random=4',
    'https://picsum.photos/400/300?random=5',
    'https://picsum.photos/400/300?random=6',
    'https://picsum.photos/400/300?random=7',
    'https://picsum.photos/400/300?random=8',
    'https://picsum.photos/400/300?random=9',
    'https://picsum.photos/400/300?random=10',
  ];
  int refreshTick = 0;

  @override
  void initState() {
    super.initState();
    updateCacheSize();
  }

  Future<void> updateCacheSize() async {
    final size = await cacheManager.getCacheSize();
    setState(() {
      cacheSize = formatBytes(size);
    });
  }

  String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  Future<void> clearCache() async {
    await cacheManager.clearCache();
    await updateCacheSize();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cache cleared successfully')),
      );
      setState(() {});
    }
  }

  Future<void> cleanExpiredCache() async {
    await cacheManager.cleanExpiredCache();
    await updateCacheSize();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Expired cache cleaned')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Caching Manager'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await updateCacheSize();
              setState(() {
                refreshTick++;
              });
            },
            tooltip: 'Refresh images',
          ),
        ],
      ),
      body: Column(
        children: [
          // Cache info panel
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cache Size: $cacheSize',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: clearCache,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Clear Cache'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: cleanExpiredCache,
                      icon: const Icon(Icons.cleaning_services, size: 18),
                      label: const Text('Clean Expired'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade400,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Image grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0,
              ),
              itemCount: sampleImages.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 4,
                  child: CachedImage(
                    imageUrl: sampleImages[index],
                    forceRefresh: refreshTick % 2 == 0,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(8),
                    placeholder: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Failed to load',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Image Caching Manager'),
              content: const Text(
                'This demo shows:\n\n'
                    '• Automatic image caching\n'
                    '• Memory & disk cache\n'
                    '• Cache size management\n'
                    '• Expired cache cleanup\n'
                    '• Custom placeholder & error widgets\n\n'
                    'Scroll to see cached images load instantly!',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Got it'),
                ),
              ],
            ),
          );
        },
        tooltip: 'Info',
        child: const Icon(Icons.info_outline),
      ),
    );
  }
}
