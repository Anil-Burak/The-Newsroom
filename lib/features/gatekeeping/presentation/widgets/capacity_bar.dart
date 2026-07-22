import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class CapacityBar extends StatelessWidget {
  final int current;
  final int max;
  final int min;

  const CapacityBar({
    super.key,
    required this.current,
    required this.max,
    required this.min,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ÖN SAYFA SLOTLARI',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(letterSpacing: 1.5),
            ),
            Text(
              '$current / $max',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: current >= min ? AppColors.publishGreen : AppColors.gold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 10,
          child: Row(
            children: List.generate(max, (index) {
              final filled = index < current;
              final isMin = index == min - 1;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: filled
                        ? (current > min
                            ? AppColors.publishGreen
                            : AppColors.gold)
                        : AppColors.glassSurface,
                    borderRadius: BorderRadius.circular(3),
                    border: isMin && !filled
                        ? Border.all(
                            color: AppColors.gold.withOpacity(0.5), width: 1)
                        : null,
                    boxShadow: filled
                        ? [
                            BoxShadow(
                              color: AppColors.publishGreen.withOpacity(0.4),
                              blurRadius: 6,
                            )
                          ]
                        : null,
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          current < min
              ? 'En az $min haber seçmelisiniz'
              : current == max
                  ? 'Ön sayfa dolu!'
                  : '${max - current} haber daha ekleyebilir ya da şimdi baskıya gönderebilirsiniz',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
