import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_service.dart';
import '../../persona_selection/domain/persona.dart';

abstract class PersonaRepository {
  Future<List<Persona>> fetchDefaultPersonas();
  Future<void> saveCustomPersona(Persona persona);
  Future<void> deleteCustomPersona(String personaId);
}

class SQLitePersonaRepository implements PersonaRepository {
  final DatabaseService _dbService;

  SQLitePersonaRepository({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService.instance;

  @override
  Future<List<Persona>> fetchDefaultPersonas() async {
    final rows = await _dbService.database.query(
      'personas',
      orderBy: 'sortOrder ASC',
    );
    return rows.map(Persona.fromMap).toList();
  }

  @override
  Future<void> saveCustomPersona(Persona persona) async {
    await _dbService.database.insert(
      'personas',
      persona.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteCustomPersona(String personaId) async {
    await _dbService.database.delete(
      'personas',
      where: 'id = ?',
      whereArgs: [personaId],
    );
  }
}
