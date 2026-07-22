import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/news_item.dart';
import '../data/news_repository.dart';
import '../../../core/constants/app_constants.dart';

// ─── State ───────────────────────────────────────────────────────────────────
enum SwipePhaseStatus { idle, loading, ready, fullCapacity, finished, error }

class GatekeeperState {
  final List<NewsItem> upcomingCards;
  final int currentIndex;
  final List<NewsItem> acceptedCards;
  final List<NewsItem> rejectedCards;
  final SwipePhaseStatus status;
  final String? errorMessage;
  final bool aiTriggered; // Has background AI call been fired?

  const GatekeeperState({
    this.upcomingCards = const [],
    this.currentIndex = 0,
    this.acceptedCards = const [],
    this.rejectedCards = const [],
    this.status = SwipePhaseStatus.idle,
    this.errorMessage,
    this.aiTriggered = false,
  });

  int get acceptedCount => acceptedCards.length;
  int get remainingSlots => AppConstants.maxPublishedArticles - acceptedCount;
  bool get isAtMinimum => acceptedCount >= AppConstants.minPublishedArticles;
  bool get isAtCapacity => acceptedCount >= AppConstants.maxPublishedArticles;
  bool get deckIsEmpty => currentIndex >= upcomingCards.length;
  bool get canProceed => isAtMinimum && (isAtCapacity || deckIsEmpty);

  GatekeeperState copyWith({
    List<NewsItem>? upcomingCards,
    int? currentIndex,
    List<NewsItem>? acceptedCards,
    List<NewsItem>? rejectedCards,
    SwipePhaseStatus? status,
    String? errorMessage,
    bool? aiTriggered,
  }) =>
      GatekeeperState(
        upcomingCards: upcomingCards ?? this.upcomingCards,
        currentIndex: currentIndex ?? this.currentIndex,
        acceptedCards: acceptedCards ?? this.acceptedCards,
        rejectedCards: rejectedCards ?? this.rejectedCards,
        status: status ?? this.status,
        errorMessage: errorMessage,
        aiTriggered: aiTriggered ?? this.aiTriggered,
      );
}

// ─── Notifier ────────────────────────────────────────────────────────────────
class GatekeeperNotifier extends StateNotifier<GatekeeperState> {
  final NewsRepository _newsRepository;

  GatekeeperNotifier(this._newsRepository)
      : super(const GatekeeperState(status: SwipePhaseStatus.idle));

  /// Load the news pool from Firestore and prepare the deck.
  Future<void> loadNewsPool() async {
    state = state.copyWith(status: SwipePhaseStatus.loading);
    try {
      final items = await _newsRepository.fetchNewsPool();
      
      // Haberleri karıştır ama arkadaki ilk 2 haberin sabit kalması için 
      // sırayı tamamen bozmak yerine rastgele bir dizilişle başlayalım.
      // Firebase'den geldiğinde zaten belirli bir sırada olabilir.
      items.shuffle(); // Tüm desteyi başta bir kez karıştır
      
      state = state.copyWith(
        upcomingCards: items,
        status: SwipePhaseStatus.ready,
      );
    } catch (e) {
      state = state.copyWith(
        status: SwipePhaseStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Called on Swipe Right — tries to accept the top card.
  /// Returns true if accepted, false if deck is full (UI can show toast).
  bool acceptCard(NewsItem card) {
    if (state.isAtCapacity) {
      // Signal that we've hit max capacity — game can auto-advance
      state = state.copyWith(status: SwipePhaseStatus.fullCapacity);
      return false;
    }

    final newAccepted = [...state.acceptedCards, card];
    final newStatus = newAccepted.length >= AppConstants.maxPublishedArticles
        ? SwipePhaseStatus.fullCapacity
        : SwipePhaseStatus.ready;

    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      acceptedCards: newAccepted,
      status: newStatus,
    );
    return true;
  }

  /// Called on Swipe Left — rejects the top card.
  void rejectCard(NewsItem card) {
    final newRejected = [...state.rejectedCards, card];
    final newIndex = state.currentIndex + 1;

    // If deck is now empty, determine if we can proceed
    final newStatus = newIndex >= state.upcomingCards.length
        ? SwipePhaseStatus.finished
        : SwipePhaseStatus.ready;

    state = state.copyWith(
      currentIndex: newIndex,
      rejectedCards: newRejected,
      status: newStatus,
    );
  }

  /// Rescue a rejected card back into the upcoming deck (allows user to reconsider).
  void rescueRejectedCard(NewsItem card) {
    final newRejected = state.rejectedCards.where((n) => n.id != card.id).toList();
    // Destedeki sıradaki kart olması için currentIndex'e ekliyoruz
    final newUpcoming = List<NewsItem>.from(state.upcomingCards);
    newUpcoming.insert(state.currentIndex, card);
    
    state = state.copyWith(
      upcomingCards: newUpcoming,
      rejectedCards: newRejected,
      status: SwipePhaseStatus.ready,
    );
  }

  /// Mark that the background AI generation call has been fired.
  void markAiTriggered() {
    state = state.copyWith(aiTriggered: true);
  }

  /// Manually confirm the selection when deck is not empty but constraints are met.
  void confirmSelection() {
    if (state.isAtMinimum) {
      // Move remaining upcoming to rejected
      final allRejected = [...state.rejectedCards, ...state.upcomingCards];
      state = state.copyWith(
        upcomingCards: [],
        rejectedCards: allRejected,
        status: SwipePhaseStatus.finished,
      );
    }
  }

  void reset() {
    state = const GatekeeperState(status: SwipePhaseStatus.idle);
  }
}

// ─── Providers ───────────────────────────────────────────────────────────────
final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  return SQLiteNewsRepository();
});

final gatekeeperProvider =
    StateNotifierProvider<GatekeeperNotifier, GatekeeperState>((ref) {
  return GatekeeperNotifier(ref.watch(newsRepositoryProvider));
});
