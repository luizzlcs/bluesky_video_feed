import 'author_model.dart';
import '../../../../core/utils/video_util.dart';

class PostModel {
  final String uri;
  final String cid;
  final AuthorModel author;
  final String text;
  final String? videoUrl;
  final DateTime createdAt;

  PostModel({
    required this.uri,
    required this.cid,
    required this.author,
    required this.text,
    this.videoUrl,
    required this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final post = json['post'];
    final record = post['record'];
    final embed = record['embed'];
    
    String? videoUrl;
    if (embed != null) {
      videoUrl = VideoUtil.extractVideoUrl(embed);
    }

    return PostModel(
      uri: post['uri'] ?? '',
      cid: post['cid'] ?? '',
      author: AuthorModel.fromJson(post['author']),
      text: record['text'] ?? '',
      videoUrl: videoUrl,
      createdAt: DateTime.parse(record['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;
}