# 🖼️ FlutterImageCachingManager

A simple Flutter demo project that shows how to build a **custom image caching system** with:

- ✅ Memory cache
- ✅ Disk cache
- ✅ Cache size calculation
- ✅ Clear cache
- ✅ Clean expired cache
- ✅ Force refresh images
- ✅ Custom placeholder & error widgets

This project is designed as a **simple Flutter app**, but the structure is future-ready so you can later convert it into a reusable package/library.

---
## ✨ Preview

![screen-20260204-144948~3](https://github.com/user-attachments/assets/80400efe-f30c-4d20-b224-62cdd8bc56df)

---
## ✨ Installation
Add this to your package's pubspec.yaml file:
```
dependencies:
  flutter_image_caching_manager:
    path: ../flutter_image_caching_manager  # For local development
```
from git:
```
dependencies:
  flutter_image_caching_manager:
    git:
      url: https://github.com/yourusername/flutter_image_caching_manager.git  # Your github path
``` 
Then run:
```
flutter pub get
```
---

## ✨ Features

- 📦 Automatic image caching (memory + disk)
- ⚡ Fast loading from cache
- 🌐 Downloads from network if not cached / expired
- 🧹 Clear all cache with one button
- 🕒 Remove expired cache files
- 📊 Show total cache size
- 🔄 Refresh images from AppBar
- 🎨 Custom placeholder & error UI
- 🧩 Reusable CachedImage widget

---
## 📁 Project Structure
```
lib/
├── main.dart
├── core/
│   └── cache/
│       ├── image_cache_manager.dart
│       └── cache_image_widget.dart
└── screens/
    └── demo_screen.dart

```
---
## 1️⃣ Add dependencies
In pubspec.yaml:
```
dependencies:
  flutter:
    sdk: flutter
  cached_network_image: ^3.4.1

```
---
## 🧩 Usage
##### Basic usage of CachedImage
```
CachedImage(
  imageUrl: "https://picsum.photos/400/300?random=1",
  width: 200,
  height: 200,
  fit: BoxFit.cover,
  borderRadius: BorderRadius.circular(8),
)
```
##### With custom placeholder & error widget
```
CachedImage(
  imageUrl: "https://picsum.photos/400/300?random=2",
  placeholder: const Center(child: CircularProgressIndicator()),
  errorWidget: const Icon(Icons.error, color: Colors.red),
)

```
##### Force refresh image (ignore cache)
```
CachedImage(
  imageUrl: "https://picsum.photos/400/300?random=3",
  forceRefresh: true, // 👈 always reload from network
)

```
---
## 🧠 How It Works
#### 🔹 Memory Cache
- Stores recently used images in RAM
- Fastest loading
- Limited by maxMemoryCacheSize

#### 🔹 Disk Cache
- Stores images in app directory
- Persists between app restarts
- Each file is saved using MD5 hash of URL

#### 🔹 Cache Validation
- Each cached file has a time limit (default: 7 days)
- Expired files are deleted using Clean Expired button

---
## 🧹 Cache Controls
##### ✅ Clear All Cache
```
await _cacheManager.clearCache();

```
- Clears memory cache
- Deletes disk cache folder

---
##### ✅ Clean Expired Cache
```
await _cacheManager.cleanExpiredCache();

```
- Removes only expired files from disk

---
##### ✅ Get Cache Size
```
final size = await _cacheManager.getCacheSize();

```
---

## 🔄 Refresh Behavior

- 🔁 AppBar Refresh Button:
     - Rebuilds grid
     - Reloads images
     - Uses cache if available

- 🗑️ After “Clear Cache”:
   - Images will download again from network

- ⚡ If cache exists:
   - Images load instantly from memory/disk
   - 
---
## 📜 License
MIT License
```
Copyright (c) 2025 Excelsior Technologies

Permission is hereby granted, free of charge, to any person obtaining a copy  
of this software and associated documentation files (the "Software"), to deal  
in the Software without restriction, including without limitation the rights  
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell  
copies of the Software, and to permit persons to whom the Software is  
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all  
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED **"AS IS"**, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,  
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
```
---
