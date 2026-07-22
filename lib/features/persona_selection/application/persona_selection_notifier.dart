import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/persona.dart';
import '../data/persona_repository.dart';

// ─── Constants ───────────────────────────────────────────────────────────────
const int kMinModelPersonas = 1;
const int kMaxModelPersonas = 3;

// ─── State ───────────────────────────────────────────────────────────────────
class PersonaSelectionState {
  /// All available personas in the pool.
  final List<Persona> personas;

  /// Selected model personas (the AI will run as these; min 1, max 3).
  final List<Persona> selectedPersonas;

  final bool isLoading;
  final String? error;

  const PersonaSelectionState({
    this.personas = const [],
    this.selectedPersonas = const [],
    this.isLoading = false,
    this.error,
  });

  /// Convenience: first selected persona (legacy compat).
  Persona? get activePersona =>
      selectedPersonas.isNotEmpty ? selectedPersonas.first : null;

  bool get canProceed => selectedPersonas.isNotEmpty;

  PersonaSelectionState copyWith({
    List<Persona>? personas,
    List<Persona>? selectedPersonas,
    bool? isLoading,
    String? error,
  }) =>
      PersonaSelectionState(
        personas: personas ?? this.personas,
        selectedPersonas: selectedPersonas ?? this.selectedPersonas,
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
      // Pre-select first persona so min-1 constraint is satisfied
      final preSelected = personas.isNotEmpty ? [personas.first] : <Persona>[];
      state = state.copyWith(
        personas: personas,
        selectedPersonas: preSelected,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Toggle a persona in/out of the selected list (respecting min/max).
  void togglePersona(Persona persona) {
    final current = [...state.selectedPersonas];
    final idx = current.indexWhere((p) => p.id == persona.id);

    if (idx >= 0) {
      // Deselect – only if it won't violate minimum
      if (current.length > kMinModelPersonas) {
        current.removeAt(idx);
        state = state.copyWith(selectedPersonas: current);
      }
    } else {
      // Select – only if under maximum
      if (current.length < kMaxModelPersonas) {
        current.add(persona);
        state = state.copyWith(selectedPersonas: current);
      }
    }
  }

  bool isSelected(Persona persona) =>
      state.selectedPersonas.any((p) => p.id == persona.id);

  /// Adds a brand-new custom persona and auto-selects it (if room).
  Future<void> addCustomPersona(Persona newPersona) async {
    final updatedList = [...state.personas, newPersona];
    await _repo.saveCustomPersona(newPersona);
    final current = [...state.selectedPersonas];
    if (current.length < kMaxModelPersonas) current.add(newPersona);
    state = state.copyWith(
      personas: updatedList,
      selectedPersonas: current,
    );
  }

  /// Edits an existing persona in-place.
  Future<void> editPersona(Persona updated) async {
    final updatedList = state.personas
        .map((p) => p.id == updated.id ? updated : p)
        .toList();
    final updatedSelected = state.selectedPersonas
        .map((p) => p.id == updated.id ? updated : p)
        .toList();
    await _repo.saveCustomPersona(updated);
    state = state.copyWith(
      personas: updatedList,
      selectedPersonas: updatedSelected,
    );
  }

  /// Deletes a persona (removes from pool and selection).
  Future<void> deletePersona(Persona persona) async {
    final updatedList =
        state.personas.where((p) => p.id != persona.id).toList();
    var updatedSelected =
        state.selectedPersonas.where((p) => p.id != persona.id).toList();
    // Ensure min 1 after deletion
    if (updatedSelected.isEmpty && updatedList.isNotEmpty) {
      updatedSelected = [updatedList.first];
    }
    if (!persona.isDefault) {
      await _repo.deleteCustomPersona(persona.id);
    }
    state = state.copyWith(
      personas: updatedList,
      selectedPersonas: updatedSelected,
    );
  }

  // ── Legacy compat ──────────────────────────────────────────────────────────
  void selectPersona(Persona persona) => togglePersona(persona);

  Future<void> addOrReplaceCustomPersona(Persona newPersona,
      {int? replaceIndex}) async {
    if (replaceIndex != null &&
        replaceIndex >= 0 &&
        replaceIndex < state.personas.length) {
      final old = state.personas[replaceIndex];
      if (!old.isDefault) await _repo.deleteCustomPersona(old.id);
      final updatedList = [...state.personas]
        ..[replaceIndex] = newPersona;
      final updatedSelected = state.selectedPersonas
          .map((p) => p.id == old.id ? newPersona : p)
          .toList();
      await _repo.saveCustomPersona(newPersona);
      state = state.copyWith(
          personas: updatedList, selectedPersonas: updatedSelected);
    } else {
      await addCustomPersona(newPersona);
    }
  }
}

// ─── Providers ───────────────────────────────────────────────────────────────
final personaRepositoryProvider = Provider<PersonaRepository>((ref) {
  return SQLitePersonaRepository();
});

final personaSelectionProvider =
    StateNotifierProvider<PersonaSelectionNotifier, PersonaSelectionState>(
        (ref) {
  return PersonaSelectionNotifier(ref.watch(personaRepositoryProvider));
});

/// Convenience provider – first selected persona (legacy compat).
final activePersonaProvider = Provider<Persona?>((ref) {
  return ref.watch(personaSelectionProvider).activePersona;
});

/// All currently selected model personas.
final selectedPersonasProvider = Provider<List<Persona>>((ref) {
  return ref.watch(personaSelectionProvider).selectedPersonas;
});
