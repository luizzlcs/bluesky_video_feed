import 'package:bluesky_video_feed/features/feed/data/models/post_model.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';

class VideoCard extends StatefulWidget {
 final PostModel post;
  final bool isCurrentVideo;

  const VideoCard({
    super.key,
    required this.post,
    required this.isCurrentVideo,
  });

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  VideoPlayerController? _controller;
  bool _isPlaying = false;
  bool _isInitialized = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(VideoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Controla o play/pause quando o vídeo atual muda
    if (widget.isCurrentVideo != oldWidget.isCurrentVideo) {
      if (widget.isCurrentVideo) {
        _playVideo();
      } else {
        _pauseVideo();
      }
    }
  }

  Future<void> _initializeVideo() async {
    if (widget.post.videoUrl != null) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.post.videoUrl!));
      
      await _controller!.initialize();
      
      setState(() {
        _isInitialized = true;
        _isPlaying = widget.isCurrentVideo;
      });
      
      if (widget.isCurrentVideo) {
        _playVideo();
      }
      
      // Configura loop do vídeo
      _controller!.setLooping(true);
    }
  }

  void _playVideo() {
    if (_controller != null && _isInitialized) {
      _controller!.play();
      setState(() {
        _isPlaying = true;
      });
      
      // Oculta os controles após 2 segundos
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  void _pauseVideo() {
    if (_controller != null && _isInitialized) {
      _controller!.pause();
      setState(() {
        _isPlaying = false;
        _showControls = true;
      });
    }
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _pauseVideo();
    } else {
      _playVideo();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showControls = !_showControls;
        });
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Vídeo
          _isInitialized
              ? VideoPlayer(_controller!)
              : const Center(child: CircularProgressIndicator()),
          
          // Overlay para os controles
          if (_showControls || !_isPlaying)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5],
                ),
              ),
            ),
          
          // Botão de play/pause
          if (_showControls)
            Center(
              child: IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  size: 70,
                  color: Colors.white.withOpacity(0.8),
                ),
                onPressed: _togglePlayPause,
              ),
            ),
          
          // Informações do autor
          Positioned(
            bottom: 20,
            left: 10,
            right: 10,
            child: Row(
              children: [
                // Avatar do autor
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey,
                  backgroundImage: widget.post.author.avatarUrl != null
                      ? CachedNetworkImageProvider(widget.post.author.avatarUrl!)
                      : null,
                  child: widget.post.author.avatarUrl == null
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 10),
                // Nome do autor
                Expanded(
                  child: Text(
                    widget.post.author.displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}