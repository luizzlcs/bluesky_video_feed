import 'package:bluesky_video_feed/features/feed/data/models/post_model.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bluesky_video_feed/core/utils/video_util.dart';

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
  ChewieController? _chewieController;
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.post.hasVideo) {
      _loadVideo(widget.post.videoUrl!);
    }
  }

  Future<void> _loadVideo(String url) async {
    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(url),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
        ),
      );

      await controller.initialize();
      
      if (!controller.value.isInitialized) {
        setState(() {
          _errorMessage = 'Falha ao inicializar o vídeo';
        });
        return;
      }

      _chewieController = ChewieController(
        videoPlayerController: controller,
        autoPlay: false,
        looping: true,
        allowFullScreen: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        aspectRatio: controller.value.aspectRatio,
        placeholder: widget.post.thumbnailUrl != null
            ? Image.network(widget.post.thumbnailUrl!)
            : null,
      );

      setState(() {
        _controller = controller;
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar vídeo';
      });
    }
  }

  Widget _buildContent() {
    if (!widget.post.hasContent) {
      return const Center(
        child: Text('Nenhum conteúdo disponível'),
      );
    }

    if (widget.post.hasVideo) {
      if (_errorMessage != null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        );
      }

      if (_isInitialized) {
        return widget.post.videoUrl!.toLowerCase().endsWith('.gif')
            ? Image.network(
                widget.post.videoUrl!,
                fit: BoxFit.contain,
              )
            : _chewieController != null
                ? Chewie(controller: _chewieController!)
                : const Center(child: CircularProgressIndicator());
      }

      return const Center(child: CircularProgressIndicator());
    }

    if (widget.post.hasImages) {
      return PageView.builder(
        itemCount: widget.post.images!.length,
        itemBuilder: (context, index) {
          return CachedNetworkImage(
            imageUrl: widget.post.images![index],
            fit: BoxFit.contain,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(),
            ),
            errorWidget: (context, url, error) => const Center(
              child: Icon(Icons.error_outline, color: Colors.red),
            ),
          );
        },
      );
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(
          widget.post.text,
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho com informações do autor
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: widget.post.author.avatarUrl != null
                      ? NetworkImage(widget.post.author.avatarUrl!)
                      : null,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post.author.displayName ?? widget.post.author.handle,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '@${widget.post.author.handle}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Conteúdo principal
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _controller?.dispose();
    super.dispose();
  }
}