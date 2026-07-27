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
            child: LayoutBuilder(
              builder: (context, constraints) {
                return _buildLayout(context, articles, constraints);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayout(
      BuildContext context, List<NewsItem> articles, BoxConstraints constraints) {
    final count = articles.length;
    if (count <= 0) {
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

    final double availableH = constraints.maxHeight;
    final double scale = (availableH / 600).clamp(0.6, 2.0);

    if (count == 1) return _Template1(articles: articles, scale: scale);
    if (count == 2) return _Template2(articles: articles, scale: scale);
    if (count == 3) return _Template3(articles: articles, scale: scale);
    if (count == 4) return _Template4(articles: articles, scale: scale);
    if (count == 5) return _Template5(articles: articles, scale: scale);
    return _Template6(
      articles: articles.sublist(0, count.clamp(0, 6)),
      scale: scale,
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
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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
// TEMPLATES (with column dividers & horizontal rules)
// ═══════════════════════════════════════════════════════════════════════════════

// ── Template 1: 1 article ───────────────────────────────────────────────────
class _Template1 extends StatelessWidget {
  final List<NewsItem> articles;
  final double scale;
  const _Template1({required this.articles, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all((12 * scale).clamp(6.0, 20.0)),
      child: _HeroArticleCell(article: articles[0], scale: scale),
    );
  }
}

// ── Template 2: 2 articles ──────────────────────────────────────────────────
class _Template2 extends StatelessWidget {
  final List<NewsItem> articles;
  final double scale;
  const _Template2({required this.articles, required this.scale});

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
              child: _HeroArticleCell(article: articles[0], scale: scale)),
          _HorizontalRule(height: gap),
          Expanded(
              flex: 4,
              child: _SubHeroArticleCell(article: articles[1], scale: scale)),
        ],
      ),
    );
  }
}

// ── Template 3: 3 articles (1 hero + 2 small stacked vertically) ──────────
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
          Expanded(
              flex: 5,
              child: _HeroArticleCell(article: articles[0], scale: scale)),
          _HorizontalRule(height: gap),
          Expanded(
              flex: 2,
              child:
                  _SmallArticleCell(article: articles[1], scale: scale)),
          _HorizontalRule(height: gap),
          Expanded(
              flex: 2,
              child:
                  _SmallArticleCell(article: articles[2], scale: scale)),
        ],
      ),
    );
  }
}

// ── Template 4: 4 articles (1 hero + 1 sub-hero + 2 small stacked) ────────
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
          Expanded(
              flex: 4,
              child: _HeroArticleCell(article: articles[0], scale: scale)),
          _HorizontalRule(height: gap),
          Expanded(
              flex: 2,
              child:
                  _SubHeroArticleCell(article: articles[1], scale: scale)),
          _HorizontalRule(height: gap),
          Expanded(
              flex: 2,
              child:
                  _SmallArticleCell(article: articles[2], scale: scale)),
          _HorizontalRule(height: gap),
          Expanded(
              flex: 2,
              child:
                  _SmallArticleCell(article: articles[3], scale: scale)),
        ],
      ),
    );
  }
}

// ── Template 5: 5 articles (all stacked vertically) ─────────────────────────
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
              flex: 4,
              child: _HeroArticleCell(article: articles[0], scale: scale)),
          _HorizontalRule(height: gap),
          Expanded(
              flex: 2,
              child:
                  _SmallArticleCell(article: articles[1], scale: scale)),
          _HorizontalRule(height: gap),
          Expanded(
              flex: 2,
              child:
                  _SmallArticleCell(article: articles[2], scale: scale)),
          _HorizontalRule(height: gap),
          Expanded(
              flex: 2,
              child:
                  _SmallArticleCell(article: articles[3], scale: scale)),
          _HorizontalRule(height: gap),
          Expanded(
              flex: 2,
              child:
                  _SmallArticleCell(article: articles[4], scale: scale)),
        ],
      ),
    );
  }
}

// ── Template 6: 6 articles (all stacked vertically) ─────────────────────────
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
          Expanded(
              flex: 3,
              child: _HeroArticleCell(article: articles[0], scale: scale)),
          _HorizontalRule(height: gap),
          Expanded(
              flex: 2,
              child:
                  _SubHeroArticleCell(article: articles[1], scale: scale)),
          _HorizontalRule(height: gap),
          Expanded(
              flex: 2,
              child:
                  _SubHeroArticleCell(article: articles[2], scale: scale)),
          _HorizontalRule(height: gap),
          Expanded(
              flex: 2,
              child:
                  _SmallArticleCell(article: articles[3], scale: scale)),
          _HorizontalRule(height: gap),
          Expanded(
              flex: 2,
              child:
                  _SmallArticleCell(article: articles[4], scale: scale)),
          _HorizontalRule(height: gap),
          Expanded(
              flex: 2,
              child:
                  _SmallArticleCell(article: articles[5], scale: scale)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ARTICLE CELL WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

// ── Hero Article ────────────────────────────────────────────────────────────
class _HeroArticleCell extends StatelessWidget {
  final NewsItem article;
  final double scale;
  const _HeroArticleCell({required this.article, required this.scale});

  @override
  Widget build(BuildContext context) {
    final hasImage = article.imageUrl.isNotEmpty;
    final catColor = _categoryColor(article.category);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _inkColor, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage ? _buildWithImage(catColor) : _buildTextOnly(catColor),
    );
  }

  /// Hero layout with image: gradient overlay + headline on image, drop cap below
  Widget _buildWithImage(Color catColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image section with overlay — takes most of the space
        Expanded(
          flex: 6,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
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
                bottom: (12 * scale).clamp(8.0, 20.0),
                left: (12 * scale).clamp(8.0, 20.0),
                right: (12 * scale).clamp(8.0, 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Category badge
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
                          fontSize: (8 * scale).clamp(7.0, 12.0),
                          letterSpacing: 2,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(height: (6 * scale).clamp(4.0, 10.0)),
                    // Headline
                    Text(
                      article.headline,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: (22 * scale).clamp(14.0, 34.0),
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
        // Summary with drop cap — compact below
        Padding(
          padding: EdgeInsets.all((10 * scale).clamp(6.0, 16.0)),
          child: _DropCapText(text: article.summary, scale: scale),
        ),
      ],
    );
  }

  /// Hero layout without image: large text-only
  Widget _buildTextOnly(Color catColor) {
    return Padding(
      padding: EdgeInsets.all((14 * scale).clamp(8.0, 22.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category with underline accent
          Row(
            children: [
              Container(
                width: (20 * scale).clamp(12.0, 32.0),
                height: 3,
                color: catColor,
              ),
              SizedBox(width: (6 * scale).clamp(4.0, 10.0)),
              Text(
                article.category.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: (9 * scale).clamp(7.0, 14.0),
                  letterSpacing: 2,
                  color: catColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: (8 * scale).clamp(4.0, 12.0)),
          // Large headline — natural height, no Expanded
          Text(
            article.headline,
            style: GoogleFonts.playfairDisplay(
              fontSize: (28 * scale).clamp(18.0, 42.0),
              fontWeight: FontWeight.w900,
              height: 1.15,
              color: _inkColor,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
          ),
          SizedBox(height: (8 * scale).clamp(4.0, 12.0)),
          // Summary with drop cap — fills remaining space
          Expanded(
            child: _DropCapText(text: article.summary, scale: scale),
          ),
        ],
      ),
    );
  }
}

// ── Sub-Hero Article ────────────────────────────────────────────────────────
class _SubHeroArticleCell extends StatelessWidget {
  final NewsItem article;
  final double scale;
  const _SubHeroArticleCell({required this.article, required this.scale});

  @override
  Widget build(BuildContext context) {
    final catColor = _categoryColor(article.category);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: catColor, width: 3),
          left: BorderSide(color: _subtleBorder, width: 0.5),
          right: BorderSide(color: _subtleBorder, width: 0.5),
          bottom: BorderSide(color: _subtleBorder, width: 0.5),
        ),
      ),
      padding: EdgeInsets.all((10 * scale).clamp(6.0, 16.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Category label
          Text(
            article.category.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: (8 * scale).clamp(6.0, 12.0),
              letterSpacing: 2,
              color: catColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: (5 * scale).clamp(3.0, 8.0)),
          // Headline in serif
          Expanded(
            flex: 3,
            child: Text(
              article.headline,
              style: GoogleFonts.playfairDisplay(
                fontSize: (16 * scale).clamp(10.0, 24.0),
                fontWeight: FontWeight.w800,
                height: 1.25,
                color: _inkColor,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: (4 * scale).clamp(2.0, 8.0)),
          // Summary in italic serif
          Expanded(
            flex: 3,
            child: Text(
              article.summary,
              style: GoogleFonts.lora(
                fontSize: (11 * scale).clamp(8.0, 16.0),
                color: const Color(0xFF444444),
                height: 1.4,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Small Article ───────────────────────────────────────────────────────────
class _SmallArticleCell extends StatelessWidget {
  final NewsItem article;
  final double scale;
  const _SmallArticleCell({required this.article, required this.scale});

  @override
  Widget build(BuildContext context) {
    final catColor = _categoryColor(article.category);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: catColor, width: 2.5),
          left: BorderSide(color: _subtleBorder, width: 0.5),
          right: BorderSide(color: _subtleBorder, width: 0.5),
          bottom: BorderSide(color: _subtleBorder, width: 0.5),
        ),
      ),
      padding: EdgeInsets.all((8 * scale).clamp(5.0, 14.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category label
          Text(
            article.category.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: (7 * scale).clamp(6.0, 11.0),
              letterSpacing: 2,
              color: catColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: (3 * scale).clamp(2.0, 5.0)),
          // Headline in serif
          Text(
            article.headline,
            style: GoogleFonts.playfairDisplay(
              fontSize: (13 * scale).clamp(9.0, 20.0),
              fontWeight: FontWeight.w800,
              height: 1.2,
              color: _inkColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: (3 * scale).clamp(2.0, 5.0)),
          // Summary / description
          Expanded(
            child: Text(
              article.summary,
              style: GoogleFonts.lora(
                fontSize: (10 * scale).clamp(7.0, 14.0),
                color: const Color(0xFF555555),
                height: 1.35,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
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
  final double scale;
  const _DropCapText({required this.text, required this.scale});

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
            fontSize: (38 * scale).clamp(24.0, 52.0),
            fontWeight: FontWeight.w900,
            height: 0.85,
            color: _inkColor,
          ),
        ),
        SizedBox(width: (4 * scale).clamp(2.0, 8.0)),
        // Remaining text
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: (2 * scale).clamp(1.0, 4.0)),
            child: Text(
              rest,
              style: GoogleFonts.lora(
                fontSize: (12 * scale).clamp(9.0, 16.0),
                color: _bodyText,
                height: 1.5,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
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
  final double height;
  const _HorizontalRule({required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
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
