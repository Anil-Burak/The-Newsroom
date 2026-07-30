import 'dart:io';
import 'package:image/image.dart' as img;

void main() async {
  final dir = Directory('images');
  if (!dir.existsSync()) {
    print('images directory not found!');
    return;
  }
  
  final files = dir.listSync().whereType<File>().where((f) => f.path.endsWith('.png')).toList();
  
  for (final file in files) {
    print('Processing ${file.path}...');
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);
    
    if (image == null) {
      print('Failed to decode ${file.path}');
      continue;
    }
    
    // Resize image if it's too large (e.g. width > 800 for news thumbnails)
    img.Image resized = image;
    if (image.width > 800) {
      resized = img.copyResize(image, width: 800);
    }
    
    // Encode to JPG with 70 quality
    final jpgBytes = img.encodeJpg(resized, quality: 70);
    final filename = file.uri.pathSegments.last.replaceAll('.png', '.jpg');
    final outFile = File('images/$filename');
    await outFile.writeAsBytes(jpgBytes);
    print('Saved ${outFile.path} (Original: ${bytes.length} bytes, Compressed: ${jpgBytes.length} bytes)');
    
    // Delete the original PNG to save space
    await file.delete();
  }
}
