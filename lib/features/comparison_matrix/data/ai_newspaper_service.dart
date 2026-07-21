import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../gatekeeping/domain/news_item.dart';
import '../../../core/constants/app_constants.dart';

// ─── Model ───────────────────────────────────────────────────────────────────
class AINewspaper {
  final String personaId;
  final List<String> selectedNewsIds;
  final Map<String, String> justifications; // newsId → justification text

  const AINewspaper({
    required this.personaId,
    required this.selectedNewsIds,
    required this.justifications,
  });

  factory AINewspaper.fromMap(String personaId, Map<String, dynamic> map) {
    return AINewspaper(
      personaId: personaId,
      selectedNewsIds: List<String>.from(map['selected'] as List? ?? []),
      justifications: Map<String, String>.from(
        (map['justifications'] as Map? ?? {}).map(
          (k, v) => MapEntry(k.toString(), v.toString()),
        ),
      ),
    );
  }
}

// ─── State ───────────────────────────────────────────────────────────────────
enum AIGenerationStatus { idle, loading, ready, error }

class AINewspaperState {
  final Map<String, AINewspaper> newspapers; // personaId → AINewspaper
  final AIGenerationStatus status;
  final String? error;

  const AINewspaperState({
    this.newspapers = const {},
    this.status = AIGenerationStatus.idle,
    this.error,
  });

  bool get isReady => status == AIGenerationStatus.ready;

  AINewspaperState copyWith({
    Map<String, AINewspaper>? newspapers,
    AIGenerationStatus? status,
    String? error,
  }) =>
      AINewspaperState(
        newspapers: newspapers ?? this.newspapers,
        status: status ?? this.status,
        error: error,
      );
}

// ─── Service / Notifier ───────────────────────────────────────────────────────
class AINewspaperService extends StateNotifier<AINewspaperState> {
  AINewspaperService() : super(const AINewspaperState());

  static const _defaultPersonas = [
    {
      'id': 'persona_public',
      'name': 'Public Broadcaster',
      'bias':
          'Neutral, civic-minded, focuses on public interest and democratic accountability.',
      'ethics':
          'Very high. Strict fact-checking, no sensationalism, balanced perspectives required.',
      'clickbaitThreshold': 15,
    },
    {
      'id': 'persona_tabloid',
      'name': 'Commercial Tabloid',
      'bias':
          'Sensationalist. Heavily favors high emotional impact, celebrity gossip, crime, and scandal.',
      'ethics':
          'Low. Will publish unverified rumors if engaging enough. Prioritizes clicks over truth.',
      'clickbaitThreshold': 85,
    },
    {
      'id': 'persona_independent',
      'name': 'Independent',
      'bias':
          'Progressive, anti-establishment. Prioritizes underreported stories, activism, and systemic issues.',
      'ethics':
          'High on principles, but may take a strong editorial stance. Avoids corporate-friendly narratives.',
      'clickbaitThreshold': 40,
    },
  ];

  /// Calls OpenAI Chat Completions API directly to generate AI newspapers
  /// for all 3 default personas. Results are cached in this notifier's state.
  Future<void> generateAINewspapers({
    required List<NewsItem> allNewsItems,
  }) async {
    if (state.status == AIGenerationStatus.loading ||
        state.status == AIGenerationStatus.ready) {
      return;
    }

    state = state.copyWith(status: AIGenerationStatus.loading);

    try {
      final newsJson = jsonEncode(
        allNewsItems
            .map((n) => {
                  'id': n.id,
                  'headline': n.headline,
                  'summary': n.summary,
                  'category': n.category,
                  'sensationalismScore': n.sensationalismScore,
                  'biasIndex': n.biasIndex,
                  'tags': n.tags,
                })
            .toList(),
      );

      final personasJson = jsonEncode(_defaultPersonas);

      const systemPrompt = '''You are the simulation engine for "GateKeeper", an educational game about news selection bias (Gatekeeping Theory by Kurt Lewin & David Manning White).

CONTEXT:
You will receive a pool of news items and 3 editor personas. Each persona has distinct values, ethics, and a clickbaitThreshold (0–100, where 100 = will publish any sensational content, 0 = only calm factual pieces).

TASK:
Simulate each of the 3 editor personas independently reviewing the provided news pool.
For EACH persona:
1. SELECT between 3 and 6 news items to publish, based STRICTLY on their bias, ethics, and clickbaitThreshold. Do NOT select fewer than 3 or more than 6.
2. REJECT all remaining items.
3. Write a brief, 1-sentence "Justification Log" for EVERY item in the pool (both selected and rejected), written in the first-person voice of THAT persona's character. Examples:
   - Public Broadcaster on a celebrity scandal: "This story lacks public interest value and would undermine our credibility."
   - Tabloid on the same story: "This is pure gold — our readers live for this kind of drama."
   - Independent on a corporate tax story: "This exposes systemic inequality that our mainstream competitors won't touch."

CRITICAL RULES:
- Your output MUST be valid JSON only, no markdown, no preamble, no explanation.
- Justifications MUST cover ALL items in the pool for each persona.
- Do NOT let personas select the same set of articles; their choices should reflect their distinct biases.

OUTPUT FORMAT (strict JSON):
{
  "persona_public": {
    "selected": ["news_id_1", "news_id_3"],
    "justifications": {
      "news_id_1": "justification string from this persona's voice",
      "news_id_2": "justification string from this persona's voice"
    }
  },
  "persona_tabloid": { ... },
  "persona_independent": { ... }
}''';

      final userPrompt =
          'NEWS POOL (${allNewsItems.length} items):\n$newsJson\n\nEDITOR PERSONAS (3 personas):\n$personasJson\n\nGenerate the three distinct newspapers now.';

      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConstants.openAiApiKey}',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'response_format': {'type': 'json_object'},
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'temperature': 0.85,
          'max_tokens': 4000,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'OpenAI API error ${response.statusCode}: ${response.body}');
      }

      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      final content =
          responseBody['choices'][0]['message']['content'] as String;
      final data = jsonDecode(content) as Map<String, dynamic>;

      final newspapers = <String, AINewspaper>{};
      for (final entry in data.entries) {
        newspapers[entry.key] = AINewspaper.fromMap(
          entry.key,
          entry.value as Map<String, dynamic>,
        );
      }

      state = state.copyWith(
        newspapers: newspapers,
        status: AIGenerationStatus.ready,
      );
    } catch (e) {
      state = state.copyWith(
        status: AIGenerationStatus.error,
        error: e.toString(),
      );
    }
  }
}

// ─── Provider ────────────────────────────────────────────────────────────────
final aiNewspaperServiceProvider =
    StateNotifierProvider<AINewspaperService, AINewspaperState>((ref) {
  return AINewspaperService();
});
