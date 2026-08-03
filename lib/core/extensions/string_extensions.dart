/// Türkçe dil desteğiyle büyük/küçük harf dönüşümleri.
/// Dart'ın varsayılan toUpperCase() metodu Türkçe'ye özgü
/// 'i'→'İ', 'ı'→'I', 'ş'→'Ş', 'ç'→'Ç', 'ğ'→'Ğ', 'ö'→'Ö', 'ü'→'Ü'
/// dönüşümlerini yapmaz. Bu extension bunu düzeltir.
extension TurkishStringExtension on String {
  static const _trUpperMap = {
    'i': 'İ',
    'ı': 'I',
    'ş': 'Ş',
    'ç': 'Ç',
    'ğ': 'Ğ',
    'ö': 'Ö',
    'ü': 'Ü',
  };

  /// Türkçe karakterleri doğru şekilde büyük harfe çevirir.
  String toUpperCaseTr() {
    final buffer = StringBuffer();
    for (final char in characters) {
      buffer.write(_trUpperMap[char] ?? char.toUpperCase());
    }
    return buffer.toString();
  }
}

/// characters getter'ı olmadan basit rune-level iterasyon
extension on String {
  Iterable<String> get characters sync* {
    for (int i = 0; i < length; i++) {
      yield this[i];
    }
  }
}
