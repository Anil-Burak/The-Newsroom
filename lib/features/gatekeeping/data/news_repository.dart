import '../../../core/database/database_service.dart';
import '../domain/news_item.dart';

abstract class NewsRepository {
  Future<List<NewsItem>> fetchNewsPool();
}

class SQLiteNewsRepository implements NewsRepository {
  final DatabaseService _dbService;

  SQLiteNewsRepository({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService.instance;

  @override
  Future<List<NewsItem>> fetchNewsPool() async {
    final rows = await _dbService.database.query('news_pool');
    final items = rows.map(NewsItem.fromMap).toList();
    items.shuffle();
    return items;
  }
}
