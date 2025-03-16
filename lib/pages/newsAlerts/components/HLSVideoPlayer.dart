import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import '../../../services/media_cache_service.dart';

class HLSVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;
  final bool looping;
  final String videoId;
  final Map<String, dynamic>? videoFormats;
  final VoidCallback? onDispose;
  @override
  final Key? key;

   const HLSVideoPlayer({
    this.key,
    required this.videoUrl,
    required this.videoId,
    this.autoPlay = true,
    this.looping = true,
    this.videoFormats,
    this.onDispose,
  }) : super(key: key);

  _HLSVideoPlayerState? get state => _key.currentState;
  static final GlobalKey<_HLSVideoPlayerState> _key = GlobalKey<_HLSVideoPlayerState>();

  @override
  State<HLSVideoPlayer> createState() => _HLSVideoPlayerState();
}

class _HLSVideoPlayerState extends State<HLSVideoPlayer> {
  final MediaCacheService _cacheService = MediaCacheService();
  VideoPlayerController? _controller;
  bool _isPlaying = false;
  bool _isBuffering = false;
  Map<String, String> _qualityOptions = {};
  String _currentQuality = 'auto';
  bool _showControls = false;
  Timer? _hideControlsTimer;
  bool _isInitialized = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isDragging = false;
  Timer? _positionUpdateTimer;
  bool _isQualityMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _setupQualityOptions();
    // Start position update timer
    _positionUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_controller != null && _isInitialized && !_isDragging) {
        _updatePosition();
      }
    });
  }

  void _setupQualityOptions() {
    if (widget.videoFormats != null) {
      final formats = widget.videoFormats as Map<String, dynamic>;
      Map<String, String> options = {'auto': formats['720p']};

      if (formats['480p'] != null) options['480p'] = formats['480p'];
      if (formats['720p'] != null) options['720p'] = formats['720p'];
      if (formats['1080p'] != null) options['1080p'] = formats['1080p'];

      setState(() {
        _qualityOptions = options;
      });
    }
  }

  @override
  void didUpdateWidget(HLSVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _initializePlayer();
    }
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 2), () {
      if (mounted && _isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _handleTap(TapDownDetails details) {
    if (!_isInitialized) return;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final tapPosition = details.globalPosition.dx;
    final tapArea = screenWidth / 3;

    if (tapPosition < tapArea) {
      // Left side tap - rewind 3 seconds
      _seekRelative(-3);
    } else if (tapPosition > (screenWidth - tapArea)) {
      // Right side tap - forward 3 seconds
      _seekRelative(3);
    } else {
      // Center tap - toggle play/pause
      _togglePlayPause();
    }
  }

  Future<void> _seekRelative(double seconds) async {
    if (!_isInitialized || _controller == null) return;
    
    try {
      final currentPosition = _controller!.value.position;
      final newPosition = currentPosition + Duration(seconds: seconds.toInt());
      await _controller!.seekTo(newPosition);
      _showControlsTemporarily();
    } catch (e) {
      debugPrint('Error seeking video: $e');
    }
  }

  Future<void> _togglePlayPause() async {
    if (!_isInitialized || _controller == null) return;
    
    try {
      setState(() {
        _isPlaying = !_isPlaying;
      });
      
      if (_isPlaying) {
        await _controller!.play();
      } else {
        await _controller!.pause();
      }
      
      _showControlsTemporarily();
    } catch (e) {
      debugPrint('Error toggling play/pause: $e');
    }
  }

  void _showControlsTemporarily() {
    setState(() {
      _showControls = true;
    });
    _startHideControlsTimer();
  }

  void _updatePosition() {
    if (_controller != null) {
      final position = _controller!.value.position;
      _cacheService.updateVideoPosition(widget.videoId, position);
    }
  }

  Future<void> _initializePlayer() async {
    try {
      await _controller?.dispose();

      // Check if video is in cache
      final cachedController = _cacheService.getCachedVideoController(widget.videoId);
      if (cachedController != null) {
        _controller = cachedController;
        if (mounted) {
          setState(() {
            _isInitialized = true;
            _isPlaying = widget.autoPlay;
            _duration = _controller!.value.duration;
            _position = _controller!.value.position;
          });

          // Restore saved position
          final savedPosition = _cacheService.getVideoPosition(widget.videoId);
          if (savedPosition != null) {
            await _controller!.seekTo(savedPosition);
          }

          if (widget.autoPlay) {
            await _controller!.play();
          }
          await _controller!.setLooping(widget.looping);
          return;
        }
      }

      // If not in cache, initialize new controller
      final initialUrl = _qualityOptions['auto'] ??
          _qualityOptions['720p'] ??
          _qualityOptions['480p'] ??
          _qualityOptions['1080p'] ??
          '';

      if (initialUrl.isEmpty) {
        debugPrint('No valid video URL available');
        return;
      }
      
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(initialUrl),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: false,
        ),
        httpHeaders: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        },
      );

      _controller!.addListener(_videoListener);
      
      await _controller!.initialize();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isPlaying = widget.autoPlay;
          _duration = _controller!.value.duration;
        });

        // Restore saved position
        final savedPosition = _cacheService.getVideoPosition(widget.videoId);
        if (savedPosition != null) {
          await _controller!.seekTo(savedPosition);
          _position = savedPosition;
        }
        
        if (widget.autoPlay) {
          await _controller!.play();
        }
        await _controller!.setLooping(widget.looping);
      }
    } catch (e) {
      debugPrint('Error initializing video player: $e');
      if (mounted) {
        setState(() {
          _isInitialized = false;
          _controller = null;
        });
      }
    }
  }

  void _videoListener() {
    if (!mounted) return;

    final controller = _controller;
    if (controller == null) return;

    final isBuffering = controller.value.isBuffering;
    if (isBuffering != _isBuffering) {
      setState(() {
        _isBuffering = isBuffering;
      });
    }

    final position = controller.value.position;
    final duration = controller.value.duration;
    
    if (position != _position || duration != _duration) {
      setState(() {
        _position = position;
        _duration = duration;
      });
      
      // Save position periodically and mark as visited when played
      if (!_isDragging) {
        _cacheService.markVideoAsVisited(widget.videoId);
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> _changeQuality(String quality) async {
    if (!_qualityOptions.containsKey(quality)) return;

    try {
      final newUrl = _qualityOptions[quality]!;
      final currentPosition = await _controller?.position ?? Duration.zero;
      final wasPlaying = _isPlaying;

      setState(() {
        _isBuffering = true;
        _isQualityMenuOpen = false;
      });

      await _controller?.dispose();

      _controller = VideoPlayerController.networkUrl(
        Uri.parse(newUrl),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false),
        httpHeaders: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        },
      );

      _controller!.addListener(_videoListener);
      await _controller!.initialize();
      await _controller!.seekTo(currentPosition);

      if (wasPlaying) {
        await _controller!.play();
      }

      if (mounted) {
        setState(() {
          _currentQuality = quality;
          _isBuffering = false;
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error changing quality: $e');
      setState(() {
        _isBuffering = false;
      });
    }
  }

  Future<void> stopPlayback() async {
    if (_controller != null) {
      await _controller!.pause();
      setState(() {
        _isPlaying = false;
      });
    }
  }

  Future<void> pause() async {
    if (_controller != null) {
      await _controller!.pause();
      setState(() {
        _isPlaying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,

      children: [
        // Video Player
        if (_isInitialized && _controller != null)
          GestureDetector(
            onTapDown: _handleTap,
            onTap: () {
                        setState(() {
                _showControls = !_showControls;
              });
              if (_showControls) {
                _startHideControlsTimer();
              }
            },
            child: VideoPlayer(_controller!),
          )
        // else
        //   const Center(child: CircularProgressIndicator())
        ,

        // Buffering Indicator
        if (_isBuffering && _controller?.dataSource == null)
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),

        // Video Controls
        if (_showControls)
          Container(
              color: Colors.black26,
            height: double.infinity,
            width: MediaQuery.of(context).size.width,
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // mainAxisSize: MainAxisSize.max,
              children: [
                // Top Bar - Quality Selector
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
              child: PopupMenuButton<String>(
                onSelected: _changeQuality,
                      itemBuilder: (context) =>
                          _qualityOptions.keys.map((quality) {
                        return PopupMenuItem<String>(
                          value: quality,
                          child: Row(
                            children: [
                              if (quality == _currentQuality)
                                const Icon(Icons.check,
                                    size: 16, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                quality.toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                color: Colors.black87,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                            const Icon(Icons.settings,
                                color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                              _currentQuality.toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.8,
                child: 

                Center(
                  child:  IconButton(
                            icon: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 32,
                            ),
                            onPressed: _togglePlayPause,
                          ),
                ),
                ),
                // Bottom Bar - Progress and Controls
                // Column(
                //   mainAxisSize: MainAxisSize.max,
                //   children: [

                    
                //     // Progress Bar

                //     // Time and Controls
                //     // Padding(
                //     //   padding: const EdgeInsets.symmetric(
                //     //       horizontal: 16, vertical: 8),
                //     //   child: Row(
                //     //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     //     children: [
                //     //       // Text(
                //     //       //   _formatDuration(_position),
                //     //       //   style: const TextStyle(color: Colors.white),
                //     //       // ),
                         
                //     //       // Text(
                //     //       //   _formatDuration(_duration),
                //     //       //   style: const TextStyle(color: Colors.white),
                //     //       // ),
                //     //     ],
                //     //   ),
                //     // ),
                //   ],
                // ),
              
              ],
            ),
          ),

        Positioned(
          left: 0,
          right: 0,
          bottom: -15,
          child: Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width * 1.2,
            height: 50,
            padding: const EdgeInsets.only(top: 16),
            child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white24,
              thumbColor: Colors.white,
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: _position.inMilliseconds.toDouble(),
              min: 0,
              max: _duration.inMilliseconds.toDouble(),
              onChanged: (value) {
                setState(() {
                  _position = Duration(milliseconds: value.toInt());
                });
              },
              onChangeStart: (_) => setState(() => _isDragging = true),
              onChangeEnd: (value) {
                setState(() => _isDragging = false);
                _controller?.seekTo(Duration(milliseconds: value.toInt()));
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    // Save final position before disposing
    if (_controller != null) {
      _updatePosition();
    }
    _positionUpdateTimer?.cancel();
    _hideControlsTimer?.cancel();
    _controller?.removeListener(_videoListener);
    if (_cacheService.getCachedVideoController(widget.videoId) != _controller) {
      _controller?.dispose();
    }
    widget.onDispose?.call();
    super.dispose();
  }
} 
