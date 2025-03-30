import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class MediaCacheService {
  static final MediaCacheService _instance = MediaCacheService._internal();
  factory MediaCacheService() => _instance;
  MediaCacheService._internal();

  final Map<String, VideoPlayerController> _videoControllerCache = {};
  final Map<String, Uint8List> _imageCache = {};
  final Set<String> _visitedVideos = {};
  final Set<String> _preloadingVideos = {};
  final Map<String, Duration> _videoPositions = {};
  final int _maxCacheSize = 5; // Maximum number of videos to keep in cache
  final DefaultCacheManager _cacheManager = DefaultCacheManager();

  bool isVideoVisited(String videoId) => _visitedVideos.contains(videoId);
  
  void markVideoAsVisited(String videoId) {
    _visitedVideos.add(videoId);
  }

  void updateVideoPosition(String videoId, Duration position) {
    _videoPositions[videoId] = position;
  }

  Duration? getVideoPosition(String videoId) {
    return _videoPositions[videoId];
  }

  Future<void> preloadUpcomingVideos(List<Map<String, dynamic>> reels, int currentIndex) async {
    // Clear old preloaded videos that are too far back
    _cleanupOldCache(reels, currentIndex);

    // Preload next 2 videos
    for (var i = 1; i <= 2; i++) {
      final nextIndex = currentIndex + i;
      if (nextIndex < reels.length) {
        final nextReel = reels[nextIndex];
        if (nextReel['type'] == 'video' && !_preloadingVideos.contains(nextReel['_id'])) {
          _preloadingVideos.add(nextReel['_id']);
          // Use unawaited to not block the UI
          _preloadVideo(nextReel).then((_) {
            _preloadingVideos.remove(nextReel['_id']);
          });
        }
      }
    }
  }

  void _cleanupOldCache(List<Map<String, dynamic>> reels, int currentIndex) {
    // Remove videos that are more than 2 positions behind current index
    for (var i = 0; i < currentIndex - 2; i++) {
      if (i >= 0 && i < reels.length) {
        final reel = reels[i];
        if (reel['type'] == 'video') {
          removeFromCache(reel['_id']);
        }
      }
    }
  }

  Future<void> preloadVideos(List<Map<String, dynamic>> reels, {int preloadCount = 3}) async {
    for (var i = 0; i < preloadCount && i < reels.length; i++) {
      final reel = reels[i];
      if (reel['type'] == 'video') {
        await _preloadVideo(reel);
      }
    }
  }

  Future<void> _preloadVideo(Map<String, dynamic> reel) async {
    if (!_videoControllerCache.containsKey(reel['_id'])) {
      try {
        final formats = reel['videoFormats'] as Map<String, dynamic>;
        final videoUrl = formats['720p'] ?? formats['480p'] ?? formats['1080p'];
        
        if (videoUrl != null) {
          final controller = VideoPlayerController.networkUrl(
            Uri.parse(videoUrl),
            videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false),
          );
          
          await controller.initialize();
          
          // Check for saved position
          final savedPosition = _videoPositions[reel['_id']];
          if (savedPosition != null) {
            await controller.seekTo(savedPosition);
          } else {
            await controller.seekTo(const Duration(seconds: 0));
            await controller.play();
            await Future.delayed(const Duration(milliseconds: 500));
            await controller.pause();
          }
          
          _addToVideoCache(reel['_id'], controller);
        }
      } catch (e) {
        //debugPrint('Error preloading video: $e');
      }
    }
  }

  void _addToVideoCache(String id, VideoPlayerController controller) {
    if (_videoControllerCache.length >= _maxCacheSize) {
      // Remove oldest non-preloading video
      final oldestKey = _videoControllerCache.keys
          .firstWhere((key) => !_preloadingVideos.contains(key),
              orElse: () => _videoControllerCache.keys.first);
      _videoControllerCache[oldestKey]?.dispose();
      _videoControllerCache.remove(oldestKey);
    }
    _videoControllerCache[id] = controller;
  }

  Future<void> preloadImages(List<Map<String, dynamic>> reels, {int preloadCount = 3}) async {
    for (var i = 0; i < preloadCount && i < reels.length; i++) {
      final reel = reels[i];
      if (reel['type'] != 'video' && reel['images'] != null) {
        await _preloadImages(reel);
      }
    }
  }

  Future<void> _preloadImages(Map<String, dynamic> reel) async {
    final images = reel['images'] as List<dynamic>;
    for (var image in images) {
      final imageUrl = image['large'] ?? image['medium'] ?? image['original'];
      if (imageUrl != null && !_imageCache.containsKey(imageUrl)) {
        try {
          final file = await _cacheManager.getSingleFile(imageUrl);
          final bytes = await file.readAsBytes();
          _imageCache[imageUrl] = bytes;
        } catch (e) {
          //debugPrint('Error preloading image: $e');
        }
      }
    }
  }

  VideoPlayerController? getCachedVideoController(String id) {
    return _videoControllerCache[id];
  }

  Uint8List? getCachedImage(String url) {
    return _imageCache[url];
  }

  void clearCache() {
    for (var controller in _videoControllerCache.values) {
      controller.dispose();
    }
    _videoControllerCache.clear();
    _imageCache.clear();
    _visitedVideos.clear();
    _preloadingVideos.clear();
    // Don't clear video positions to maintain continuity
    _cacheManager.emptyCache();
  }

  Future<void> removeFromCache(String id) async {
    if (_videoControllerCache.containsKey(id)) {
      await _videoControllerCache[id]?.dispose();
      _videoControllerCache.remove(id);
    }
  }
} 