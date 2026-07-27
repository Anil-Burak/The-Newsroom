import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../gatekeeping/application/gatekeeper_notifier.dart';
import '../../persona_selection/application/persona_selection_notifier.dart';
import '../../comparison_matrix/data/ai_newspaper_service.dart';
import 'widgets/newspaper_view.dart';

class NewspaperScreen extends ConsumerWidget {
  const NewspaperScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gatekeeperProvider);
    final persona = ref.watch(activePersonaProvider);
    final accepted = state.acceptedCards;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        final bool? shouldPop = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.inkSurface,
            title: const Text('Ana Sayfaya Dön', style: TextStyle(color: AppColors.textPrimary)),
            content: const Text('Ana sayfaya dönmek ister misiniz? İlerlemeniz kaybolacak.', style: TextStyle(color: AppColors.textSecondary)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('İptal', style: TextStyle(color: AppColors.textMuted)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Evet', style: TextStyle(color: AppColors.publishGreen)),
              ),
            ],
          ),
        );
        
        if (shouldPop == true && context.mounted) {
          ref.read(gatekeeperProvider.notifier).reset();
          ref.invalidate(aiNewspaperServiceProvider);
          context.go(AppConstants.routePersonaSelection);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F0E8), // aged newsprint
        bottomNavigationBar: Container(
          color: const Color(0xFFF5F0E8),
          padding: EdgeInsets.fromLTRB(
            20,
            10,
            20,
            MediaQuery.of(context).padding.bottom + 16,
          ),
          child: ElevatedButton(
            onPressed: () => context.go(AppConstants.routeComparison),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              backgroundColor: AppColors.inkDeep,
              foregroundColor: AppColors.gold,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('KARŞILAŞTIRMAYI GÖR'),
                SizedBox(width: 8),
                Icon(Icons.compare_rounded),
              ],
            ),
          ),
        ),
        body: SafeArea(
          bottom: false, // bottom handled by bottomNavigationBar padding
          child: NewspaperView(
            personaName: persona?.name ?? 'Senin Gazeten',
            articles: accepted,
            isPlayer: true,
          ),
        ),
      ),
    );
  }
}
