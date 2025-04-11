import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'data/models/post_model.dart';
import 'data/repositories/feed_repository.dart';

enum FeedState { initial, loading, loaded, error }

class FeedController extends ChangeNotifier {
  final FeedRepository _repository;
  
  List<PostModel> _posts = [];
  FeedState _state = FeedState.initial;
  String _errorMessage = '';
  int _currentIndex = 0;
  bool _isLoggedIn = false;

  // Construtor com injeção explícita do repository
  FeedController({required FeedRepository repository}) 
      : _repository = repository;

  // Getters
  List<PostModel> get posts => _posts;
  FeedState get state => _state;
  String get errorMessage => _errorMessage;
  int get currentIndex => _currentIndex;
  bool get isLoggedIn => _isLoggedIn;
  bool get hasVideos => _posts.isNotEmpty;

  // Login com email e senha
  Future<void> login(String email, String password) async {
    try {
      _state = FeedState.loading;
      notifyListeners();
      
      await _repository.login(email, password);
      _isLoggedIn = true;
      
      // Após login bem-sucedido, carrega os vídeos
      await loadVideos();
    } catch (e) {
      _state = FeedState.error;
      _errorMessage = 'Erro ao fazer login: ${e.toString()}';
      notifyListeners();
    }
  }

  // Carrega os vídeos do feed
  Future<void> loadVideos() async {
    if (!_isLoggedIn) {
      _state = FeedState.error;
      _errorMessage = 'É necessário fazer login primeiro';
      notifyListeners();
      return;
    }

    try {
      _state = FeedState.loading;
      notifyListeners();
      
      final videoPosts = await _repository.getVideoFeed();
      
      if (videoPosts.isEmpty) {
        _state = FeedState.loaded;
        _errorMessage = 'Nenhum vídeo encontrado';
      } else {
        _posts = videoPosts;
        _state = FeedState.loaded;
        _errorMessage = '';
      }
    } catch (e) {
      _state = FeedState.error;
      _errorMessage = 'Erro ao carregar vídeos: ${e.toString()}';
    }
    
    notifyListeners();
  }

  // Atualiza o índice do vídeo atual
  void updateCurrentIndex(int index) {
    if (index != _currentIndex && index >= 0 && index < _posts.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  // Verificação para implementação de scroll infinito (opcional)
  bool shouldLoadMore(int currentIndex) {
    // Carrega mais vídeos quando estiver próximo ao final da lista
    return _isLoggedIn && 
           _state != FeedState.loading && 
           currentIndex >= (_posts.length - 3);
  }
}