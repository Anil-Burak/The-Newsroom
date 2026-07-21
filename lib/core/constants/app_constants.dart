class AppConstants {
  AppConstants._();

  // Gatekeeping rules
  static const int minPublishedArticles = 3;
  static const int maxPublishedArticles = 6;
  static const int totalNewsPoolSize = 30;

  // Layout template thresholds
  static const int template1Count = 3;
  static const int template2Count = 4;
  static const int template3Count = 5;
  static const int template4Count = 6;

  // Swipe velocity threshold (logical pixels/sec)
  static const double swipeVelocityThreshold = 1000.0;
  static const double swipeAngleThreshold = 30.0; // degrees

  // AI Background trigger delay (ms after first swipe)
  static const int aiTriggerDelayMs = 1500;

  // SQLite database name
  static const String dbName = 'gatekeeper.db';

  // Default persona IDs
  static const String personaPublicId = 'persona_public';
  static const String personaTabloidId = 'persona_tabloid';
  static const String personaIndependentId = 'persona_independent';

  // Navigation route names
  static const String routeSplash = '/';
  static const String routePersonaSelection = '/persona-selection';
  static const String routeGatekeeping = '/gatekeeping';
  static const String routeNewspaper = '/newspaper';
  static const String routeComparison = '/comparison';

  // ── OpenAI ───────────────────────────────────────────────────────────────
  // ⚠️  API key is embedded for institutional use — do not commit to public repos.
  static const String openAiApiKey = 'YOUR_OPENAI_API_KEY_HERE';
}
