import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final dir = Directory('images');
  if (!dir.existsSync()) {
    print('images directory not found.');
    return;
  }
  
  final files = dir.listSync();
  int totalOriginalSize = 0;
  int totalNewSize = 0;

  for (final file in files) {
    if (file is File) {
      if (file.path.endsWith('ikon.png')) {
        print('Skipping ${file.path} as it is the app icon.');
        continue;
      }
      
      final isPng = file.path.endsWith('.png');
      final isJpg = file.path.endsWith('.jpg') || file.path.endsWith('.jpeg');
      
      if (isPng || isJpg) {
        try {
          totalOriginalSize += file.lengthSync();
          final imageBytes = file.readAsBytesSync();
          final image = img.decodeImage(imageBytes);
          
          if (image != null) {
            img.Image resized = image;
            // Resize if it's too large to save space
            if (image.width > 800) {
              resized = img.copyResize(image, width: 800);
            }
            
            // Encode as JPG with quality 70
            final jpgData = img.encodeJpg(resized, quality: 70);
            
            String newPath;
            if (isPng) {
              newPath = file.path.replaceAll('.png', '.jpg');
            } else {
              newPath = file.path;
            }
            
            File(newPath).writeAsBytesSync(jpgData);
            totalNewSize += jpgData.length;
            
            if (isPng) {
              print('Converted and compressed ${file.path} to $newPath');
              file.deleteSync();
            } else {
              print('Compressed ${file.path}');
            }
          }
        } catch (e) {
          print('Error processing ${file.path}: $e');
        }
      }
    }
  }
  
  print('Compression complete.');
  print('Original size: \${(totalOriginalSize / 1024 / 1024).toStringAsFixed(2)} MB');
  print('New size: \${(totalNewSize / 1024 / 1024).toStringAsFixed(2)} MB');
  print('Saved: \${((totalOriginalSize - totalNewSize) / 1024 / 1024).toStringAsFixed(2)} MB');
}
