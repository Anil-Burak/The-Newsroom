import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../core/extensions/string_extensions.dart';
import '../../gatekeeping/domain/news_item.dart';

class PdfExportService {
  /// Generates a PDF of the newspaper and opens a share/save dialog
  static Future<void> exportAndShareNewspaper({
    required String personaName,
    required List<NewsItem> articles,
    bool isPlayer = false,
  }) async {
    final pdf = pw.Document();

    // Use a font that supports Turkish characters
    final font = await PdfGoogleFonts.loraRegular();
    final fontBold = await PdfGoogleFonts.loraBold();
    final titleFont = await PdfGoogleFonts.playfairDisplayBlack();
    
    // We fetch all network and asset images beforehand so we can use them synchronously in build
    final Map<String, pw.MemoryImage> imageCache = {};
    for (final article in articles) {
      if (article.imageUrl.isNotEmpty) {
        try {
          if (article.imageUrl.startsWith('http')) {
            final imageProvider = await networkImage(article.imageUrl);
            imageCache[article.imageUrl] = imageProvider as pw.MemoryImage;
          } else {
            // Load from assets
            final ByteData data = await rootBundle.load(article.imageUrl);
            final Uint8List bytes = data.buffer.asUint8List();
            imageCache[article.imageUrl] = pw.MemoryImage(bytes);
          }
        } catch (e) {
          // Ignore error, image will just not appear
        }
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        theme: pw.ThemeData.withFont(
          base: font,
          bold: fontBold,
        ),
        build: (pw.Context context) {
          return [
            _buildMasthead(personaName, isPlayer, titleFont, font),
            pw.SizedBox(height: 20),
            if (articles.isEmpty)
              pw.Center(child: pw.Text('Bu editör için seçilen haber bulunmamaktadır.'))
            else ...[
              _buildHeroArticle(articles[0], imageCache, fontBold),
              pw.SizedBox(height: 16),
              ...articles.skip(1).map((a) => _buildFixedArticle(a, fontBold, font)).toList(),
            ]
          ];
        },
      ),
    );

    // Get the generated pdf bytes
    final Uint8List bytes = await pdf.save();

    // Share or save the file
    final filename = isPlayer
        ? 'Senin_Gazeten.pdf'
        : '${personaName.replaceAll(' ', '_')}_Gazetesi.pdf';
        
    await Printing.sharePdf(
      bytes: bytes,
      filename: filename,
    );
  }

  static pw.Widget _buildMasthead(String personaName, bool isPlayer, pw.Font titleFont, pw.Font font) {
    final now = DateTime.now();
    final issueNumber = now.difference(DateTime(now.year, 1, 1)).inDays + 1;

    final dateStr = '${now.day}/${now.month}/${now.year}';
    
    return pw.Column(
      children: [
        pw.Container(height: 3, color: PdfColors.black, width: double.infinity),
        pw.SizedBox(height: 2),
        pw.Container(height: 1, color: PdfColors.black, width: double.infinity),
        pw.SizedBox(height: 6),
        
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(dateStr, style: pw.TextStyle(fontSize: 10, font: font)),
            pw.Text('Fiyatı: ₺2', style: pw.TextStyle(fontSize: 10, font: font)),
            pw.Text('Sayı $issueNumber', style: pw.TextStyle(fontSize: 10, font: font)),
          ],
        ),
        
        pw.SizedBox(height: 4),
        pw.Container(height: 0.5, color: PdfColors.grey, width: double.infinity),
        pw.SizedBox(height: 6),
        
        pw.Text(
          isPlayer
              ? 'SENIN GAZETEN'
              : '${personaName.toUpperCaseTr()} GAZETESI',
          style: pw.TextStyle(
            font: titleFont,
            fontSize: 28,
            fontWeight: pw.FontWeight.bold,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          '« Haber Sizin Elinizde »',
          style: pw.TextStyle(
            fontSize: 10,
            fontStyle: pw.FontStyle.italic,
            color: PdfColors.grey700,
          ),
        ),
        
        pw.SizedBox(height: 6),
        pw.Container(height: 1, color: PdfColors.black, width: double.infinity),
        pw.SizedBox(height: 2),
        pw.Container(height: 3, color: PdfColors.black, width: double.infinity),
      ],
    );
  }

  static pw.Widget _buildHeroArticle(NewsItem article, Map<String, pw.MemoryImage> imageCache, pw.Font fontBold) {
    return pw.Container(
      width: double.infinity,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 0.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          if (article.imageUrl.isNotEmpty && imageCache.containsKey(article.imageUrl))
            pw.ClipRect(
              child: pw.Container(
                height: 200,
                width: double.infinity,
                child: pw.Image(imageCache[article.imageUrl]!, fit: pw.BoxFit.cover),
              ),
            ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(12),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  article.category.toUpperCaseTr(),
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey800,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  article.headline,
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  article.summary,
                  style: pw.TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFixedArticle(NewsItem article, pw.Font fontBold, pw.Font font) {
    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(bottom: 12),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey, width: 0.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            article.category.toUpperCaseTr(),
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            article.headline,
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            article.summary,
            style: pw.TextStyle(fontSize: 11, font: font),
          ),
        ],
      ),
    );
  }
}
