import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'HLSVideoPlayer.dart';

class ReelDetailedPage extends StatefulWidget {
  final Map<String, dynamic> reel;

  const ReelDetailedPage({required this.reel, super.key});

  @override
  State<ReelDetailedPage> createState() => _ReelDetailedPageState();
}

class _ReelDetailedPageState extends State<ReelDetailedPage> {
  int _currentImageIndex = 0;
  late PageController _imagePageController;
  final String _selectedQuality = '720p'; // Default quality

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
      // Use the selected quality or fallback to available quality
      final formats = widget.reel['videoFormats'] as Map<String, dynamic>;
      return formats[_selectedQuality] ?? formats['720p'] ?? formats['480p'] ?? formats['1080p'];
    }
    return '';
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

  Widget _buildMediaContent() {
    if (widget.reel['type'] == 'video') {
      final videoUrl = _getVideoUrl();
      if (videoUrl.isEmpty) {
        return const Center(child: Text('Video not available', style: TextStyle(color: Colors.white)));
      }
      
      return AspectRatio(
        aspectRatio: 16/9,
        child: HLSVideoPlayer(
          videoUrl: videoUrl,
          videoId: widget.reel['_id'],
          autoPlay: true,
          looping: true,
        ),
      );
    } else {
      final images = widget.reel['images'] as List<dynamic>;
      if (images.isEmpty) {
        return const Center(child: Text('No images available', style: TextStyle(color: Colors.white)));
      }

      if (images.length == 1) {
        return AspectRatio(
          aspectRatio: 16/9,
          child: Image.network(
            images[0]['large'] ?? images[0]['medium'] ?? images[0]['original'],
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        );
      } else {
        return AspectRatio(
          aspectRatio: 16/9,
          child: Stack(
            children: [
              PageView.builder(
                controller: _imagePageController,
                itemCount: images.length,
                physics: const ClampingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final image = images[index];
                  return Image.network(
                    image['large'] ?? image['medium'] ?? image['original'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  );
                },
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
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMediaContent(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Info and Type Badge
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey[800],
                        child: Text(
                          widget.reel['username'][0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '@${widget.reel['username']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _buildTypeBadge(widget.reel['contentType']),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Description
                  Text(
                    widget.reel['description'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Additional Information
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Market Analysis',
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'This analysis provides insights into current market trends and potential trading opportunities. The content demonstrates key technical indicators and support/resistance levels.',
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Engagement Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(Icons.favorite, widget.reel['likes'], 'Likes'),
                      _buildStatItem(Icons.comment, widget.reel['comments'], 'Comments'),
                      _buildStatItem(Icons.share, 0, 'Share'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, int count, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
} 

