import 'package:flutter/foundation.dart';

class VideoUtil {
  // Lista de tipos MIME de vídeo suportados
  static const List<String> videoMimeTypes = [
    'video/mp4',
    'video/webm',
    'video/quicktime',
    'video/x-msvideo',
    'video/3gpp',
    'video/x-matroska',
  ];

  // Lista de extensões de vídeo suportadas
  static const List<String> videoExtensions = [
    '.mp4',
    '.webm',
    '.mov',
    '.avi',
    '.3gp',
    '.mkv',
  ];

  // Verifica se um blob é um vídeo pelo tipo MIME
  static bool isVideoMimeType(String? mimeType) {
    if (mimeType == null) return false;
    return videoMimeTypes.contains(mimeType.toLowerCase());
  }

  // Verifica se uma URL contém um vídeo
  static bool isVideoUrl(String? url) {
    if (url == null) return false;
    final lowerUrl = url.toLowerCase();
    return videoExtensions.any((ext) => lowerUrl.endsWith(ext)) ||
           lowerUrl.contains('video') ||
           lowerUrl.contains('/v/');
  }
  
  // Extrai a URL do vídeo dos diferentes formatos possíveis de embed
  static String? extractVideoUrl(Map<String, dynamic>? embed, {String? did}) {
    if (embed == null) return null;
    
    final type = embed['\$type'];
    debugPrint('Processando embed do tipo: $type');
    debugPrint('Estrutura do embed: $embed');
    
    // Caso 1: Embed de vídeo direto do Bluesky
    if (type == 'app.bsky.embed.video') {
      final video = embed['video'];
      if (video != null) {
        debugPrint('Processando vídeo: $video');
        
        // Verifica o blob do vídeo
        if (video['ref'] != null) {
          final blob = video;
          final mimeType = blob['mimeType'] as String?;
          debugPrint('MimeType do blob: $mimeType');
          
          if (isVideoMimeType(mimeType)) {
            final link = blob['ref']?['\$link'] as String?;
            if (link != null && did != null) {
              final videoUrl = 'https://bsky.social/xrpc/com.atproto.sync.getBlob?cid=$link&did=$did';
              debugPrint('Encontrado vídeo do Bluesky: $videoUrl');
              return videoUrl;
            }
          } else {
            debugPrint('Blob não é um vídeo: $blob');
          }
        }
        
        // Verifica se tem URL direta
        if (video['url'] != null) {
          final url = video['url'] as String;
          if (isVideoUrl(url)) {
            debugPrint('Encontrado URL de vídeo direta: $url');
            return url;
          }
        }
      }
    }
    
    // Caso 2: Embed de record com mídia
    if (type == 'app.bsky.embed.recordWithMedia') {
      final media = embed['media'];
      if (media != null) {
        debugPrint('Processando media do recordWithMedia: $media');
        // Tenta extrair vídeo do media
        final videoUrl = extractVideoUrl(media, did: did);
        if (videoUrl != null) {
          return videoUrl;
        }
      }
    }
    
    // Caso 3: Embed externo (link para vídeo)
    if (type == 'app.bsky.embed.external') {
      final external = embed['external'];
      if (external != null) {
        // Verifica URI
        if (external['uri'] != null) {
          final uri = external['uri'] as String;
          if (isVideoUrl(uri)) {
            debugPrint('Encontrado vídeo externo: $uri');
            return uri;
          }
        }
        
        // Verifica thumb
        if (external['thumb'] != null) {
          final thumb = external['thumb'];
          final mimeType = thumb['mimeType'] as String?;
          if (isVideoMimeType(mimeType)) {
            final link = thumb['ref']?['\$link'] as String?;
            if (link != null && did != null) {
              final videoUrl = 'https://bsky.social/xrpc/com.atproto.sync.getBlob?cid=$link&did=$did';
              debugPrint('Encontrado vídeo no thumb: $videoUrl');
              return videoUrl;
            }
          }
        }
      }
    }
    
    // Caso 4: Embed de mídia (novo formato do Bluesky)
    if (type == 'app.bsky.embed.media' || type == 'app.bsky.embed.images') {
      final media = embed['media'] ?? embed['images'];
      if (media is List && media.isNotEmpty) {
        for (final item in media) {
          if (item != null) {
            // Verifica fullsize
            if (item['fullsize'] != null) {
              final uri = item['fullsize'] as String;
              if (isVideoUrl(uri)) {
                debugPrint('Encontrado vídeo em fullsize: $uri');
                return uri;
              }
            }
            
            // Verifica blob
            if (item['blob'] != null) {
              final blob = item['blob'];
              final mimeType = blob['mimeType'] as String?;
              if (isVideoMimeType(mimeType)) {
                final link = blob['ref']?['\$link'] as String?;
                if (link != null && did != null) {
                  final videoUrl = 'https://bsky.social/xrpc/com.atproto.sync.getBlob?cid=$link&did=$did';
                  debugPrint('Encontrado vídeo no blob: $videoUrl');
                  return videoUrl;
                }
              }
            }
          }
        }
      }
    }
    
    // Caso 5: Embed de rich text (frequentemente usado para vídeos)
    if (type == 'app.bsky.embed.record') {
      final record = embed['record'];
      if (record != null) {
        debugPrint('Processando record: $record');
        
        // Tenta extrair vídeo do record
        if (record['value'] != null) {
          final value = record['value'];
          debugPrint('Valor do record: $value');
          
          // Verifica se tem texto com link de vídeo
          if (value['text'] != null) {
            final text = value['text'] as String;
            debugPrint('Texto do record: $text');
            
            // Verifica links do YouTube
            if (text.contains('youtu')) {
              final regex = RegExp(r'(?:youtube\.com\/watch\?v=|youtu\.be\/)([^&\s]+)');
              final match = regex.firstMatch(text);
              if (match != null) {
                final youtubeUrl = 'https://www.youtube.com/embed/${match.group(1)}';
                debugPrint('Encontrado vídeo do YouTube: $youtubeUrl');
                return youtubeUrl;
              }
            }
            
            // Verifica outros links de vídeo
            final videoRegex = RegExp(r'https?:\/\/(?:www\.)?[^\s]+\.(?:mp4|mov|webm|avi|3gp|mkv)');
            final videoMatch = videoRegex.firstMatch(text);
            if (videoMatch != null) {
              final videoUrl = videoMatch.group(0);
              debugPrint('Encontrado link de vídeo no texto: $videoUrl');
              return videoUrl;
            }
          }
          
          // Verifica se tem embed dentro do record
          if (value['embed'] != null) {
            debugPrint('Encontrado embed dentro do record');
            return extractVideoUrl(value['embed'], did: did);
          }
        }
      }
    }
    
    debugPrint('Nenhum vídeo encontrado no embed do tipo: $type');
    return null;
  }
}