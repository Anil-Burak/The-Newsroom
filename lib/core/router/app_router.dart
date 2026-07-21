import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/persona_selection/presentation/persona_selection_screen.dart';
import '../../features/gatekeeping/presentation/gatekeeping_screen.dart';
import '../../features/newspaper_render/presentation/newspaper_screen.dart';
import '../../features/comparison_matrix/presentation/comparison_screen.dart';
import '../constants/app_constants.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppConstants.routeSplash,
    routes: [
      GoRoute(
        path: AppConstants.routeSplash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppConstants.routePersonaSelection,
        builder: (context, state) => const PersonaSelectionScreen(),
      ),
      GoRoute(
        path: AppConstants.routeGatekeeping,
        builder: (context, state) => const GatekeepingScreen(),
      ),
      GoRoute(
        path: AppConstants.routeNewspaper,
        builder: (context, state) => const NewspaperScreen(),
      ),
      GoRoute(
        path: AppConstants.routeComparison,
        builder: (context, state) => const ComparisonScreen(),
      ),
    ],
  );
});
