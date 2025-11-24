import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class UrlHistory {
  final int? id;
  final String url;
  final DateTime timestamp;

  UrlHistory({this.id, required this.url, required this.timestamp});

  Map<String, dynamic> toMap() {
    return {'id': id, 'url': url, 'timestamp': timestamp.toIso8601String()};
  }

  factory UrlHistory.fromMap(Map<String, dynamic> map) {
    return UrlHistory(
      id: map['id'] as int?,
      url: map['url'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('url_history.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE url_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        url TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertUrl(UrlHistory urlHistory) async {
    final db = await database;
    return await db.insert('url_history', urlHistory.toMap());
  }

  Future<List<UrlHistory>> getAllUrls() async {
    final db = await database;
    final result = await db.query('url_history', orderBy: 'timestamp DESC');

    return result.map((map) => UrlHistory.fromMap(map)).toList();
  }

  Future<int> deleteUrl(int id) async {
    final db = await database;
    return await db.delete('url_history', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> clearAllHistory() async {
    final db = await database;
    return await db.delete('url_history');
  }

  Future close() async {
    final db = await database;
    await db.close();
  }
}
