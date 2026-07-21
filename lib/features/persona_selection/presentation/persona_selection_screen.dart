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

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.inkGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose Your',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.gold,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      'Editor Persona',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your persona shapes what news is worthy of print.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Persona Cards
              if (state.isLoading)
                const Expanded(
                    child: Center(
                        child: CircularProgressIndicator(
                            color: AppColors.gold)))
              else
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: state.personas.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final persona = state.personas[index];
                      final isActive = state.activePersona?.id == persona.id;
                      return PersonaCard(
                        persona: persona,
                        isActive: isActive,
                        onTap: () => ref
                            .read(personaSelectionProvider.notifier)
                            .selectPersona(persona),
                        onLongPress: () => _showReplaceDialog(context, index),
                      );
                    },
                  ),
                ),

              // Bottom actions
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Create custom persona
                    OutlinedButton.icon(
                      onPressed: () => _showCreateDialog(context),
                      icon: const Icon(Icons.add_rounded, color: AppColors.gold),
                      label: const Text('Create Custom Persona'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.gold,
                        side: const BorderSide(color: AppColors.gold),
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Start game
                    ElevatedButton(
                      onPressed: state.activePersona != null
                          ? () => context.go(AppConstants.routeGatekeeping)
                          : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('START GATEKEEPING'),
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

  void _showCreateDialog(BuildContext context, {int? replaceIndex}) {
    showDialog<Persona>(
      context: context,
      builder: (_) => const CreatePersonaDialog(),
    ).then((newPersona) {
      if (newPersona != null) {
        ref
            .read(personaSelectionProvider.notifier)
            .addOrReplaceCustomPersona(newPersona, replaceIndex: replaceIndex);
      }
    });
  }

  void _showReplaceDialog(BuildContext context, int index) {
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
          children: [
            Text('Replace this persona?',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.swap_horiz_rounded, color: AppColors.gold),
              title: const Text('Replace with new custom persona',
                  style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _showCreateDialog(context, replaceIndex: index);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
