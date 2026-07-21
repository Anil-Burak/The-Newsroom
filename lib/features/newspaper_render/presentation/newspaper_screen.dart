import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../gatekeeping/application/gatekeeper_notifier.dart';
import '../../gatekeeping/domain/news_item.dart';
import '../../persona_selection/application/persona_selection_notifier.dart';

class NewspaperScreen extends ConsumerWidget {
  const NewspaperScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gatekeeperProvider);
    final persona = ref.watch(activePersonaProvider);
    final accepted = state.acceptedCards;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8), // aged newsprint
      body: SafeArea(
        child: Column(
          children: [
            // Newspaper masthead
            _NewspaperMasthead(personaName: persona?.name ?? 'The Daily'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: _buildLayout(context, accepted),
              ),
            ),
            // Bottom CTA
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () => context.go(AppConstants.routeComparison),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: AppColors.inkDeep,
                  foregroundColor: AppColors.gold,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('SEE THE COMPARISON'),
                    SizedBox(width: 8),
                    Icon(Icons.compare_rounded),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLayout(BuildContext context, List<NewsItem> articles) {
    final count = articles.length;
    if (count <= 0) return const SizedBox.shrink();

    if (count == 3) return _Template3(articles: articles);
    if (count == 4) return _Template4(articles: articles);
    if (count == 5) return _Template5(articles: articles);
    return _Template6(articles: articles);
  }
}

class _NewspaperMasthead extends StatelessWidget {
  final String personaName;
  const _NewspaperMasthead({required this.personaName});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Container(
      color: const Color(0xFFF5F0E8),
      child: Column(
        children: [
          // Top rule
          Container(height: 3, color: const Color(0xFF1A1A2E)),
          const SizedBox(height: 4),
          Container(height: 1, color: const Color(0xFF1A1A2E)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                Text(
                  '${personaName.toUpperCase()} DAILY',
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1A2E),
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  '${_weekday(now.weekday)}, ${_month(now.month)} ${now.day}, ${now.year}  •  Vol. CCXLII, No. ${now.millisecondsSinceEpoch % 999 + 1}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF555555),
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: const Color(0xFF1A1A2E)),
          const SizedBox(height: 2),
          Container(height: 3, color: const Color(0xFF1A1A2E)),
        ],
      ),
    );
  }

  String _weekday(int d) =>
      ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][d];
  String _month(int m) =>
      ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][m];
}

// ── Template A: 3 articles (1 hero + 2 side) ─────────────────────────────────
class _Template3 extends StatelessWidget {
  final List<NewsItem> articles;
  const _Template3({required this.articles});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HeroArticleCell(article: articles[0]),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _SmallArticleCell(article: articles[1])),
            const SizedBox(width: 8),
            Expanded(child: _SmallArticleCell(article: articles[2])),
          ],
        ),
      ],
    );
  }
}

// ── Template B: 4 articles (1 hero + 1 sub-hero + 2 small) ───────────────────
class _Template4 extends StatelessWidget {
  final List<NewsItem> articles;
  const _Template4({required this.articles});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HeroArticleCell(article: articles[0]),
        const SizedBox(height: 8),
        _SubHeroArticleCell(article: articles[1]),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _SmallArticleCell(article: articles[2])),
            const SizedBox(width: 8),
            Expanded(child: _SmallArticleCell(article: articles[3])),
          ],
        ),
      ],
    );
  }
}

// ── Template C: 5 articles ────────────────────────────────────────────────────
class _Template5 extends StatelessWidget {
  final List<NewsItem> articles;
  const _Template5({required this.articles});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: _HeroArticleCell(article: articles[0])),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _SmallArticleCell(article: articles[1]),
                  const SizedBox(height: 8),
                  _SmallArticleCell(article: articles[2]),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _SmallArticleCell(article: articles[3])),
            const SizedBox(width: 8),
            Expanded(child: _SmallArticleCell(article: articles[4])),
          ],
        ),
      ],
    );
  }
}

// ── Template D: 6 articles ────────────────────────────────────────────────────
class _Template6 extends StatelessWidget {
  final List<NewsItem> articles;
  const _Template6({required this.articles});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HeroArticleCell(article: articles[0]),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _SubHeroArticleCell(article: articles[1])),
            const SizedBox(width: 8),
            Expanded(child: _SubHeroArticleCell(article: articles[2])),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(3, (i) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: i == 0 ? 0 : 4, right: i == 2 ? 0 : 4),
                child: _SmallArticleCell(article: articles[i + 3]),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ─── Article Cell Widgets ─────────────────────────────────────────────────────
class _HeroArticleCell extends StatelessWidget {
  final NewsItem article;
  const _HeroArticleCell({required this.article});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF1A1A2E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (article.imageUrl.isNotEmpty)
            AspectRatio(
              aspectRatio: 16 / 7,
              child: Image.network(article.imageUrl, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFDDD8CC),
                    child: const Icon(Icons.article, size: 64, color: Color(0xFF888888)),
                  )),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.category.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 9, letterSpacing: 2, color: Color(0xFF888888),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  article.headline,
                  style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w900, height: 1.2,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  article.summary,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF333333), height: 1.5),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubHeroArticleCell extends StatelessWidget {
  final NewsItem article;
  const _SubHeroArticleCell({required this.article});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: const Color(0xFF1A1A2E))),
      padding: const EdgeInsets.all(10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(article.category.toUpperCase(),
            style: const TextStyle(fontSize: 8, letterSpacing: 2, color: Color(0xFF888888), fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(article.headline,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, height: 1.3, color: Color(0xFF1A1A2E)),
            maxLines: 3, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 6),
        Text(article.summary,
            style: const TextStyle(fontSize: 11, color: Color(0xFF444444), height: 1.4),
            maxLines: 2, overflow: TextOverflow.ellipsis),
      ]),
    );
  }
}

class _SmallArticleCell extends StatelessWidget {
  final NewsItem article;
  const _SmallArticleCell({required this.article});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: const Color(0xFF1A1A2E))),
      padding: const EdgeInsets.all(8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(article.category.toUpperCase(),
            style: const TextStyle(fontSize: 7, letterSpacing: 2, color: Color(0xFF888888), fontWeight: FontWeight.w700)),
        const SizedBox(height: 3),
        Text(article.headline,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, height: 1.25, color: Color(0xFF1A1A2E)),
            maxLines: 3, overflow: TextOverflow.ellipsis),
      ]),
    );
  }
}
