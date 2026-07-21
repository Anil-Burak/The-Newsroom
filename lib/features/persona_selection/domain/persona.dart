class Persona {
  final String id;
  final String name;
  final String description;
  final String iconEmoji;
  final bool isDefault;
  final int sortOrder;
  final PersonaAiConfig aiConfig;

  const Persona({
    required this.id,
    required this.name,
    required this.description,
    required this.iconEmoji,
    required this.isDefault,
    this.sortOrder = 99,
    required this.aiConfig,
  });

  factory Persona.fromMap(Map<String, dynamic> map) {
    return Persona(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      iconEmoji: map['iconEmoji'] as String? ?? '📰',
      isDefault: (map['isDefault'] as int? ?? 0) == 1,
      sortOrder: map['sortOrder'] as int? ?? 99,
      aiConfig: PersonaAiConfig.fromMap(map),
    );
  }

  Persona copyWith({
    String? id,
    String? name,
    String? description,
    String? iconEmoji,
    bool? isDefault,
    int? sortOrder,
    PersonaAiConfig? aiConfig,
  }) =>
      Persona(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        iconEmoji: iconEmoji ?? this.iconEmoji,
        isDefault: isDefault ?? this.isDefault,
        sortOrder: sortOrder ?? this.sortOrder,
        aiConfig: aiConfig ?? this.aiConfig,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'iconEmoji': iconEmoji,
        'isDefault': isDefault ? 1 : 0,
        'sortOrder': sortOrder,
        'bias': aiConfig.bias,
        'ethics': aiConfig.ethics,
        'clickbaitThreshold': aiConfig.clickbaitThreshold,
      };
}

class PersonaAiConfig {
  final String bias;
  final String ethics;
  final int clickbaitThreshold;

  const PersonaAiConfig({
    required this.bias,
    required this.ethics,
    required this.clickbaitThreshold,
  });

  factory PersonaAiConfig.fromMap(Map<String, dynamic> map) => PersonaAiConfig(
        bias: map['bias'] as String? ?? '',
        ethics: map['ethics'] as String? ?? '',
        clickbaitThreshold: map['clickbaitThreshold'] as int? ?? 50,
      );

  Map<String, dynamic> toMap() => {
        'bias': bias,
        'ethics': ethics,
        'clickbaitThreshold': clickbaitThreshold,
      };
}
