import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class HLSVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;
  final bool looping;
  final String videoId;
  // final bool isInReel;

   const HLSVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.videoId,
    this.autoPlay = true,
    this.looping = true,
    // this.isInReel = false,
  });

  @override
  State<HLSVideoPlayer> createState() => _HLSVideoPlayerState();
}

class _HLSVideoPlayerState extends State<HLSVideoPlayer> {
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
  static final Map<String, Duration> _videoPositions = {};

  @override
  void initState() {
    super.initState();
    _initializePlayer(widget.videoUrl);
    _fetchQualityOptions();
  }

  @override
  void didUpdateWidget(HLSVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _initializePlayer(widget.videoUrl);
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

  Future<void> _fetchQualityOptions() async {
    try {
      final response = await http.get(
        Uri.parse(widget.videoUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          'Accept': '*/*',
          'Origin': '*',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
          'Access-Control-Allow-Headers': 'Origin, Content-Type',
        },
      );
      
      if (response.statusCode == 200) {
        final manifest = response.body;
        final lines = manifest.split('\n');
        final baseUrl = widget.videoUrl.substring(0, widget.videoUrl.lastIndexOf('/') + 1);
        
        Map<String, String> options = {'auto': widget.videoUrl};
        
        for (int i = 0; i < lines.length; i++) {
          if (lines[i].startsWith('#EXT-X-STREAM-INF')) {
            final resolution = RegExp(r'RESOLUTION=(\d+x\d+)').firstMatch(lines[i])?.group(1);
            if (resolution != null && i + 1 < lines.length) {
              final height = resolution.split('x')[1];
              final qualityUrl = lines[i + 1].startsWith('http') 
                  ? lines[i + 1] 
                  : baseUrl + lines[i + 1];
              options['${height}p'] = qualityUrl;
            }
          }
        }

        if (mounted) {
          setState(() {
            _qualityOptions = options;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching quality options: $e');
    }
  }

  Future<void> _initializePlayer(String url) async {
    try {
      // Dispose of the old controller if it exists
      await _controller?.dispose();
      
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(url),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: false,
        ),
        httpHeaders: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          'Accept': '*/*',
          'Origin': '*',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
          'Access-Control-Allow-Headers': 'Origin, Content-Type',
        },
      );

      _controller!.addListener(_videoListener);
      
      await _controller!.initialize();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isPlaying = widget.autoPlay;
        });

        // Restore previous position if exists
        final savedPosition = _videoPositions[widget.videoId];
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
      
      // Save position periodically
      if (!_isDragging) {
        _videoPositions[widget.videoId] = position;
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
    if (_qualityOptions.containsKey(quality)) {
      final newUrl = _qualityOptions[quality]!;
      final position = await _controller?.position;
      final wasPlaying = _isPlaying;

      await _controller?.dispose();
      await _initializePlayer(newUrl);

      if (position != null) {
        await _controller?.seekTo(position);
      }

      if (wasPlaying) {
        _controller?.play();
      }

      setState(() {
        _currentQuality = quality;
      });
    }
  }

// GestureDetector(
//             onTapDown: _handleTap,
//             child: AspectRatio(
//               aspectRatio: _controller!.value.aspectRatio,
//               child: ,
//             ),
//           )

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Base video player
        if (_isInitialized && _controller != null)
        VideoPlayer(_controller!)
          
        else
          const Center(child: CircularProgressIndicator()),

        // Video Progress Bar (moved up in the stack)
        if (_isInitialized && _controller != null)
          Positioned(
            width: MediaQuery.of(context).size.width *1.12,
            bottom: -10, // Positioned under description, above bottom nav
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Progress Slider
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white.withOpacity(0.3),
                      thumbColor: Colors.white,
                      overlayColor: Colors.white.withOpacity(0.2),
                      trackHeight: 2,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 8),
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
                      onChangeStart: (_) {
                        setState(() {
                          _isDragging = true;
                        });
                      },
                      onChangeEnd: (value) {
                        setState(() {
                          _isDragging = false;
                        });
                        _controller?.seekTo(Duration(milliseconds: value.toInt()));
                      },
                    ),
                  ),
                  // Time indicators
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text(
                  //       _formatDuration(_position),
                  //       style: const TextStyle(
                  //         color: Colors.white,
                  //         fontSize: 12,
                  //       ),
                  //     ),
                  //     Text(
                  //       _formatDuration(_duration),
                  //       style: const TextStyle(
                  //         color: Colors.white,
                  //         fontSize: 12,
                  //       ),
                  //     ),
                  //   ],
                  // ),
               
                ],
              ),
            ),
          ),

        // Quality selector (moved up in the stack)
        if (_qualityOptions.isNotEmpty)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: PopupMenuButton<String>(
                onSelected: _changeQuality,
                itemBuilder: (context) => _qualityOptions.keys
                    .map((quality) => PopupMenuItem<String>(
                          value: quality,
                          child: Row(
                            children: [
                              if (quality == _currentQuality)
                                const Icon(Icons.check, size: 16, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                quality,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
                color: Colors.black87,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.settings, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        _currentQuality,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // Buffering indicator
        if (_isBuffering)
          Container(
            color: Colors.black26,
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),

        // Play/Pause overlay
        if (_showControls)
          AnimatedOpacity(
            opacity: _showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              color: Colors.black26,
              child: Center(
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
          ),

        // Forward/Rewind indicators
        if (_showControls)
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 3,
                  color: Colors.transparent,
                  child: const Center(
                    child: Icon(
                      Icons.replay_10,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 3,
                  color: Colors.transparent,
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 3,
                  color: Colors.transparent,
                  child: const Center(
                    child: Icon(
                      Icons.forward_10,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    // Save final position before disposing
    if (_controller != null) {
      _videoPositions[widget.videoId] = _controller!.value.position;
    }
    
    _hideControlsTimer?.cancel();
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    super.dispose();
  }
} 