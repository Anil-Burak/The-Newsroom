import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/persona.dart';
import '../data/persona_repository.dart';

// ─── State ───────────────────────────────────────────────────────────────────
class PersonaSelectionState {
  final List<Persona> personas;
  final Persona? activePersona;
  final bool isLoading;
  final String? error;

  const PersonaSelectionState({
    this.personas = const [],
    this.activePersona,
    this.isLoading = false,
    this.error,
  });

  PersonaSelectionState copyWith({
    List<Persona>? personas,
    Persona? activePersona,
    bool? isLoading,
    String? error,
  }) =>
      PersonaSelectionState(
        personas: personas ?? this.personas,
        activePersona: activePersona ?? this.activePersona,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

// ─── Notifier ────────────────────────────────────────────────────────────────
class PersonaSelectionNotifier extends StateNotifier<PersonaSelectionState> {
  final PersonaRepository _repo;

  PersonaSelectionNotifier(this._repo)
      : super(const PersonaSelectionState(isLoading: true));

  Future<void> loadPersonas() async {
    state = state.copyWith(isLoading: true);
    try {
      final personas = await _repo.fetchDefaultPersonas();
      state = state.copyWith(
        personas: personas,
        activePersona: personas.isNotEmpty ? personas.first : null,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectPersona(Persona persona) {
    state = state.copyWith(activePersona: persona);
  }

  /// Adds a new custom persona to the list.
  /// If [replaceIndex] is provided, replaces the persona at that slot.
  Future<void> addOrReplaceCustomPersona(Persona newPersona,
      {int? replaceIndex}) async {
    final updatedList = [...state.personas];
    if (replaceIndex != null &&
        replaceIndex >= 0 &&
        replaceIndex < updatedList.length) {
      // If we're replacing a non-default, delete the old one from Firestore
      if (!updatedList[replaceIndex].isDefault) {
        await _repo.deleteCustomPersona(updatedList[replaceIndex].id);
      }
      updatedList[replaceIndex] = newPersona;
    } else {
      updatedList.add(newPersona);
    }
    await _repo.saveCustomPersona(newPersona);
    state = state.copyWith(personas: updatedList, activePersona: newPersona);
  }
}

// ─── Providers ───────────────────────────────────────────────────────────────
final personaRepositoryProvider = Provider<PersonaRepository>((ref) {
  return SQLitePersonaRepository();
});

final personaSelectionProvider =
    StateNotifierProvider<PersonaSelectionNotifier, PersonaSelectionState>((ref) {
  return PersonaSelectionNotifier(ref.watch(personaRepositoryProvider));
});

/// Convenience provider to get the currently active persona elsewhere.
final activePersonaProvider = Provider<Persona?>((ref) {
  return ref.watch(personaSelectionProvider).activePersona;
});
