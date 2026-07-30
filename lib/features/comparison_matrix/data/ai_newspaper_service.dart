import 'dart:io';
import 'dart:convert';
import 'package:http/io_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../gatekeeping/domain/news_item.dart';
import '../../persona_selection/domain/persona.dart';
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

  /// Calls OpenAI Chat Completions API directly to generate AI newspapers
  /// for the given [personas]. Results are cached in this notifier's state.
  Future<void> generateAINewspapers({
    required List<NewsItem> allNewsItems,
    required List<Persona> personas,
  }) async {
    if (state.status == AIGenerationStatus.loading ||
        state.status == AIGenerationStatus.ready) {
      return;
    }

    if (personas.isEmpty) {
      state = state.copyWith(
        status: AIGenerationStatus.error,
        error: 'Karşılaştırma için seçili persona bulunamadı.',
      );
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

      // Persona listesini dinamik olarak oluştur
      final personasList = personas
          .map((p) => {
                'id': p.id,
                'name': p.name,
                'bias': p.aiConfig.bias,
                'ethics': p.aiConfig.ethics,
                'clickbaitThreshold': p.aiConfig.clickbaitThreshold,
              })
          .toList();
      final personasJson = jsonEncode(personasList);
      final personaCount = personas.length;
      final personaIds = personas.map((p) => p.id).toList();

      // Dinamik JSON örneği oluştur (prompt'a gömülecek)
      final exampleJson = StringBuffer('{\n');
      for (int i = 0; i < personaIds.length; i++) {
        final pid = personaIds[i];
        exampleJson.writeln('  "$pid": {');
        exampleJson.writeln('    "selected": ["news_id_1", "news_id_3"],');
        exampleJson.writeln('    "justifications": {');
        exampleJson.writeln('      "news_id_1": "Karakterin ağzından 1 cümlelik gerekçe",');
        exampleJson.writeln('      "news_id_2": "Karakterin ağzından 1 cümlelik gerekçe"');
        exampleJson.writeln('    }');
        exampleJson.write('  }');
        if (i < personaIds.length - 1) exampleJson.write(',');
        exampleJson.writeln();
      }
      exampleJson.write('}');

      final systemPrompt = '''Sen "GateKeeper" adlı habercilik etiği ve yayın yönetmenliği oyununun simülasyon motorusun. 
Görevin, sana verilen haber havuzundaki içerikleri $personaCount farklı editör (persona) gözünden incelemek ve yayınlanacak haberleri seçmektir.

SİSTEM KURALLARI:
1. Her persona, kendi "bias" (taraf/ideoloji), "ethics" (etik anlayışı) ve "clickbaitThreshold" (tık tuzağı eşiği) değerlerine göre tamamen bağımsız seçimler yapmalıdır.
2. Her persona en az 3, en fazla 6 haber SEÇMEK zorundadır. Kalan haberleri reddetmelidir.
3. Personalar aynı haberleri seçmek zorunda değildir. Kararlar tamamen karakterlerine özgü olmalıdır.
4. Her persona, havuzdaki İSTİSNASIZ TÜM HABERLER (hem seçtikleri hem reddettikleri) için o karakterin ağzından yazılmış 1 cümlelik bir gerekçe (Justification Log) sunmalıdır.

ÇIKTI FORMATI:
Hiçbir açıklama veya düşünce süreci (thinking process) belirtmeden SADECE aşağıdaki JSON formatında yanıt ver! 
Markdown formatını kullanma, sadece doğrudan raw JSON çıktısı ver.
JSON anahtarları olarak persona ID'lerini AYNEN kullan: ${personaIds.map((id) => '"$id"').join(', ')}

$exampleJson''';

      final userPrompt =
          'NEWS POOL (${allNewsItems.length} items):\n$newsJson\n\nEDITOR PERSONAS ($personaCount personas):\n$personasJson\n\n'
          'CRITICAL INSTRUCTION: DO NOT WRITE A THINKING PROCESS! SKIP THE ANALYSIS! '
          'You MUST start your response immediately with a { character.';

      // İlk persona ID'si ile assistant prefill oluştur
      final firstPersonaId = personaIds.first;
      final assistantPrefill = '{\n  "$firstPersonaId": {';

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
            {'role': 'assistant', 'content': assistantPrefill}
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
        content = assistantPrefill + content;
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
        // BULLETPROOF FALLBACK PARSER
        // Eğer JSON yarım kaldıysa (max_tokens bittiyse) veya bozuksa, RegExp ile kurtarabildiğimiz kadarını kurtarırız.
        data = _bulletproofParse(rawContent, personaIds);
        
        if (data.isEmpty || !data.containsKey(personaIds.first) ||
            (data[personaIds.first]['selected'] as List).isEmpty) {
          throw Exception('Kritik Hata: JSON yarım kaldı ve Bulletproof Parser da veri çıkaramadı.\nRaw Output:\n$rawContent');
        }
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

  /// JSON yapısı bozuk olsa bile Regex ile verileri ayıklayan kurtarıcı fonksiyon (Bulletproof Parser)
  Map<String, dynamic> _bulletproofParse(String content, List<String> personaIds) {
    final Map<String, dynamic> data = {};

    for (final p in personaIds) {
      data[p] = {
        'selected': <String>[],
        'justifications': <String, dynamic>{}
      };

      final pIndex = content.indexOf('"$p"');
      if (pIndex == -1) continue;

      int nextPIndex = content.length;
      for (final otherP in personaIds) {
        if (otherP != p) {
          final idx = content.indexOf('"$otherP"', pIndex + 1);
          if (idx != -1 && idx < nextPIndex) {
            nextPIndex = idx;
          }
        }
      }

      final block = content.substring(pIndex, nextPIndex);

      // "selected": ["news_002", "news_013"] listesini ayıkla
      final selectedRegex = RegExp(r'"selected"\s*:\s*\[(.*?)\]', dotAll: true);
      final selectedMatch = selectedRegex.firstMatch(block);
      if (selectedMatch != null) {
        final idsStr = selectedMatch.group(1) ?? '';
        final idRegex = RegExp(r'"(news_\d+)"');
        data[p]['selected'] = idRegex.allMatches(idsStr).map((m) => m.group(1)!).toList();
      }

      // "news_001": "Gerekçe" eşleşmelerini ayıkla (Kaçış karakterleri dahil her türlü metni kapsar)
      final justRegex = RegExp(r'"(news_\d+)"\s*:\s*"([^"\\]*(?:\\.[^"\\]*)*)"');
      final justMatches = justRegex.allMatches(block);
      for (final m in justMatches) {
        data[p]['justifications'][m.group(1)!] = m.group(2)!;
      }
    }
    return data;
  }
}

// ─── Provider ────────────────────────────────────────────────────────────────
final aiNewspaperServiceProvider =
    StateNotifierProvider<AINewspaperService, AINewspaperState>((ref) {
  return AINewspaperService();
});
