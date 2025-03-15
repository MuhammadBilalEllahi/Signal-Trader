import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:tradingapp/pages/newsAlerts/components/ReelDetailedPage.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:provider/provider.dart';
import 'package:tradingapp/pages/newsAlerts/providers/news_alerts_provider.dart';
import 'package:tradingapp/pages/newsAlerts/components/HLSVideoPlayer.dart';
import 'package:tradingapp/pages/newsAlerts/services/news_alerts_service.dart';

class NewsAlerts extends StatefulWidget {
  const NewsAlerts({super.key});

  @override
  State<NewsAlerts> createState() => _NewsAlertsState();
}

class _NewsAlertsState extends State<NewsAlerts> {
  late PageController _pageController;
  final NewsAlertsService _newsAlertsService = NewsAlertsService();
  List<Map<String, dynamic>> reels = [];
  bool _isLoading = true;
  int _currentPage = 1;
  bool _hasMore = true;
  static const int _pageSize = 2;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<NewsAlertsProvider>(context, listen: false);
    _pageController = PageController(initialPage: provider.currentReelIndex);
    _loadInitialReels();
  }

  Future<void> _loadInitialReels() async {
    setState(() => _isLoading = true);
    final newsAlerts = await _newsAlertsService.fetchNewsAlerts(page: _currentPage, limit: _pageSize);
    
    if (mounted) {
      setState(() {
        reels = newsAlerts;
        _isLoading = false;
        _hasMore = newsAlerts.length >= _pageSize;
      });
    }
  }

  Future<void> _loadMoreReels() async {
    if (!_hasMore || _isLoading) return;

    setState(() => _isLoading = true);
    final moreNewsAlerts = await _newsAlertsService.fetchNewsAlerts(
      page: _currentPage + 1,
      limit: _pageSize,
    );

    if (mounted) {
      setState(() {
        reels.addAll(moreNewsAlerts);
        _currentPage++;
        _isLoading = false;
        _hasMore = moreNewsAlerts.length >= _pageSize;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && reels.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (reels.isEmpty) {
      return const Center(child: Text('No news alerts available'));
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 25),
        child: SizedBox.expand(
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                _loadMoreReels();
              }
              return true;
            },
        child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
              itemCount: reels.length + (_hasMore ? 1 : 0),
          onPageChanged: (index) {
            Provider.of<NewsAlertsProvider>(context, listen: false)
                .setCurrentReelIndex(index);
                
                if (index == reels.length - 2) {
                  _loadMoreReels();
                }
          },
        itemBuilder: (context, index) {
                if (index == reels.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                debugPrint("reels[index]ii---- ${reels[index]}");
          return ReelItem(reel: reels[index]);
        },
        ),
        ),
        ),
      ),
    );
  }
}

class ReelItem extends StatefulWidget {
  final Map<String, dynamic> reel;
  
  const ReelItem({super.key, required this.reel});

  @override
  State<ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<ReelItem> {
  int _currentImageIndex = 0;
  late PageController _imagePageController;
  HLSVideoPlayer? _videoPlayer;

  @override
  void initState() {
    super.initState();
    _imagePageController = PageController();
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  String _getVideoUrl() {
    if (widget.reel['type'] == 'video' && widget.reel['videoFormats'] != null) {
      final formats = widget.reel['videoFormats'] as Map<String, dynamic>;
      return formats['720p'] ?? formats['480p'] ?? formats['1080p'] ?? '';
    }
    return '';
  }

  Widget _buildTypeBadge(String type) {
    Color startColor;
    Color endColor;
    String text;
    Color textColor;

    switch (type.toUpperCase()) {
      case 'CRYPTO':
        startColor = Colors.grey.shade700;
        endColor = Colors.grey.shade500;
        text = "CRYPTO";
        textColor = Colors.white;
        break;
      case 'STOCKS':
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

  Widget _buildMediaContent() {
    if (widget.reel['type'] == 'video') {
      final videoUrl = _getVideoUrl();
      if (videoUrl.isEmpty) {
        return const Center(child: Text('Video not available', style: TextStyle(color: Colors.white)));
      }
      
      _videoPlayer = HLSVideoPlayer(
        videoUrl: videoUrl,
        videoId: widget.reel['_id'] ?? '',
        videoFormats: widget.reel['videoFormats'],
        autoPlay: true,
        looping: true,
        onDispose: () {
          _videoPlayer = null;
        },
      );
      
      return SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: _videoPlayer!,
      );
    } else {
      final images = widget.reel['images'] as List<dynamic>;
      if (images.isEmpty) {
        return const Center(child: Text('No images available', style: TextStyle(color: Colors.white)));
      }

      if (images.length == 1) {
        final image = images[0] as Map<String, dynamic>;
        return SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Image.network(
            image['large'] ?? image['medium'] ?? image['original'],
            fit: BoxFit.contain,
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
                  final image = images[index] as Map<String, dynamic>;
                  return Image.network(
                    image['large'] ?? image['medium'] ?? image['original'],
                    fit: BoxFit.contain,
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
             _buildMediaContent(),
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
                        '${widget.reel['title']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
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
                        maxLines: 3,
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
                              child: Text(
                              widget.reel['description'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                                maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              ),
                            ),
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
                    icon: Icon(
                      widget.reel['isSaved'] ?? false 
                        ? Icons.bookmark 
                        : Icons.bookmark_border,
                      color: Colors.white
                    ),
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
