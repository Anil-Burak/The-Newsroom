import 'dart:io';

void main() {
  final file = File('lib/core/database/seed_data.dart');
  final content = file.readAsStringSync();
  final newContent = content.replaceAll('.png"', '.jpg"');
  file.writeAsStringSync(newContent);
  print('Updated seed_data.dart');
}
