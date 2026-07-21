import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _slideUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideUp = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();

    // Navigate after splash delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) context.go(AppConstants.routePersonaSelection);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.inkGradient),
        child: Center(
          child: FadeTransition(
            opacity: _fadeIn,
            child: AnimatedBuilder(
              animation: _slideUp,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, _slideUp.value),
                child: child,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Press badge icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.goldDark, AppColors.gold],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withOpacity(0.4),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.newspaper_rounded,
                      size: 52,
                      color: AppColors.inkBlack,
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Title
                  Text(
                    'GATEKEEPER',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 40,
                          letterSpacing: 8,
                          foreground: Paint()
                            ..shader = const LinearGradient(
                              colors: [AppColors.goldDark, AppColors.goldLight],
                            ).createShader(
                              const Rect.fromLTWH(0, 0, 300, 60),
                            ),
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Who controls the news?',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                          letterSpacing: 2.0,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                  const SizedBox(height: 48),
                  // Attribution
                  Text(
                    'Based on Lewin & White\'s Gatekeeping Theory',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
