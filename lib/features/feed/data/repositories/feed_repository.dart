import 'dart:convert';

import 'package:flutter/widgets.dart';

import '../datasources/bluesky_datasource.dart';
import '../models/post_model.dart';
import '../models/session_model.dart';

class FeedRepository {
  final BlueskyDatasource _datasource;

  // Construtor com injeção explícita do datasource
  FeedRepository({required BlueskyDatasource datasource}) 
      : _datasource = datasource;

  Future<SessionModel> login(String email, String password) async {
    return await _datasource.createSession(
      identifier: email,
      password: password,
    );
  }

  Future<List<PostModel>> getVideoFeed({int limit = 50}) async {
  final feedItems = await _datasource.getTimeline(limit: limit);
  
  debugPrint("Total de posts encontrados: ${feedItems.length}");
  
  // Verifique a estrutura dos posts recebidos
  if (feedItems.isNotEmpty) {
    debugPrint("Estrutura do primeiro post: ${jsonEncode(feedItems[0])}");
  }
  
  // Converte os itens do feed em PostModel
  final allPosts = feedItems.map((item) => PostModel.fromJson(item)).toList();
  debugPrint("Posts convertidos: ${allPosts.length}");
  
  // Filtra apenas posts com vídeos
  final videoPosts = allPosts.where((post) => post.hasVideo).toList();
  debugPrint("Posts com vídeo: ${videoPosts.length}");
  
  return videoPosts;
}
}