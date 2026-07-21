import 'dart:convert';

class NewsItem {
  final String id;
  final String headline;
  final String summary;
  final String imageUrl;
  final String category;
  final int sensationalismScore; // 0–100
  final int biasIndex; // negative=left, 0=neutral, positive=right
  final List<String> tags;

  const NewsItem({
    required this.id,
    required this.headline,
    required this.summary,
    required this.imageUrl,
    required this.category,
    required this.sensationalismScore,
    required this.biasIndex,
    required this.tags,
  });

  factory NewsItem.fromMap(Map<String, dynamic> map) {
    // tags is stored as a JSON string in SQLite
    List<String> parsedTags = [];
    final rawTags = map['tags'];
    if (rawTags is String) {
      try {
        parsedTags = List<String>.from(jsonDecode(rawTags) as List);
      } catch (_) {
        parsedTags = [];
      }
    } else if (rawTags is List) {
      parsedTags = List<String>.from(rawTags);
    }

    return NewsItem(
      id: map['id'] as String? ?? '',
      headline: map['headline'] as String? ?? '',
      summary: map['summary'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      category: map['category'] as String? ?? '',
      sensationalismScore: map['sensationalismScore'] as int? ?? 0,
      biasIndex: map['biasIndex'] as int? ?? 0,
      tags: parsedTags,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'headline': headline,
        'summary': summary,
        'imageUrl': imageUrl,
        'category': category,
        'sensationalismScore': sensationalismScore,
        'biasIndex': biasIndex,
        'tags': jsonEncode(tags),
      };
}
