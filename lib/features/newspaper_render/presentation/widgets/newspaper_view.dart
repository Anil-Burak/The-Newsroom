import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../gatekeeping/domain/news_item.dart';

// ─── Category Color Helper ───────────────────────────────────────────────────
/// Returns a muted, print-appropriate accent color for each news category.
Color _categoryColor(String category) {
  switch (category.toLowerCase()) {
    case 'siyaset':
      return const Color(0xFF1A3C5E);
    case 'suç':
      return const Color(0xFF8B1A1A);
    case 'magazin':
      return const Color(0xFF6B2D5B);
    case 'ekonomi':
      return const Color(0xFF2D5F2D);
    case 'bilim':
      return const Color(0xFF4B2D7F);
    case 'spor':
      return const Color(0xFFBF5B17);
    case 'asayiş':
      return const Color(0xFF37474F);
    case 'teknoloji':
      return const Color(0xFF00695C);
    case 'dünya':
      return const Color(0xFF4E342E);
    default:
      return const Color(0xFF424242);
  }
}

// ─── Constants ───────────────────────────────────────────────────────────────
const _inkColor = Color(0xFF1A1A2E);
const _paperColor = Color(0xFFF5F0E8);
const _subtleBorder = Color(0xFFD5D0C4);
const _mutedText = Color(0xFF888888);
const _bodyText = Color(0xFF333333);

// ─── Fixed sizes for the scrollable layout ───────────────────────────────────
/// Hero (manşet) image height
const double _heroImageHeight = 220.0;
/// Fixed height for each non-headline article cell
const double _articleCellHeight = 130.0;

// ═══════════════════════════════════════════════════════════════════════════════
// MAIN NEWSPAPER VIEW
// ═══════════════════════════════════════════════════════════════════════════════
class NewspaperView extends StatelessWidget {
  final String personaName;
  final List<NewsItem> articles;
  final VoidCallback? onFullscreenTap;
  final VoidCallback? onCloseTap;
  final bool isPlayer;

  const NewspaperView({
    super.key,
    required this.personaName,
    required this.articles,
    this.onFullscreenTap,
    this.onCloseTap,
    this.isPlayer = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _paperColor,
      child: Column(
        children: [
          NewspaperMasthead(
            personaName: personaName,
            onFullscreenTap: onFullscreenTap,
            onCloseTap: onCloseTap,
            isPlayer: isPlayer,
          ),
          Expanded(
            child: _buildScrollableLayout(context),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableLayout(BuildContext context) {
    if (articles.isEmpty) {
      return Center(
        child: Text(
          'Bu editör için seçilen haber bulunmamaktadır.',
          style: GoogleFonts.lora(
            fontSize: 16,
            color: const Color(0xFF555555),
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Manşet (Hero — first article, with image) ──
          _HeroArticleCell(article: articles[0]),
          // ── Remaining articles (fixed height, no image) ──
          for (int i = 1; i < articles.length; i++) ...[
            const _HorizontalRule(),
            _FixedArticleCell(article: articles[i]),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ENHANCED MASTHEAD
// ═══════════════════════════════════════════════════════════════════════════════
class NewspaperMasthead extends StatelessWidget {
  final String personaName;
  final VoidCallback? onFullscreenTap;
  final VoidCallback? onCloseTap;
  final bool isPlayer;

  const NewspaperMasthead({
    super.key,
    required this.personaName,
    this.onFullscreenTap,
    this.onCloseTap,
    this.isPlayer = false,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Stable issue number: day of the year
    final issueNumber = now.difference(DateTime(now.year, 1, 1)).inDays + 1;

    return Container(
      color: _paperColor,
      child: Column(
        children: [
          // ── Top double rule ──
          Container(height: 3, color: _inkColor),
          const SizedBox(height: 2),
          Container(height: 1, color: _inkColor),

          const SizedBox(height: 6),

          // ── Date & Volume info row ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${_weekday(now.weekday)}, ${now.day} ${_month(now.month)} ${now.year}',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    color: _mutedText,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Text(
                  'Fiyatı: ₺2',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    color: _mutedText,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Text(
                  'Cilt CCXLII  •  Sayı $issueNumber',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    color: _mutedText,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // ── Thin rule ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(height: 0.5, color: _subtleBorder),
          ),

          const SizedBox(height: 6),

          // ── Newspaper Title ──
          Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '✦  ',
                            style: TextStyle(color: _inkColor, fontSize: 10),
                          ),
                          Text(
                            isPlayer
                                ? 'SENİN GAZETEN'
                                : '${personaName.toUpperCase()} GAZETESİ',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: _inkColor,
                              letterSpacing: 3,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            '  ✦',
                            style: TextStyle(color: _inkColor, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Motto
                    Text(
                      '« Haber Sizin Elinizde »',
                      style: GoogleFonts.lora(
                        fontSize: 9,
                        color: const Color(0xFF999999),
                        fontStyle: FontStyle.italic,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Fullscreen / close buttons
              if (onFullscreenTap != null || onCloseTap != null)
                Positioned(
                  right: 4,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onFullscreenTap != null)
                        IconButton(
                          icon: const Icon(Icons.open_in_full_rounded,
                              color: _inkColor, size: 18),
                          onPressed: onFullscreenTap,
                          tooltip: 'Tam Ekran Oku',
                          visualDensity: VisualDensity.compact,
                        ),
                      if (onCloseTap != null)
                        IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: _inkColor, size: 22),
                          onPressed: onCloseTap,
                          tooltip: 'Kapat',
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 6),

          // ── Bottom double rule ──
          Container(height: 1, color: _inkColor),
          const SizedBox(height: 2),
          Container(height: 3, color: _inkColor),
        ],
      ),
    );
  }

  String _weekday(int d) => [
        '',
        'Pazartesi',
        'Salı',
        'Çarşamba',
        'Perşembe',
        'Cuma',
        'Cumartesi',
        'Pazar'
      ][d];
  String _month(int m) => [
        '',
        'Ocak',
        'Şubat',
        'Mart',
        'Nisan',
        'Mayıs',
        'Haziran',
        'Temmuz',
        'Ağustos',
        'Eylül',
        'Ekim',
        'Kasım',
        'Aralık'
      ][m];
}

// ═══════════════════════════════════════════════════════════════════════════════
// ARTICLE CELL WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

// ── Hero Article (Manşet — first article, with image) ───────────────────────
class _HeroArticleCell extends StatelessWidget {
  final NewsItem article;
  const _HeroArticleCell({required this.article});

  @override
  Widget build(BuildContext context) {
    final hasImage = article.imageUrl.isNotEmpty;
    final catColor = _categoryColor(article.category);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _inkColor, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image section (only for hero) ──
          if (hasImage)
            SizedBox(
              height: _heroImageHeight,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _ArticleImage(imageUrl: article.imageUrl),
                  // Gradient overlay
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color(0x180D0D0D),
                          Color(0xBB0D0D0D),
                        ],
                        stops: [0.25, 0.55, 1.0],
                      ),
                    ),
                  ),
                  // Category + Headline on image
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: catColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            article.category.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              letterSpacing: 2,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          article.headline,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                            color: Colors.white,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          // ── Text-only header when no image ──
          if (!hasImage)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(width: 18, height: 3, color: catColor),
                      const SizedBox(width: 6),
                      Text(
                        article.category.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          letterSpacing: 2,
                          color: catColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    article.headline,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                      color: _inkColor,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          // ── Summary with drop cap ──
          Padding(
            padding: const EdgeInsets.all(12),
            child: _DropCapText(text: article.summary),
          ),
        ],
      ),
    );
  }
}

// ── Fixed-Height Article Cell (non-headline articles, no image) ──────────────
class _FixedArticleCell extends StatelessWidget {
  final NewsItem article;
  const _FixedArticleCell({required this.article});

  @override
  Widget build(BuildContext context) {
    final catColor = _categoryColor(article.category);

    return Container(
      height: _articleCellHeight,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: catColor, width: 2.5),
          left: BorderSide(color: _subtleBorder, width: 0.5),
          right: BorderSide(color: _subtleBorder, width: 0.5),
          bottom: BorderSide(color: _subtleBorder, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category label
          Text(
            article.category.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 8,
              letterSpacing: 2,
              color: catColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          // Headline
          Text(
            article.headline,
            style: GoogleFonts.playfairDisplay(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              height: 1.2,
              color: _inkColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Summary — fills remaining space
          Expanded(
            child: Text(
              article.summary,
              style: GoogleFonts.lora(
                fontSize: 13,
                color: const Color(0xFF555555),
                height: 1.35,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 4,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// HELPER WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

// ── Drop Cap Text ───────────────────────────────────────────────────────────
/// Renders the first character large (newspaper drop-cap style) with the
/// remaining text flowing beside it.
class _DropCapText extends StatelessWidget {
  final String text;
  const _DropCapText({required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    final firstChar = text[0].toUpperCase();
    final rest = text.substring(1);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Drop cap character
        Text(
          firstChar,
          style: GoogleFonts.playfairDisplay(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            height: 0.85,
            color: _inkColor,
          ),
        ),
        const SizedBox(width: 4),
        // Remaining text
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              rest,
              style: GoogleFonts.lora(
                fontSize: 12,
                color: _bodyText,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Horizontal Rule ─────────────────────────────────────────────────────────
/// Decorative horizontal divider between article rows, styled as a thin rule
/// with a centered ornament.
class _HorizontalRule extends StatelessWidget {
  const _HorizontalRule();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(height: 0.5, color: _subtleBorder),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '❖',
              style: TextStyle(
                color: _subtleBorder,
                fontSize: 7,
              ),
            ),
          ),
          Expanded(
            child: Container(height: 0.5, color: _subtleBorder),
          ),
        ],
      ),
    );
  }
}

// ── Article Image ───────────────────────────────────────────────────────────
/// Handles loading network or asset images with graceful fallbacks.
class _ArticleImage extends StatelessWidget {
  final String imageUrl;
  const _ArticleImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (_, _) => Container(
          color: const Color(0xFFDDD8CC),
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _mutedText,
              ),
            ),
          ),
        ),
        errorWidget: (_, _, _) => _imageFallback(),
      );
    }
    return Image.asset(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _imageFallback(),
    );
  }

  Widget _imageFallback() {
    return Container(
      color: const Color(0xFFDDD8CC),
      child: const Center(
        child: Icon(Icons.article_rounded, size: 48, color: _mutedText),
      ),
    );
  }
}
