import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
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
      'name': 'Kamu Yayıncısı',
      'bias': 'Devletin bekasını, kamu düzenini ve toplum ahlakını ön planda tutar. Muhalif çatlak sesleri ve sansasyonel haberleri filtreler.',
      'ethics': 'Resmi kaynaklara dayanmayan hiçbir habere yer vermez. Skandallardan ve magazinden nefret eder. Sıkıcı ama güvenilirdir.',
      'clickbaitThreshold': 10,
    },
    {
      'id': 'persona_tabloid',
      'name': 'Ticari Magazin',
      'bias': 'Sadece okunma sayısı, reklam geliri ve viral potansiyeli umrundadır. Şiddet, aldatma, ünlüler ve skandallar favorisidir.',
      'ethics': 'Etik kuralları yok sayar. Doğrulanmamış dedikoduları bile tıklanma uğruna manşete taşır. Başlıkları aşırı abartılıdır.',
      'clickbaitThreshold': 95,
    },
    {
      'id': 'persona_independent',
      'name': 'Bağımsız',
      'bias': 'Sisteme ve büyük sermayeye karşı muhaliftir. İnsan hakları, çevre sorunları, yolsuzluk ve sansürlenmiş gerçeklerin peşindedir.',
      'ethics': 'Editoryal bağımsızlığı her şeyden üstündür. Haberin kaynağı güvenilirse, hükümeti veya şirketleri kızdırmaktan çekinmez.',
      'clickbaitThreshold': 30,
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

      const systemPrompt = '''Sen "GateKeeper" adlı habercilik etiği ve yayın yönetmenliği oyununun simülasyon motorusun. 
Görevin, sana verilen haber havuzundaki içerikleri 3 farklı editör (persona) gözünden incelemek ve yayınlanacak haberleri seçmektir.

SİSTEM KURALLARI:
1. Her persona, kendi "bias" (taraf/ideoloji), "ethics" (etik anlayışı) ve "clickbaitThreshold" (tık tuzağı eşiği) değerlerine göre tamamen bağımsız seçimler yapmalıdır.
2. Her persona en az 3, en fazla 6 haber SEÇMEK zorundadır. Kalan haberleri reddetmelidir.
3. Personalar aynı haberleri seçmek zorunda değildir. Kararlar tamamen karakterlerine özgü olmalıdır.
4. Her persona, havuzdaki İSTİSNASIZ TÜM HABERLER (hem seçtikleri hem reddettikleri) için o karakterin ağzından yazılmış 1 cümlelik bir gerekçe (Justification Log) sunmalıdır.

ÇIKTI FORMATI:
Hiçbir açıklama veya düşünce süreci (thinking process) belirtmeden SADECE aşağıdaki JSON formatında yanıt ver! 
Markdown formatını kullanma, sadece doğrudan raw JSON çıktısı ver.

{
  "persona_public": {
    "selected": ["news_id_1", "news_id_3", "news_id_5"],
    "justifications": {
      "news_id_1": "Karakterin ağzından 1 cümlelik gerekçe",
      "news_id_2": "Karakterin ağzından 1 cümlelik gerekçe"
    }
  },
  "persona_tabloid": {
    "selected": ["news_id_2", "news_id_4", "news_id_6"],
    "justifications": {
      "news_id_1": "Karakterin ağzından 1 cümlelik gerekçe"
    }
  },
  "persona_independent": {
    "selected": ["news_id_7", "news_id_8", "news_id_9"],
    "justifications": {
      "news_id_1": "Karakterin ağzından 1 cümlelik gerekçe"
    }
  }
}''';

      final userPrompt =
          'NEWS POOL (${allNewsItems.length} items):\n$newsJson\n\nEDITOR PERSONAS (3 personas):\n$personasJson\n\n'
          'CRITICAL INSTRUCTION: DO NOT WRITE A THINKING PROCESS! SKIP THE ANALYSIS! '
          'You MUST start your response immediately with a { character.';

      // Sertifika doğrulama hatalarını atlamak için özel HTTP istemcisi (Bad Certificate Bypass)
      final ioClient = HttpClient()
        ..badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
      final client = IOClient(ioClient);

      final response = await client.post(
        Uri.parse('https://llmstat.iletisim.gov.tr/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConstants.openAiApiKey}',
        },
        body: jsonEncode({
          'model': 'qwen-397b',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
            {'role': 'assistant', 'content': '{\n  "persona_public": {'}
          ],
          'temperature': 0.7,
          'max_tokens': 8192,
        }),
      );
      
      // Kaynak sızıntısını önlemek için client'ı kapatıyoruz
      client.close();

      if (response.statusCode != 200) {
        throw Exception(
            'API error ${response.statusCode}: ${response.body}');
      }

      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      String rawContent =
          responseBody['choices'][0]['message']['content'] as String;
      
      // Eğer assistant prefill kullandıysak model geri kalanı tamamlar.
      // İçinde baştaki kısım yoksa (çoğu API eklemez), biz manuel eklemeliyiz.
      String content = rawContent;
      if (!content.trimLeft().startsWith('{')) {
        content = '{\n  "persona_public": {' + content;
      }
      
      // Temizlik aşaması: <think> veya Thinking Process gibi blokları ayıkla
      if (content.contains('</think>')) {
        content = content.split('</think>').last;
      }
      
      // JSON Markdown (```json ... ```) ile sarılmışsa onu ayıkla
      if (content.contains('```json')) {
        content = content.split('```json')[1].split('```')[0];
      } else if (content.contains('```')) {
        content = content.split('```')[1].split('```')[0];
      }

      // En güvenilir yol olarak sadece { ile } arasını al
      final startIndex = content.indexOf('{');
      final endIndex = content.lastIndexOf('}');
      if (startIndex != -1 && endIndex != -1) {
        content = content.substring(startIndex, endIndex + 1);
      } else {
        throw Exception('API çıktısında JSON başlangıç veya bitiş karakteri bulunamadı. Model sadece düz metin üretmiş olabilir.');
      }

      Map<String, dynamic> data;
      try {
        data = jsonDecode(content) as Map<String, dynamic>;
      } catch (e) {
        throw Exception(
            'JSON Parse Error: $e\n\nExtracted Content:\n$content\n\nRaw Model Output:\n${responseBody['choices'][0]['message']['content']}');
      }

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
