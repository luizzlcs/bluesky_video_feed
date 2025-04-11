class VideoUtil {
  // Verifica se uma URL contém um vídeo
  static bool isVideo(String? url) {
    if (url == null) return false;
    final lowerUrl = url.toLowerCase();
    return lowerUrl.endsWith('.mp4') || 
           lowerUrl.endsWith('.mov') || 
           lowerUrl.contains('video') ||
           lowerUrl.contains('/v/');
  }
  
  // Extrai a URL do vídeo dos diferentes formatos possíveis de embed
  static String? extractVideoUrl(Map<String, dynamic>? embed) {
    if (embed == null) return null;
    
    final type = embed['\$type'];
    
    // Caso 1: Embed externo (link para .mp4)
    if (type == 'app.bsky.embed.external') {
      final external = embed['external'];
      if (external != null && external['uri'] != null) {
        final uri = external['uri'] as String;
        if (isVideo(uri)) {
          return uri;
        }
      }
    }
    
    // Caso 2: Embed de mídia (novo formato do Bluesky)
    if (type == 'app.bsky.embed.media' || type == 'app.bsky.embed.images') {
      final media = embed['media'] ?? embed['images'];
      if (media is List && media.isNotEmpty) {
        for (final item in media) {
          if (item != null && item['fullsize'] != null) {
            final uri = item['fullsize'] as String;
            if (isVideo(uri)) {
              return uri;
            }
          }
        }
      }
    }
    
    // Caso 3: Embed de rich text (frequentemente usado para vídeos)
    if (type == 'app.bsky.embed.record') {
      final record = embed['record'];
      if (record != null && record['value'] != null) {
        final value = record['value'];
        if (value['text'] != null && value['text'].contains('youtu')) {
          // Extrair ID do YouTube e construir URL de embed do YouTube
          final regex = RegExp(r'(?:youtube\.com\/watch\?v=|youtu\.be\/)([^&\s]+)');
          final match = regex.firstMatch(value['text']);
          if (match != null) {
            return 'https://www.youtube.com/embed/${match.group(1)}';
          }
        }
      }
    }
    
    return null;
  }
}