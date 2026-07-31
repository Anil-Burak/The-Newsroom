import 'package:flutter/material.dart';
import '../../domain/persona.dart';
import '../../../../core/theme/app_theme.dart';

class PersonaCard extends StatelessWidget {
  final Persona persona;
  final bool isActive;
  final bool isDisabled;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const PersonaCard({
    super.key,
    required this.persona,
    required this.isActive,
    this.isDisabled = false,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isDisabled ? 0.45 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: isDisabled ? null : onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? AppColors.gold : AppColors.glassBorder,
            width: isActive ? 2.0 : 1.0,
          ),
          color: AppColors.inkSurface,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.gold.withOpacity(0.12),
                    blurRadius: 12,
                    spreadRadius: 1,
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Emoji avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.glassSurface,
                border: Border.all(
                  color: isActive ? AppColors.gold : AppColors.glassBorder,
                ),
              ),
              child: Center(
                child: Text(persona.iconEmoji,
                    style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 16),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        persona.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: isActive
                                  ? AppColors.inkBlack
                                  : AppColors.textPrimary,
                              fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                            ),
                      ),
                      if (!persona.isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'ÖZEL',
                            style: TextStyle(
                              color: AppColors.gold,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    persona.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  // Clickbait threshold indicator
                  Row(
                    children: [
                      Text(
                        'Clickbait Eşiği: ',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: persona.aiConfig.clickbaitThreshold / 100,
                            backgroundColor: AppColors.glassSurface,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.gold,
                            ),
                            minHeight: 4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${persona.aiConfig.clickbaitThreshold}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isActive
                                  ? AppColors.gold
                                  : AppColors.textMuted,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Active indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? AppColors.gold : Colors.transparent,
                border: Border.all(
                  color: isActive ? AppColors.gold : AppColors.glassBorder,
                  width: 2,
                ),
              ),
              child: isActive
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
      ),
    );
  }
}
