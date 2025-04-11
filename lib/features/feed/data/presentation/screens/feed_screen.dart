import 'package:bluesky_video_feed/core/services/service_locator.dart';
import 'package:bluesky_video_feed/features/feed/feed_controller.dart';
import 'package:flutter/material.dart';
import '../widgets/video_card.dart';
import '../widgets/login_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final PageController _pageController = PageController();
  
  // Obtém o controller via GetIt
  final _controller = getIt<FeedController>();

  @override
  void initState() {
    super.initState();
    // Adiciona um listener ao controller para reconstruir a UI quando o estado mudar
    _controller.addListener(_updateUI);
  }
  
  void _updateUI() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controller.removeListener(_updateUI);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mostra tela de login se o usuário não estiver logado
    if (!_controller.isLoggedIn) {
      return const LoginScreen();
    }

    // Mostra tela de carregamento inicial
    if (_controller.state == FeedState.loading && _controller.posts.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Carregando vídeos...'),
            ],
          ),
        ),
      );
    }

    // Mostra mensagem de erro se não conseguiu carregar os vídeos
    if (_controller.state == FeedState.error) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bluesky Video Feed')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 70, color: Colors.red),
              const SizedBox(height: 20),
              Text(
                _controller.errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _controller.loadVideos(),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    // Mostra mensagem se não encontrou vídeos
    if (_controller.posts.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bluesky Video Feed')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.videocam_off, size: 70, color: Colors.grey),
              const SizedBox(height: 20),
              const Text(
                'Nenhum vídeo encontrado',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _controller.loadVideos(),
                child: const Text('Atualizar'),
              ),
            ],
          ),
        ),
      );
    }

    // Feed de vídeos principal
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.loadVideos(),
          ),
        ],
      ),
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        itemCount: _controller.posts.length,
        onPageChanged: (index) {
          _controller.updateCurrentIndex(index);
          
          // Implementação do scroll infinito (opcional)
          if (_controller.shouldLoadMore(index)) {
            _controller.loadVideos();
          }
        },
        itemBuilder: (context, index) {
          final post = _controller.posts[index];
          return VideoCard(
            post: post,
            isCurrentVideo: index == _controller.currentIndex,
          );
        },
      ),
    );
  }
}