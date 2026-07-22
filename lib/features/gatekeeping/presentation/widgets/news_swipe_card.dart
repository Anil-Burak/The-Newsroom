import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/news_item.dart';
import '../../../../core/theme/app_theme.dart';

class NewsSwipeCard extends StatelessWidget {
  final NewsItem news;

  const NewsSwipeCard({super.key, required this.news});

  Color get _categoryColor {
    switch (news.category.toLowerCase()) {
      case 'siyaset':
        return const Color(0xFF4A90D9);
      case 'suç':
        return AppColors.rejectRed;
      case 'magazin':
        return const Color(0xFFE91E8C);
      case 'ekonomi':
        return const Color(0xFF2ECC71);
      case 'bilim':
        return const Color(0xFF9B59B6);
      case 'spor':
        return const Color(0xFFFF9800);
      default:
        return AppColors.gold;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: AppColors.inkSurface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  news.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: news.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: AppColors.inkMid,
                            child: const Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.gold),
                            ),
                          ),
                          errorWidget: (_, __, ___) => _PlaceholderImage(
                              category: news.category,
                              color: _categoryColor),
                        )
                      : _PlaceholderImage(
                          category: news.category, color: _categoryColor),
                  // Image overlay gradient
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xCC0D0D0D)],
                        stops: [0.5, 1.0],
                      ),
                    ),
                  ),
                  // Category badge
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _categoryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        news.category.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  // Sensationalism indicator
                  Positioned(
                    top: 16,
                    right: 16,
                    child: _SensationalismBadge(score: news.sensationalismScore),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        news.headline,
                        style: Theme.of(context).textTheme.headlineMedium,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        news.summary,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Tags
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: news.tags
                          .take(3)
                          .map((tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.glassSurface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: const Border.fromBorderSide(
                                      BorderSide(color: AppColors.glassBorder)),
                                ),
                                child: Text(
                                  '#$tag',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: AppColors.textSecondary),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SensationalismBadge extends StatelessWidget {
  final int score;
  const _SensationalismBadge({required this.score});

  Color get _color {
    if (score >= 75) return AppColors.rejectRed;
    if (score >= 45) return AppColors.gold;
    return AppColors.publishGreen;
  }

  String get _label {
    if (score >= 75) return '🔥 YÜKSEK';
    if (score >= 45) return '⚡ ORTA';
    return '✅ DÜŞÜK';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _label,
        style: const TextStyle(
            fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  final String category;
  final Color color;
  const _PlaceholderImage({required this.category, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color.withOpacity(0.15),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.article_rounded, size: 64, color: color.withOpacity(0.5)),
            const SizedBox(height: 8),
            Text(
              category,
              style: TextStyle(color: color.withOpacity(0.7), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
