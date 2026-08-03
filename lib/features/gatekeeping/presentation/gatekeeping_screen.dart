import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/extensions/string_extensions.dart';
import '../../../core/constants/app_constants.dart';
import '../application/gatekeeper_notifier.dart';

import '../../persona_selection/application/persona_selection_notifier.dart';
import '../../comparison_matrix/data/ai_newspaper_service.dart';
import 'widgets/news_swipe_card.dart';
import 'widgets/capacity_bar.dart';

class GatekeepingScreen extends ConsumerStatefulWidget {
  const GatekeepingScreen({super.key});

  @override
  ConsumerState<GatekeepingScreen> createState() => _GatekeepingScreenState();
}

class _GatekeepingScreenState extends ConsumerState<GatekeepingScreen> {
  final AppinioSwiperController _swiperController = AppinioSwiperController();
  bool _aiTriggered = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(gatekeeperProvider.notifier).loadNewsPool());
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  void _triggerAiBackground() {
    if (_aiTriggered) return;
    _aiTriggered = true;
    ref.read(gatekeeperProvider.notifier).markAiTriggered();

    final persona = ref.read(activePersonaProvider);
    if (persona == null) return;

    // Fire-and-forget background call to OpenAI
    final newsPool = ref.read(gatekeeperProvider).upcomingCards +
        ref.read(gatekeeperProvider).acceptedCards +
        ref.read(gatekeeperProvider).rejectedCards;

    final selectedPersonas = ref.read(personaSelectionProvider).selectedPersonas;

    ref.read(aiNewspaperServiceProvider.notifier).generateAINewspapers(
          allNewsItems: newsPool,
          personas: selectedPersonas,
        );
  }

  void _onSwipe(int index, SwiperActivity activity) {
    final state = ref.read(gatekeeperProvider);
    if (state.deckIsEmpty) return;
    final card = state.upcomingCards[state.currentIndex];

    if (activity is Swipe) {
      if (activity.direction == AxisDirection.right) {
        // Publish
        final accepted = ref.read(gatekeeperProvider.notifier).acceptCard(card);
        if (!accepted) {
          _showCapacityFullModal();
          return;
        }
      } else if (activity.direction == AxisDirection.left) {
        // Reject
        ref.read(gatekeeperProvider.notifier).rejectCard(card);
      }

      // Trigger AI after first swipe (with delay)
      if (!_aiTriggered) {
        Future.delayed(
          const Duration(milliseconds: AppConstants.aiTriggerDelayMs),
          _triggerAiBackground,
        );
      }
    }

    // Check post-swipe state
    final newState = ref.read(gatekeeperProvider);
    if (newState.status == SwipePhaseStatus.fullCapacity) {
      Future.delayed(const Duration(milliseconds: 400), _showCapacityFullModal);
    } else if ((newState.status == SwipePhaseStatus.finished || newState.deckIsEmpty) &&
        newState.isAtMinimum) {
      Future.delayed(
          const Duration(milliseconds: 300),
          () => context.go(AppConstants.routeNewspaper));
    } else if ((newState.status == SwipePhaseStatus.finished || newState.deckIsEmpty) &&
        !newState.isAtMinimum) {
      Future.delayed(
          const Duration(milliseconds: 300), _showNeedMoreArticlesModal);
    }
  }

  void _showCapacityFullModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _GatekeeperModal(
        icon: Icons.newspaper_rounded,
        iconColor: AppColors.gold,
        title: 'Ön Sayfa Dolu!',
        subtitle:
            '${AppConstants.maxPublishedArticles} haber seçtiniz. Gazeteniz baskıya hazır.',
        actionLabel: 'BASKIYA GÖNDER',
        onAction: () {
          Navigator.pop(context);
          ref.read(gatekeeperProvider.notifier).confirmSelection();
          context.go(AppConstants.routeNewspaper);
        },
      ),
    );
  }

  void _showNeedMoreArticlesModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _GatekeeperModal(
        icon: Icons.warning_amber_rounded,
        iconColor: AppColors.rejectRed,
        title: 'Yeterli Haber Yok!',
        subtitle:
            'Yayınlamak için en az ${AppConstants.minPublishedArticles} habere ihtiyacınız var. Reddedilenleri kurtarın.',
        actionLabel: 'REDDEDİLENLERİ GÖRÜŞÜN',
        onAction: () {
          Navigator.pop(context);
          _showRejectedPile();
        },
      ),
    );
  }

  void _showRejectedPile() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.inkSurface,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _RejectedPileSheet(),
    );
  }

  Future<bool> _showExitConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _GatekeeperModal(
        icon: Icons.exit_to_app_rounded,
        iconColor: AppColors.gold,
        title: 'Çıkış Yap',
        subtitle: 'Haber kaydırma işlemini iptal edip ana ekrana dönmek istediğinize emin misiniz?',
        actionLabel: 'EVET, ÇIK',
        onAction: () => Navigator.pop(context, true),
        secondaryActionLabel: 'HAYIR, DEVAM ET',
        onSecondaryAction: () => Navigator.pop(context, false),
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gatekeeperProvider);
    final persona = ref.watch(activePersonaProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await _showExitConfirmationDialog();
        if (shouldExit && context.mounted) {
          context.go(AppConstants.routePersonaSelection);
        }
      },
      child: Scaffold(
      body: Container(
        color: AppColors.inkDeep,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          persona?.name ?? 'Editör',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textMuted, letterSpacing: 1.5),
                        ),
                        Text('Haber Geçidi',
                            style: Theme.of(context).textTheme.headlineSmall),
                      ],
                    ),
                    const Spacer(),
                      // Cards remaining counter
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${state.upcomingCards.length - state.currentIndex} kaldı',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Capacity Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CapacityBar(
                  current: state.acceptedCount,
                  max: AppConstants.maxPublishedArticles,
                  min: AppConstants.minPublishedArticles,
                ),
              ),
              const SizedBox(height: 8),

              // Swipe Card Stack
              Expanded(
                child: state.status == SwipePhaseStatus.loading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.gold))
                    : state.deckIsEmpty
                        ? (!state.isAtMinimum && state.rejectedCards.isNotEmpty)
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 32),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.rejectRed.withValues(alpha: 0.1),
                                          border: Border.all(color: AppColors.rejectRed, width: 2),
                                        ),
                                        child: const Icon(Icons.warning_amber_rounded,
                                            color: AppColors.rejectRed, size: 40),
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        'Yeterli Haber Yok',
                                        style: Theme.of(context).textTheme.headlineSmall,
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'En az ${AppConstants.minPublishedArticles} haber gerekli. Reddedilenlerden kurtarabilirsiniz.',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),

                                    ],
                                  ),
                                ),
                              )
                            : const SizedBox.shrink()
                        : AppinioSwiper(
                            controller: _swiperController,
                            cardCount: state.upcomingCards.length,
                            initialIndex: state.currentIndex,
                            swipeOptions: const SwipeOptions.symmetric(
                              horizontal: true,
                            ),
                            onSwipeEnd: (int index, int? leavingIndex, SwiperActivity activity) => _onSwipe(index, activity),
                            cardBuilder: (context, index) {
                              if (index >= state.upcomingCards.length) {
                                return const SizedBox.shrink();
                              }
                              return NewsSwipeCard(
                                  news: state.upcomingCards[index]);
                            },
                          ),
              ),

              // Bottom action hint
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _SwipeHint(
                      icon: Icons.arrow_back_rounded,
                      label: 'REDDET',
                      color: AppColors.rejectRed,
                    ),
                    // Confirm early if eligible
                    if (state.isAtMinimum && !state.isAtCapacity)
                      ElevatedButton(
                        onPressed: () {
                          ref
                              .read(gatekeeperProvider.notifier)
                              .confirmSelection();
                          context.go(AppConstants.routeNewspaper);
                        },
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12)),
                        child: const Text('BASKIYA GÖNDER'),
                      ),
                    _SwipeHint(
                      icon: Icons.arrow_forward_rounded,
                      label: 'YAYINLA',
                      color: AppColors.publishGreen,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

class _SwipeHint extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SwipeHint(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class _GatekeeperModal extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  const _GatekeeperModal({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: AppColors.inkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconColor.withValues(alpha: 0.1),
                  border: Border.all(color: iconColor, width: 2),
                ),
                child: Icon(icon, color: iconColor, size: 36),
              ),
              const SizedBox(height: 20),
              Text(title,
                  style: Theme.of(context).textTheme.displaySmall,
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(subtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: 28),
              if (secondaryActionLabel != null && onSecondaryAction != null) ...[
                OutlinedButton(
                  onPressed: onSecondaryAction,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.glassBorder),
                  ),
                  child: Text(secondaryActionLabel!),
                ),
                const SizedBox(height: 12),
              ],
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52)),
                child: Text(actionLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RejectedPileSheet extends ConsumerStatefulWidget {
  const _RejectedPileSheet();

  @override
  ConsumerState<_RejectedPileSheet> createState() => _RejectedPileSheetState();
}

class _RejectedPileSheetState extends ConsumerState<_RejectedPileSheet> {
  final Set<String> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    final rejected = ref.watch(gatekeeperProvider).rejectedCards;
    final screenHeight = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: false,
      child: SizedBox(
        height: screenHeight * 0.75,
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Static handle bar (non-draggable, visual only)
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.glassBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Reddedilen Haberler',
                      style: Theme.of(context).textTheme.headlineSmall),
                  if (rejected.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          if (_selectedIds.length == rejected.length) {
                            _selectedIds.clear();
                          } else {
                            _selectedIds.addAll(rejected.map((e) => e.id));
                          }
                        });
                      },
                      child: Text(
                        _selectedIds.length == rejected.length
                            ? 'Tümünü Kaldır'
                            : 'Tümünü Seç',
                        style: const TextStyle(
                            color: AppColors.gold, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Tekrar değerlendirmek istediğiniz haberleri seçin ve "Tamam"a basın.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: rejected.isEmpty
                  ? const Center(
                      child: Text(
                        'Reddedilen haber bulunmuyor.',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: rejected.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final item = rejected[i];
                        final isSelected = _selectedIds.contains(item.id);
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedIds.remove(item.id);
                                } else {
                                  _selectedIds.add(item.id);
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.gold.withValues(alpha: 0.08)
                                    : AppColors.glassSurface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.gold
                                      : AppColors.glassBorder,
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: isSelected,
                                    activeColor: AppColors.gold,
                                    checkColor: Colors.white,
                                    onChanged: (val) {
                                      setState(() {
                                        if (val == true) {
                                          _selectedIds.add(item.id);
                                        } else {
                                          _selectedIds.remove(item.id);
                                        }
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.headline,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                                color: isSelected
                                                    ? AppColors.gold
                                                    : AppColors.textPrimary,
                                              ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item.category.toUpperCaseTr(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppColors.textSecondary,
                                                fontSize: 11,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: const BoxDecoration(
                color: AppColors.inkSurface,
                border: Border(top: BorderSide(color: AppColors.glassBorder)),
              ),
              child: ElevatedButton(
                onPressed: _selectedIds.isEmpty
                    ? null
                    : () {
                        final selectedItems = rejected
                            .where((item) => _selectedIds.contains(item.id))
                            .toList();
                        ref
                            .read(gatekeeperProvider.notifier)
                            .rescueMultipleRejectedCards(selectedItems);
                        Navigator.pop(context);
                      },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: AppColors.gold,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.glassSurface,
                  disabledForegroundColor: AppColors.textMuted,
                ),
                child: Text(
                  _selectedIds.isEmpty
                      ? 'TAMAM'
                      : 'TAMAM (${_selectedIds.length} HABERİ KURTAR)',
                  style:
                      const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
