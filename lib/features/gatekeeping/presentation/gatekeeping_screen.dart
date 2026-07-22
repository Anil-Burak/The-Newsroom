import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
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

    ref.read(aiNewspaperServiceProvider.notifier).generateAINewspapers(
          allNewsItems: newsPool,
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
    } else if (newState.status == SwipePhaseStatus.finished &&
        newState.isAtMinimum) {
      Future.delayed(
          const Duration(milliseconds: 300),
          () => context.go(AppConstants.routeNewspaper));
    } else if (newState.status == SwipePhaseStatus.finished &&
        !newState.isAtMinimum) {
      Future.delayed(
          const Duration(milliseconds: 300), _showNeedMoreArticlesModal);
    }
  }

  void _showCapacityFullModal() {
    showDialog(
      context: context,
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
        actionLabel: 'REDDEDILENLERI GÖRÜŞÜN',
        onAction: () {
          Navigator.pop(context);
          _showRejectedPile();
        },
      ),
    );
  }

  void _showRejectedPile() {
    final rejected = ref.read(gatekeeperProvider).rejectedCards;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.inkSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (_, scrollController) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Reddedilen Haberler',
                  style: Theme.of(context).textTheme.displaySmall),
            ),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: rejected.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final item = rejected[i];
                  return ListTile(
                    tileColor: AppColors.glassSurface,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    title: Text(item.headline,
                        style: Theme.of(context).textTheme.titleLarge,
                        maxLines: 2),
                    subtitle:
                        Text(item.category, style: Theme.of(context).textTheme.bodySmall),
                    trailing: IconButton(
                      icon: const Icon(Icons.undo_rounded, color: AppColors.gold),
                      onPressed: () {
                        ref
                            .read(gatekeeperProvider.notifier)
                            .rescueRejectedCard(item);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gatekeeperProvider);
    final persona = ref.watch(activePersonaProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.inkGradient),
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
                              ?.copyWith(color: AppColors.gold, letterSpacing: 1.5),
                        ),
                        Text('Haber Odası',
                            style: Theme.of(context).textTheme.headlineSmall),
                      ],
                    ),
                    const Spacer(),
                      // Cards remaining counter
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.glassSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Text(
                        '${state.upcomingCards.length - state.currentIndex} kaldı',
                        style: Theme.of(context).textTheme.labelLarge,
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
                        ? const SizedBox.shrink()
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

  const _GatekeeperModal({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
                color: iconColor.withOpacity(0.15),
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
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52)),
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
