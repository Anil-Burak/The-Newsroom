import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../application/persona_selection_notifier.dart';
import '../domain/persona.dart';
import 'widgets/persona_card.dart';
import 'widgets/create_persona_dialog.dart';

class PersonaSelectionScreen extends ConsumerStatefulWidget {
  const PersonaSelectionScreen({super.key});

  @override
  ConsumerState<PersonaSelectionScreen> createState() =>
      _PersonaSelectionScreenState();
}

class _PersonaSelectionScreenState
    extends ConsumerState<PersonaSelectionScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(personaSelectionProvider.notifier).loadPersonas());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(personaSelectionProvider);
    final selectedCount = state.selectedPersonas.length;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.inkGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Yapılandır',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.gold,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      'Yapay Zeka Personaları',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Haberleri kimin değerlendireceğini seçin. '
                      '$kMinModelPersonas ile $kMaxModelPersonas arasında persona belirleyin.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    // Selection counter pill
                    _SelectionCounter(
                      selected: selectedCount,
                      max: kMaxModelPersonas,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Persona List ───────────────────────────────────────────────
              if (state.isLoading)
                const Expanded(
                    child: Center(
                        child: CircularProgressIndicator(color: AppColors.gold)))
              else
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: state.personas.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final persona = state.personas[index];
                      final isSelected =
                          ref.read(personaSelectionProvider.notifier).isSelected(persona);
                      final atMax = selectedCount >= kMaxModelPersonas;
                      return PersonaCard(
                        persona: persona,
                        isActive: isSelected,
                        isDisabled: !isSelected && atMax,
                        onTap: () => ref
                            .read(personaSelectionProvider.notifier)
                            .togglePersona(persona),
                        onLongPress: () =>
                            _showPersonaActions(context, persona, index),
                      );
                    },
                  ),
                ),

              // ── Bottom Actions ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  children: [
                    // Add persona button (only when under max)
                    if (state.personas.length < 10)
                      OutlinedButton.icon(
                        onPressed: () => _showCreateDialog(context),
                        icon: const Icon(Icons.add_rounded,
                            color: AppColors.gold),
                        label: const Text('Özel Yapay Zeka Personası Ekle'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.gold,
                          side: const BorderSide(color: AppColors.gold),
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    // Start button
                    ElevatedButton(
                      onPressed: state.canProceed
                          ? () => context.go(AppConstants.routeGatekeeping)
                          : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('HABERLERİ ELEMEK İÇİN BAŞLA'),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded),
                        ],
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
  }

  // ── Dialogs ─────────────────────────────────────────────────────────────────

  void _showCreateDialog(BuildContext context, {Persona? editTarget}) {
    showDialog<Persona>(
      context: context,
      builder: (_) => CreatePersonaDialog(editTarget: editTarget),
    ).then((result) {
      if (result == null) return;
      final notifier = ref.read(personaSelectionProvider.notifier);
      if (editTarget != null) {
        notifier.editPersona(result.copyWith(id: editTarget.id));
      } else {
        notifier.addCustomPersona(result);
      }
    });
  }

  void _showPersonaActions(BuildContext context, Persona persona, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.inkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Persona name header
            Row(
              children: [
                Text(
                  persona.iconEmoji,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    persona.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.glassBorder),
            const SizedBox(height: 8),
            // Edit
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.edit_rounded, color: AppColors.gold),
              title: const Text('Personayı düzenle',
                  style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _showCreateDialog(context, editTarget: persona);
              },
            ),
            // Delete (disabled for default personas)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.delete_outline_rounded,
                color: persona.isDefault
                    ? AppColors.textMuted
                    : AppColors.rejectRed,
              ),
              title: Text(
                persona.isDefault
                    ? 'Yerleşik persona silinemez'
                    : 'Personayı sil',
                style: TextStyle(
                  color: persona.isDefault
                      ? AppColors.textMuted
                      : AppColors.rejectRed,
                ),
              ),
              onTap: persona.isDefault
                  ? null
                  : () {
                      Navigator.pop(context);
                      _confirmDelete(context, persona);
                    },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Persona persona) {
    showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.inkSurface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('"${persona.name}" silinsin mi?',
            style: Theme.of(context).textTheme.titleLarge),
        content: Text(
          'Bu persona kalıcı olarak kaldırılacak.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil',
                style: TextStyle(color: AppColors.rejectRed)),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        ref.read(personaSelectionProvider.notifier).deletePersona(persona);
      }
    });
  }
}

// ── Selection Counter Widget ──────────────────────────────────────────────────
class _SelectionCounter extends StatelessWidget {
  final int selected;
  final int max;
  const _SelectionCounter({required this.selected, required this.max});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...List.generate(max, (i) {
          final filled = i < selected;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    filled ? AppColors.gold : AppColors.glassSurface,
                border: Border.all(
                  color: filled ? AppColors.gold : AppColors.glassBorder,
                  width: 1.5,
                ),
              ),
              child: filled
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: AppColors.inkBlack)
                  : null,
            ),
          );
        }),
        const SizedBox(width: 8),
        Text(
          '$selected / $max seçildi',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: selected >= max
                    ? AppColors.gold
                    : AppColors.textMuted,
              ),
        ),
      ],
    );
  }
}
