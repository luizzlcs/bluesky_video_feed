import 'author_model.dart';
import '../../../../core/utils/video_util.dart';
import 'package:flutter/foundation.dart';

class PostModel {
  final String uri;
  final String cid;
  final AuthorModel author;
  final String text;
  final String? videoUrl;
  final String? thumbnailUrl;
  final List<String>? images;
  final Map<String, dynamic> record;
  final DateTime createdAt;
  final String? accessJwt;
  final String? embedType;
  final String? externalUrl;
  final String? mediaType;
  final Map<String, dynamic>? mediaData;

  PostModel({
    required this.uri,
    required this.cid,
    required this.author,
    required this.text,
    this.videoUrl,
    this.thumbnailUrl,
    this.images,
    required this.record,
    required this.createdAt,
    this.accessJwt,
    this.embedType,
    this.externalUrl,
    this.mediaType,
    this.mediaData,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final post = json['post'];
    final record = post['record'];
    final embed = record['embed'];
    
    String? videoUrl;
    String? thumbnailUrl;
    List<String>? images;
    String? accessJwt;
    String? embedType;
    String? externalUrl;
    String? mediaType;
    Map<String, dynamic>? mediaData;
    
    if (embed != null) {
      embedType = embed['\$type'];
      debugPrint('Tipo de embed encontrado: $embedType');
      
      // Obtém o did do autor do post
      final authorDid = post['author']?['did'];
      
      // Extrai URLs de vídeo
      videoUrl = VideoUtil.extractVideoUrl(embed, did: authorDid);
      
      // Processa diferentes tipos de embed
      switch (embedType) {
        case 'app.bsky.embed.images':
          final imageList = embed['images'] as List?;
          if (imageList != null && imageList.isNotEmpty) {
            // Usa a primeira imagem como thumbnail
            final firstImage = imageList.first;
            if (firstImage['image'] != null && firstImage['image']['ref'] != null) {
              final link = firstImage['image']['ref']['\$link'] as String;
              if (authorDid != null) {
                thumbnailUrl = 'https://bsky.social/xrpc/com.atproto.sync.getBlob?cid=$link&did=$authorDid';
              } else {
                thumbnailUrl = 'https://bsky.social/xrpc/com.atproto.sync.getBlob?cid=$link';
              }
            }
            
            images = imageList.map((image) {
              if (image['image'] != null && image['image']['ref'] != null) {
                final link = image['image']['ref']['\$link'] as String;
                if (authorDid != null) {
                  return 'https://bsky.social/xrpc/com.atproto.sync.getBlob?cid=$link&did=$authorDid';
                }
                return 'https://bsky.social/xrpc/com.atproto.sync.getBlob?cid=$link';
              }
              return '';
            }).where((url) => url.isNotEmpty).toList();
          }
          mediaType = 'image';
          mediaData = {'images': images};
          break;
          
        case 'app.bsky.embed.external':
          final external = embed['external'];
          if (external != null) {
            externalUrl = external['uri'] as String?;
            if (external['thumb'] != null) {
              final thumb = external['thumb'];
              final link = thumb['ref']?['\$link'] as String?;
              if (link != null && authorDid != null) {
                thumbnailUrl = 'https://bsky.social/xrpc/com.atproto.sync.getBlob?cid=$link&did=$authorDid';
              }
            }
          }
          mediaType = 'external';
          mediaData = {'url': externalUrl};
          break;
          
        case 'app.bsky.embed.record':
          final record = embed['record'];
          if (record != null && record['value'] != null) {
            final value = record['value'];
            if (value['text'] != null) {
              mediaType = 'text';
              mediaData = {'text': value['text']};
            }
            if (value['embed'] != null) {
              // Recursivamente processa embeds aninhados
              final nestedEmbed = value['embed'];
              final nestedType = nestedEmbed['\$type'];
              if (nestedType == 'app.bsky.embed.images') {
                final imageList = nestedEmbed['images'] as List?;
                if (imageList != null && imageList.isNotEmpty) {
                  images = imageList.map((image) {
                    if (image['image'] != null && image['image']['ref'] != null) {
                      final link = image['image']['ref']['\$link'] as String;
                      if (authorDid != null) {
                        return 'https://bsky.social/xrpc/com.atproto.sync.getBlob?cid=$link&did=$authorDid';
                      }
                      return 'https://bsky.social/xrpc/com.atproto.sync.getBlob?cid=$link';
                    }
                    return '';
                  }).where((url) => url.isNotEmpty).toList();
                }
                mediaType = 'image';
                mediaData = {'images': images};
              }
            }
          }
          break;
          
        case 'app.bsky.embed.recordWithMedia':
          final media = embed['media'];
          if (media != null) {
            final nestedMediaType = media['\$type'];
            if (nestedMediaType == 'app.bsky.embed.images') {
              final imageList = media['images'] as List?;
              if (imageList != null && imageList.isNotEmpty) {
                images = imageList.map((image) {
                  if (image['image'] != null && image['image']['ref'] != null) {
                    final link = image['image']['ref']['\$link'] as String;
                    if (authorDid != null) {
                      return 'https://bsky.social/xrpc/com.atproto.sync.getBlob?cid=$link&did=$authorDid';
                    }
                    return 'https://bsky.social/xrpc/com.atproto.sync.getBlob?cid=$link';
                  }
                  return '';
                }).where((url) => url.isNotEmpty).toList();
              }
              mediaType = 'image';
              mediaData = {'images': images};
            }
          }
          break;
      }
    }

    // Obtém o token de autenticação
    accessJwt = json['accessJwt'] as String?;
    debugPrint('Token de autenticação extraído: ${accessJwt != null ? 'Sim' : 'Não'}');

    String text = '';
    if (record['text'] != null) {
      if (record['text'] is String) {
        text = record['text'];
      } else if (record['text'] is Map) {
        text = record['text']['text'] ?? record['text']['value'] ?? '';
      }
    }

    return PostModel(
      uri: post['uri'] ?? '',
      cid: post['cid'] ?? '',
      author: AuthorModel.fromJson(post['author']),
      text: text,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      images: images,
      record: record,
      createdAt: DateTime.parse(record['createdAt'] ?? DateTime.now().toIso8601String()),
      accessJwt: accessJwt,
      embedType: embedType,
      externalUrl: externalUrl,
      mediaType: mediaType,
      mediaData: mediaData,
    );
  }

  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;
  bool get hasImages => images != null && images!.isNotEmpty;
  bool get hasText => text.isNotEmpty;
  bool get hasExternalContent => externalUrl != null && externalUrl!.isNotEmpty;
  bool get hasContent => hasVideo || hasImages || hasText || hasExternalContent;
  
  // Métodos para verificar o tipo de mídia
  bool get isImagePost => mediaType == 'image';
  bool get isVideoPost => mediaType == 'video';
  bool get isTextPost => mediaType == 'text';
  bool get isExternalPost => mediaType == 'external';
}