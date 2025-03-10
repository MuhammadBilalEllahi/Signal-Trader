import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:tradingapp/pages/newsAlerts/components/ReelDetailedPage.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:provider/provider.dart';
import 'package:tradingapp/pages/newsAlerts/providers/news_alerts_provider.dart';
import 'package:tradingapp/pages/newsAlerts/components/HLSVideoPlayer.dart';

class NewsAlerts extends StatefulWidget {
  const NewsAlerts({super.key});

  @override
  State<NewsAlerts> createState() => _NewsAlertsState();
}

class _NewsAlertsState extends State<NewsAlerts> {
  late PageController _pageController;
  List<Map<String, dynamic>> reels = [
    {
      'type': 'video',
      'videoUrl': 'https://flipfit-cdn.akamaized.net/flip_hls/661f570aab9d840019942b80-473e0b/video_h1.m3u8',
      'username': 'crypto_analyst',
      'description': 'Gold price analysis and market trends for the week',
      'likes': 1234,
      'comments': 89,
      'contentType': 'gold'
    },
    {
      'type': 'image',
      'images': [
        'https://images.unsplash.com/photo-1620641788421-7a1c342ea42e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1974&q=80',
      ],
      'username': 'btc_trader',
      'description': 'Bitcoin technical analysis and support levels',
      'likes': 2345,
      'comments': 156,
      'contentType': 'crypto'
    },
     {
      'type': 'video',
      'videoUrl': 'https://flipfit-cdn.akamaized.net/flip_hls/661f570aab9d840019942b80-473e0b/video_h1.m3u8',
      'username': 'crypto_analyst',
      'description': 'Gold price analysis and market trends for the week',
      'likes': 1234,
      'comments': 89,
      'contentType': 'gold'
    },
    {
      'type': 'image',
      'images': [
        'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80',
        'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80',
        'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80',
      ],
      'username': 'stock_master',
      'description': 'Stock market overview and trading opportunities',
      'likes': 3456,
      'comments': 234,
      'contentType': 'stocks'
    },
  ];

  @override
  void initState() {
    super.initState();
    // Initialize PageController with the saved index
    final provider = Provider.of<NewsAlertsProvider>(context, listen: false);
    _pageController = PageController(initialPage: provider.currentReelIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      Padding(
        padding: const EdgeInsets.only(top: 25),
        child: SizedBox.expand(
        child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: reels.length,
          onPageChanged: (index) {
            Provider.of<NewsAlertsProvider>(context, listen: false)
                .setCurrentReelIndex(index);
          },
        itemBuilder: (context, index) {
          return ReelItem(reel: reels[index]);
        },
        ),
        ),
    ));
  }
}

class ReelItem extends StatefulWidget {
  final Map<String, dynamic> reel;
  
  const ReelItem({super.key, required this.reel});

  @override
  State<ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<ReelItem> {
  VideoPlayerController? _videoController;
  final bool _isPlaying = true;
  final bool _showFullDescription = false;
  int _currentImageIndex = 0;
  late PageController _imagePageController;
  bool _isBuffering = false;

  @override
  void initState() {
    super.initState();
    _imagePageController = PageController();
    _initializeController();
  }

  Future<void> _initializeController() async {
    debugPrint('Initializing controller');
       debugPrint(" ${widget.reel}");
    if (widget.reel['type'] == 'video') {
      try {
        _videoController = VideoPlayerController.networkUrl(
          Uri.parse(widget.reel['videoUrl']),
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

        _videoController!.addListener(_videoListener);
        
        await _videoController?.initialize();
        if (mounted) {
        setState(() {});
          _videoController?.play();
          _videoController?.setLooping(true);
        }
      } catch (e) {
        print('Error initializing video controller: $e');
        if (mounted) {
          setState(() {
            _videoController = null;
          });
        }
      }
    }
  }

  void _videoListener() {
    if (!mounted) return;

    final controller = _videoController;
    if (controller == null) return;

    if (controller.value.isBuffering != _isBuffering) {
      setState(() {
        _isBuffering = controller.value.isBuffering;
      });
    }
  }

  @override
  void dispose() {
    _videoController?.removeListener(_videoListener);
    _videoController?.dispose();
    _imagePageController.dispose();
    super.dispose();
  }

  Widget _buildTypeBadge(String type) {
    Color startColor;
    Color endColor;
    String text;
    Color textColor;

    switch (type.toLowerCase()) {
      case 'crypto':
        startColor = Colors.grey.shade700;
        endColor = Colors.grey.shade500;
        text = "CRYPTO";
        textColor = Colors.white;
        break;
      case 'stocks':
        startColor = Colors.black87;
        endColor = Colors.black12;
        text = "STOCKS";
        textColor = Colors.white;
        break;
      default:
        startColor = Colors.yellow.shade700;
        endColor = Colors.yellow.shade100;
        text = "GOLD";
        textColor = Colors.black87;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  void _navigateToDetailedPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReelDetailedPage(reel: widget.reel),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Stack(
      // alignment: Alignment.center,
      children: [
        // Video player
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: _videoController?.value.isInitialized == true
              ? VideoPlayer(_videoController!)
              : const Center(child: CircularProgressIndicator()),
        ),
        // Buffering indicator
        // if (_isBuffering)
        //   Container(
        //     color: Colors.black26,
        //     child: const Center(
        //       child: CircularProgressIndicator(
        //         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        //       ),
        //     ),
        //   ),
        // // Play/Pause overlay
        // GestureDetector(
        //   onTap: () {
        //     setState(() {
        //       _isPlaying = !_isPlaying;
        //       _isPlaying ? _videoController?.play() : _videoController?.pause();
        //     });
        //   },
        //   child: Container(
        //     width: double.infinity,
        //     height: double.infinity,
        //     color: Colors.transparent,
        //     child: Center(
        //       child: AnimatedOpacity(
        //         opacity: _isPlaying ? 0.0 : 1.0,
        //         duration: const Duration(milliseconds: 200),
        //         child: Container(
        //           padding: const EdgeInsets.all(20),
        //           decoration: BoxDecoration(
        //             color: Colors.black.withOpacity(0.5),
        //             shape: BoxShape.circle,
        //           ),
        //           child: Icon(
        //             _isPlaying ? Icons.pause : Icons.play_arrow,
        //             color: Colors.white,
        //             size: 50,
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        // // Quality selector
        // Positioned(
        //   top: 40,
        //   right: 16,
        //   child: Container(
        //     decoration: BoxDecoration(
        //       color: Colors.black.withOpacity(0.6),
        //       borderRadius: BorderRadius.circular(4),
        //     ),
        //     child: PopupMenuButton<String>(
        //       onSelected: (String quality) async {
        //         String videoUrl = widget.reel['videoUrl'];
        //         if (quality != 'auto') {
        //           final Uri uri = Uri.parse(videoUrl);
        //           final String baseUrl = uri.toString().replaceAll('video_h1.m3u8', '');
        //           videoUrl = '${baseUrl}audio-video/$quality/stream.m3u8';
        //         }

        //         // Store current position and state
        //         final position = await _videoController?.position;
        //         final wasPlaying = _isPlaying;

        //         // Dispose old controller
        //         await _videoController?.dispose();

        //         // Create new controller with CORS headers
        //         _videoController = VideoPlayerController.networkUrl(
        //           Uri.parse(videoUrl),
        //           videoPlayerOptions: VideoPlayerOptions(
        //             mixWithOthers: false,
        //           ),
        //           httpHeaders: {
        //             'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        //             'Accept': '*/*',
        //             'Origin': '*',
        //             'Access-Control-Allow-Origin': '*',
        //             'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
        //             'Access-Control-Allow-Headers': 'Origin, Content-Type',
        //           },
        //         );

        //         // Initialize and restore state
        //         _videoController!.addListener(_videoListener);
        //         await _videoController!.initialize();
        //         await _videoController!.seekTo(position ?? Duration.zero);
                
        //         if (mounted) {
        //           setState(() {});
        //           if (wasPlaying) {
        //             _videoController?.play();
        //           }
        //         }
        //       },
        //       itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        //         const PopupMenuItem<String>(
        //           value: 'auto',
        //           child: Text('Auto', style: TextStyle(color: Colors.white)),
        //         ),
        //         const PopupMenuItem<String>(
        //           value: '1080',
        //           child: Text('1080p', style: TextStyle(color: Colors.white)),
        //         ),
        //         const PopupMenuItem<String>(
        //           value: '720',
        //           child: Text('720p', style: TextStyle(color: Colors.white)),
        //         ),
        //         const PopupMenuItem<String>(
        //           value: '480',
        //           child: Text('480p', style: TextStyle(color: Colors.white)),
        //         ),
        //       ],
        //       color: Colors.black87,
        //       child: Padding(
        //         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        //         child: Row(
        //           mainAxisSize: MainAxisSize.min,
        //           children: const [
        //             Icon(Icons.settings, color: Colors.white, size: 16),
        //             SizedBox(width: 4),
        //             Text(
        //               'Quality',
        //               style: TextStyle(color: Colors.white, fontSize: 12),
        //             ),
        //           ],
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        // Error indicator
        if (_videoController?.value.hasError ?? false)
          Container(
            color: Colors.black87,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 40),
                  const SizedBox(height: 8),
                  const Text(
                    'Error loading video',
                    style: TextStyle(color: Colors.white),
                  ),
                  TextButton(
                    onPressed: _initializeController,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
     
      ],
    );
  }

  Widget _buildMediaContent() {
    if (widget.reel['type'] == 'video') {
      return SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: HLSVideoPlayer(
          videoUrl: widget.reel['videoUrl'],
          videoId: widget.reel['videoUrl'],
        ),
      );
    } else {
      final images = widget.reel['images'] as List<String>;
      if (images.length == 1) {
        return SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Image.network(
            images[0],
            fit: BoxFit.cover,
          ),
        );
      } else {
        return Stack(
          children: [
            Positioned.fill(
              child: PageView.builder(
                controller: _imagePageController,
                itemCount: images.length,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                pageSnapping: true,
                onPageChanged: (index) {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Image.network(
                    images[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            if (images.length > 1) Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: SmoothPageIndicator(
                  controller: _imagePageController,
                  count: images.length,
                  effect: WormEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    spacing: 8,
                    dotColor: Colors.white.withOpacity(0.4),
                    activeDotColor: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
            ),
          ],
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // Media content
             _buildMediaContent(),
            
            // Gradient overlay for better text visibility
            // Positioned.fill(
            //   child: Container(
            //     color: Colors.black,
            //     // decoration: BoxDecoration(
            //     //   gradient: LinearGradient(
            //     //     begin: Alignment.topCenter,
            //     //     end: Alignment.bottomCenter,
            //     //     colors: [
            //     //       Colors.transparent,
            //     //       Colors.black.withOpacity(0.7),
            //     //     ],
            //     //   ),
            //     // ),
            //   ),
            // ),
            // Rest of the UI (username, description, etc.)
        Positioned(
          bottom: 20,
          left: 10,
          right: 60,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
            children: [
              Text(
                '@${widget.reel['username']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                      ),
                      const SizedBox(width: 8),
                      _buildTypeBadge(widget.reel['contentType']),
                    ],
              ),
              const SizedBox(height: 8),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final textSpan = TextSpan(
                        text: widget.reel['description'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      );
                      final textPainter = TextPainter(
                        text: textSpan,
                        textDirection: TextDirection.ltr,
                        maxLines: _showFullDescription ? null : 3,
                      );
                      textPainter.layout(maxWidth: constraints.maxWidth);
                      
                      final exceededMaxLines = textPainter.didExceedMaxLines;
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 80),
                            child: GestureDetector(
                              onTap: _navigateToDetailedPage,
                              child:  Text(
                              widget.reel['description'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              maxLines: _showFullDescription ? null : 3,
                              overflow: TextOverflow.ellipsis,
                            ),),
                          ),
                          if (exceededMaxLines)
                            TextButton(
                              onPressed: _navigateToDetailedPage,
                              child: Row(
                                children: [
              Text(
                                    'Read more',
                                    style: TextStyle(
                                      color: Colors.amber[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 12,
                                    color: Colors.amber[400],
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
              ),
            ],
          ),
        ),
        Positioned(
          right: 10,
          bottom: 20,
          child: Column(
            children: [
              IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.white),
                onPressed: () {},
              ),
              Text(
                '${widget.reel['likes']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
              ),
              const SizedBox(height: 20),
              IconButton(
                icon: Icon(widget.reel['isSaved'] ?? false 
                  ? Icons.bookmark : Icons.bookmark_border, color: Colors.white),
                onPressed: () {},
              ),
              Text(
                '${widget.reel['comments']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
              ),
            ],
          ),
        ),
      
      
      ],
        );
      },
    );
  }
}
