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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        final bool? shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.inkSurface,
            title: const Text('Ana Sayfaya Dön', style: TextStyle(color: AppColors.textPrimary)),
            content: const Text('Ana sayfaya dönmek ister misiniz? İlerlemeniz kaybolacak.', style: TextStyle(color: AppColors.textSecondary)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('İptal', style: TextStyle(color: AppColors.textMuted)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Evet', style: TextStyle(color: AppColors.publishGreen)),
              ),
            ],
          ),
        );
        
        if (shouldPop == true && context.mounted) {
          ref.read(gatekeeperProvider.notifier).reset();
          context.go(AppConstants.routePersonaSelection);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F0E8), // aged newsprint
      // ── CTA pinned at bottom – always visible, no dead space below it ──
      bottomNavigationBar: Container(
        color: const Color(0xFFF5F0E8),
        padding: EdgeInsets.fromLTRB(
          20,
          10,
          20,
          MediaQuery.of(context).padding.bottom + 16,
        ),
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
              Text('KARŞILAŞTIRMAYI GÖR'),
              SizedBox(width: 8),
              Icon(Icons.compare_rounded),
            ],
          ),
        ),
      ),
      body: SafeArea(
        bottom: false, // bottom handled by bottomNavigationBar padding
        child: Column(
          children: [
            // Masthead – fixed at top
            _NewspaperMasthead(personaName: persona?.name ?? 'The Daily'),
            // Articles – fill remaining space, no scroll, fonts scale to fit
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return _buildLayout(context, accepted, constraints);
                },
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildLayout(
      BuildContext context, List<NewsItem> articles, BoxConstraints constraints) {
    final count = articles.length;
    if (count <= 0) return const SizedBox.shrink();

    // Base heights are tuned for ~600px available. Scale fonts proportionally.
    final double availableH = constraints.maxHeight;
    final double scale = (availableH / 600).clamp(0.6, 2.0);

    if (count == 3) return _Template3(articles: articles, scale: scale);
    if (count == 4) return _Template4(articles: articles, scale: scale);
    if (count == 5) return _Template5(articles: articles, scale: scale);
    return _Template6(articles: articles, scale: scale);
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
          const SizedBox(height: 3),
          Container(height: 1, color: const Color(0xFF1A1A2E)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Column(
              children: [
                Text(
                  '${personaName.toUpperCase()} GAZETESİ',
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1A2E),
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  '${_weekday(now.weekday)}, ${now.day} ${_month(now.month)} ${now.year}  •  Cilt CCXLII, Sayı ${now.millisecondsSinceEpoch % 999 + 1}',
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
      ['', 'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'][d];
  String _month(int m) =>
      ['', 'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'][m];
}

// ── Template A: 3 articles (1 hero + 2 side) ─────────────────────────────────
class _Template3 extends StatelessWidget {
  final List<NewsItem> articles;
  final double scale;
  const _Template3({required this.articles, required this.scale});

  @override
  Widget build(BuildContext context) {
    final gap = (8 * scale).clamp(4.0, 16.0);
    return Padding(
      padding: EdgeInsets.all((12 * scale).clamp(6.0, 20.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 5, child: _HeroArticleCell(article: articles[0], scale: scale)),
          SizedBox(height: gap),
          Expanded(
            flex: 3,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _SmallArticleCell(article: articles[1], scale: scale)),
                SizedBox(width: gap),
                Expanded(child: _SmallArticleCell(article: articles[2], scale: scale)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Template B: 4 articles (1 hero + 1 sub-hero + 2 small) ───────────────────
class _Template4 extends StatelessWidget {
  final List<NewsItem> articles;
  final double scale;
  const _Template4({required this.articles, required this.scale});

  @override
  Widget build(BuildContext context) {
    final gap = (8 * scale).clamp(4.0, 16.0);
    return Padding(
      padding: EdgeInsets.all((12 * scale).clamp(6.0, 20.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 4, child: _HeroArticleCell(article: articles[0], scale: scale)),
          SizedBox(height: gap),
          Expanded(flex: 3, child: _SubHeroArticleCell(article: articles[1], scale: scale)),
          SizedBox(height: gap),
          Expanded(
            flex: 3,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _SmallArticleCell(article: articles[2], scale: scale)),
                SizedBox(width: gap),
                Expanded(child: _SmallArticleCell(article: articles[3], scale: scale)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Template C: 5 articles ────────────────────────────────────────────────────
class _Template5 extends StatelessWidget {
  final List<NewsItem> articles;
  final double scale;
  const _Template5({required this.articles, required this.scale});

  @override
  Widget build(BuildContext context) {
    final gap = (8 * scale).clamp(4.0, 16.0);
    return Padding(
      padding: EdgeInsets.all((12 * scale).clamp(6.0, 20.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 3, child: _HeroArticleCell(article: articles[0], scale: scale)),
                SizedBox(width: gap),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _SmallArticleCell(article: articles[1], scale: scale)),
                      SizedBox(height: gap),
                      Expanded(child: _SmallArticleCell(article: articles[2], scale: scale)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: gap),
          Expanded(
            flex: 3,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _SmallArticleCell(article: articles[3], scale: scale)),
                SizedBox(width: gap),
                Expanded(child: _SmallArticleCell(article: articles[4], scale: scale)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Template D: 6 articles ────────────────────────────────────────────────────
class _Template6 extends StatelessWidget {
  final List<NewsItem> articles;
  final double scale;
  const _Template6({required this.articles, required this.scale});

  @override
  Widget build(BuildContext context) {
    final gap = (8 * scale).clamp(4.0, 16.0);
    return Padding(
      padding: EdgeInsets.all((12 * scale).clamp(6.0, 20.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 4, child: _HeroArticleCell(article: articles[0], scale: scale)),
          SizedBox(height: gap),
          Expanded(
            flex: 3,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _SubHeroArticleCell(article: articles[1], scale: scale)),
                SizedBox(width: gap),
                Expanded(child: _SubHeroArticleCell(article: articles[2], scale: scale)),
              ],
            ),
          ),
          SizedBox(height: gap),
          Expanded(
            flex: 3,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(3, (i) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: i == 0 ? 0 : gap / 2, right: i == 2 ? 0 : gap / 2),
                    child: _SmallArticleCell(article: articles[i + 3], scale: scale),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Article Cell Widgets ─────────────────────────────────────────────────────
class _HeroArticleCell extends StatelessWidget {
  final NewsItem article;
  final double scale;
  const _HeroArticleCell({required this.article, required this.scale});

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
            Flexible(
              flex: 3,
              child: SizedBox(
                width: double.infinity,
                child: Image.network(article.imageUrl, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFDDD8CC),
                      child: const Icon(Icons.article, size: 64, color: Color(0xFF888888)),
                    )),
              ),
            ),
          Flexible(
            flex: 4,
            child: Padding(
              padding: EdgeInsets.all((12 * scale).clamp(6.0, 18.0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    article.category.toUpperCase(),
                    style: TextStyle(
                      fontSize: (9 * scale).clamp(7.0, 14.0),
                      letterSpacing: 2,
                      color: const Color(0xFF888888),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: (4 * scale).clamp(2.0, 8.0)),
                  Text(
                    article.headline,
                    style: TextStyle(
                      fontSize: (24 * scale).clamp(14.0, 36.0),
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                      color: const Color(0xFF1A1A2E),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                  SizedBox(height: (8 * scale).clamp(4.0, 12.0)),
                  Flexible(
                    child: Text(
                      article.summary,
                      style: TextStyle(
                        fontSize: (13 * scale).clamp(9.0, 18.0),
                        color: const Color(0xFF333333),
                        height: 1.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubHeroArticleCell extends StatelessWidget {
  final NewsItem article;
  final double scale;
  const _SubHeroArticleCell({required this.article, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: const Color(0xFF1A1A2E))),
      padding: EdgeInsets.all((10 * scale).clamp(6.0, 16.0)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text(article.category.toUpperCase(),
            style: TextStyle(
              fontSize: (8 * scale).clamp(6.0, 12.0),
              letterSpacing: 2,
              color: const Color(0xFF888888),
              fontWeight: FontWeight.w700,
            )),
        SizedBox(height: (4 * scale).clamp(2.0, 8.0)),
        Text(article.headline,
            style: TextStyle(
              fontSize: (16 * scale).clamp(10.0, 24.0),
              fontWeight: FontWeight.w800,
              height: 1.3,
              color: const Color(0xFF1A1A2E),
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis),
        SizedBox(height: (6 * scale).clamp(3.0, 10.0)),
        Text(article.summary,
            style: TextStyle(
              fontSize: (11 * scale).clamp(8.0, 16.0),
              color: const Color(0xFF444444),
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis),
      ]),
    );
  }
}

class _SmallArticleCell extends StatelessWidget {
  final NewsItem article;
  final double scale;
  const _SmallArticleCell({required this.article, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: const Color(0xFF1A1A2E))),
      padding: EdgeInsets.all((8 * scale).clamp(5.0, 14.0)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text(article.category.toUpperCase(),
            style: TextStyle(
              fontSize: (7 * scale).clamp(6.0, 11.0),
              letterSpacing: 2,
              color: const Color(0xFF888888),
              fontWeight: FontWeight.w700,
            )),
        SizedBox(height: (3 * scale).clamp(2.0, 6.0)),
        Text(article.headline,
            style: TextStyle(
              fontSize: (12 * scale).clamp(9.0, 18.0),
              fontWeight: FontWeight.w800,
              height: 1.25,
              color: const Color(0xFF1A1A2E),
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis),
      ]),
    );
  }
}
