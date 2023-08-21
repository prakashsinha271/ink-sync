import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {

  static final tableNotes = 'notes'; // Replace with your actual table name
  static final columnId = 'id';


  static final DatabaseHelper _instance = DatabaseHelper._();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'ink_sync.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            content TEXT,
            date TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertNote({
    required String title,
    required String content,
    required String date,
  }) async {
    final db = await database;
    await db.insert(
      'notes',
      {
        'title': title,
        'content': content,
        'date': date,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getNotes() async {
    final db = await database;
    return await db.query('notes');
  }

  Future<void> updateNote({
    required int id,
    required String title,
    required String content,
    required String date,
  }) async {
    final db = await database;
    await db.update(
      'notes',
      {
        'title': title,
        'content': content,
        'date': date,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteNote(int id) async {
    final db = await database;
    await db.delete(tableNotes, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> getNotesCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM $tableNotes');
    final count = Sqflite.firstIntValue(result);
    return count ?? 0;
  }
}
