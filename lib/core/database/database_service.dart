import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'seed_data.dart';

/// Singleton SQLite database service.
/// Call [init] once at app startup, then use [database] everywhere.
class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  static Database? _db;

  Database get database {
    assert(_db != null, 'DatabaseService.init() must be called first.');
    return _db!;
  }

  Future<void> init() async {
    if (_db != null) return;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'gatekeeper.db');

    _db = await openDatabase(
      path,
      version: 6,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    // Varsayılan personaların güncellemelerinin (önceden kurulmuş veritabanlarında da) yansıması için:
    final batch = _db!.batch();
    for (final persona in kSeedPersonas) {
      batch.insert('personas', persona,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  // ─── Schema ───────────────────────────────────────────────────────────────
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS news_pool');
    await db.execute('DROP TABLE IF EXISTS personas');
    await _onCreate(db, newVersion);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE news_pool (
        id                 TEXT PRIMARY KEY,
        headline           TEXT NOT NULL,
        summary            TEXT NOT NULL,
        imageUrl           TEXT NOT NULL DEFAULT '',
        category           TEXT NOT NULL,
        sensationalismScore INTEGER NOT NULL DEFAULT 0,
        biasIndex          INTEGER NOT NULL DEFAULT 0,
        tags               TEXT NOT NULL DEFAULT '[]'
      )
    ''');

    await db.execute('''
      CREATE TABLE personas (
        id                  TEXT PRIMARY KEY,
        name                TEXT NOT NULL,
        description         TEXT NOT NULL,
        iconEmoji           TEXT NOT NULL DEFAULT '📰',
        isDefault           INTEGER NOT NULL DEFAULT 0,
        sortOrder           INTEGER NOT NULL DEFAULT 99,
        bias                TEXT NOT NULL DEFAULT '',
        ethics              TEXT NOT NULL DEFAULT '',
        clickbaitThreshold  INTEGER NOT NULL DEFAULT 50
      )
    ''');

    await _seed(db);
  }

  // ─── Seed ─────────────────────────────────────────────────────────────────
  Future<void> _seed(Database db) async {
    final batch = db.batch();

    for (final persona in kSeedPersonas) {
      batch.insert('personas', persona,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    for (final news in kSeedNewsPool) {
      final newsMap = Map<String, dynamic>.from(news);
      if (newsMap['tags'] is List) {
        newsMap['tags'] = jsonEncode(newsMap['tags']);
      }
      batch.insert('news_pool', newsMap,
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    await batch.commit(noResult: true);
  }
}
