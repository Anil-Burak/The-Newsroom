import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../gatekeeping/application/gatekeeper_notifier.dart';
import '../../gatekeeping/domain/news_item.dart';
import '../../persona_selection/application/persona_selection_notifier.dart';
import '../../persona_selection/domain/persona.dart';
import '../../comparison_matrix/data/ai_newspaper_service.dart';

class ComparisonScreen extends ConsumerStatefulWidget {
  const ComparisonScreen({super.key});

  @override
  ConsumerState<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends ConsumerState<ComparisonScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<Persona> _selectedPersonas = [];
  bool _initialized = false;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initTabs(List<Persona> personas) {
    _selectedPersonas = personas;
    // 1 (SEN) + selected personas count
    _tabController = TabController(length: 1 + personas.length, vsync: this);
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiNewspaperServiceProvider);
    final gatekeeperState = ref.watch(gatekeeperProvider);
    final selectedPersonas = ref.watch(personaSelectionProvider).selectedPersonas;
    final persona = ref.watch(activePersonaProvider); // User's persona

    // Initialize or rebuild tab controller if persona count changes
    if (!_initialized || _selectedPersonas.length != selectedPersonas.length) {
      if (_initialized) _tabController.dispose();
      _initTabs(selectedPersonas);
    }

    final now = DateTime.now();
    final months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    final dateString = '${now.day} ${months[now.month - 1]} ${now.year}';

    final allTabs = [
      const Tab(text: 'SEN'),
      ...selectedPersonas.map((p) => Tab(text: p.name.toUpperCase())),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.inkGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    // Back to home button
                    GestureDetector(
                      onTap: () {
                        ref.read(gatekeeperProvider.notifier).reset();
                        ref.invalidate(aiNewspaperServiceProvider);
                        context.go(AppConstants.routePersonaSelection);
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.glassSurface,
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: const Icon(Icons.home_rounded,
                            color: AppColors.gold, size: 18),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Karşılaştırma', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gold, letterSpacing: 1.5)),
                        Text('Matrisi', style: Theme.of(context).textTheme.displaySmall),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.glassSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Text(
                        dateString,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              // Tabs
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.glassSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: AppColors.inkBlack,
                  unselectedLabelColor: AppColors.textMuted,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 0.8),
                  tabs: allTabs,
                  dividerColor: Colors.transparent,
                ),
              ),
              const SizedBox(height: 8),
              // Tab views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Player's newspaper
                    _PlayerNewspaperTab(
                      accepted: gatekeeperState.acceptedCards,
                      rejected: gatekeeperState.rejectedCards,
                      personaName: persona?.name ?? 'You',
                    ),
                    // AI newspapers dynamically generated
                    ...selectedPersonas.map((p) => _AINewspaperTab(
                          personaId: p.id,
                          personaLabel: p.name,
                          aiState: aiState,
                          allNews: gatekeeperState.acceptedCards +
                              gatekeeperState.rejectedCards,
                          userAcceptedIds: gatekeeperState.acceptedCards
                              .map((n) => n.id)
                              .toSet(),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Player Tab ───────────────────────────────────────────────────────────────
class _PlayerNewspaperTab extends StatelessWidget {
  final List<NewsItem> accepted;
  final List<NewsItem> rejected;
  final String personaName;

  const _PlayerNewspaperTab({
    required this.accepted,
    required this.rejected,
    required this.personaName,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: '📰 Yayınlanan — $personaName'),
          ...accepted.map((n) => _ArticleRow(
                news: n,
                status: 'published',
                justification: 'Sizin editörlük seçiminiz.',
              )),
          const SizedBox(height: 16),
          _SectionHeader(title: '🗑️ Reddedilen'),
          ...rejected.map((n) => _ArticleRow(
                news: n,
                status: 'rejected',
                justification: 'Bu haberi yayınlamama kararı verdiniz.',
              )),
        ],
      ),
    );
  }
}

// ─── AI Tab ───────────────────────────────────────────────────────────────────
class _AINewspaperTab extends StatelessWidget {
  final String personaId;
  final String personaLabel;
  final AINewspaperState aiState;
  final List<NewsItem> allNews;
  final Set<String> userAcceptedIds;

  const _AINewspaperTab({
    required this.personaId,
    required this.personaLabel,
    required this.aiState,
    required this.allNews,
    required this.userAcceptedIds,
  });

  @override
  Widget build(BuildContext context) {
    if (aiState.status == AIGenerationStatus.loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.gold),
            SizedBox(height: 16),
            Text('Yapay zeka editörleri inceliyor...',
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    if (aiState.status == AIGenerationStatus.error) {
      return Center(
        child: Text('Yapay zeka oluşturma başarısız: ${aiState.error}',
            style: const TextStyle(color: AppColors.rejectRed)),
      );
    }

    final newspaper = aiState.newspapers[personaId];
    if (newspaper == null) {
      return const Center(
        child: Text('Yapay zeka sonuçları bekleniyor...',
            style: TextStyle(color: AppColors.textMuted)),
      );
    }

    final published = allNews
        .where((n) => newspaper.selectedNewsIds.contains(n.id))
        .toList();
    final rejected = allNews
        .where((n) => !newspaper.selectedNewsIds.contains(n.id))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: '📰 Yayınlanan — $personaLabel'),
          ...published.map((n) => _ArticleRow(
                news: n,
                status: 'published',
                justification: newspaper.justifications[n.id] ??
                    'Geçerlilik açıklaması bulunmuyor.',
                isUserAccepted: userAcceptedIds.contains(n.id),
              )),
          const SizedBox(height: 16),
          _SectionHeader(title: '🗑️ $personaLabel tarafından reddedilen'),
          ...rejected.map((n) => _ArticleRow(
                news: n,
                status: 'rejected',
                justification: newspaper.justifications[n.id] ??
                    'Geçerlilik açıklaması bulunmuyor.',
                isUserAccepted: userAcceptedIds.contains(n.id),
              )),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.gold,
                letterSpacing: 1.2,
              )),
    );
  }
}

// ─── Article Row with Tap-to-Justify ─────────────────────────────────────────
class _ArticleRow extends StatelessWidget {
  final NewsItem news;
  final String status;
  final String justification;
  final bool? isUserAccepted;

  const _ArticleRow({
    required this.news,
    required this.status,
    required this.justification,
    this.isUserAccepted,
  });

  @override
  Widget build(BuildContext context) {
    final isPublished = status == 'published';
    return GestureDetector(
      onTap: () => _showJustificationModal(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.glassSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPublished
                ? AppColors.publishGreen.withOpacity(0.4)
                : AppColors.rejectRed.withOpacity(0.3),
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPublished
                  ? AppColors.publishGreen.withOpacity(0.15)
                  : AppColors.rejectRed.withOpacity(0.15),
            ),
            child: Icon(
              isPublished ? Icons.check_rounded : Icons.close_rounded,
              color: isPublished ? AppColors.publishGreen : AppColors.rejectRed,
              size: 18,
            ),
          ),
          title: Text(news.headline,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          subtitle: Text(news.category,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11)),
          trailing: isUserAccepted == null
              ? const Icon(Icons.info_outline_rounded, color: AppColors.gold, size: 18)
              : Icon(
                  isUserAccepted! ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: isUserAccepted! ? AppColors.publishGreen : AppColors.rejectRed,
                  size: 20,
                ),
        ),
      ),
    );
  }

  void _showJustificationModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.inkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: (status == 'published'
                        ? AppColors.publishGreen
                        : AppColors.rejectRed)
                    .withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: status == 'published'
                      ? AppColors.publishGreen
                      : AppColors.rejectRed,
                ),
              ),
              child: Text(
                status == 'published' ? '✅ YAYIMLANDI' : '❌ REDDEDILDİ',
                style: TextStyle(
                  color: status == 'published'
                      ? AppColors.publishGreen
                      : AppColors.rejectRed,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(news.headline,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(news.summary,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3),
            const Divider(height: 28, color: AppColors.glassBorder),
            Text('EDİTÖRÜN YORUMU',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(letterSpacing: 1.5, color: AppColors.gold)),
            const SizedBox(height: 8),
            Text(
              '"$justification"',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.textPrimary,
                    height: 1.6,
                  ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
