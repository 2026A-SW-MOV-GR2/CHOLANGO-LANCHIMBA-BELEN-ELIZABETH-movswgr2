import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/item.dart';
import '../utils/app_logger.dart';
import 'i_item_repository.dart';

class SqliteItemRepository implements IItemRepository {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'items.db');
    AppLogger.info('SQLite: abriendo base de datos en $path');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        AppLogger.debug('SQLite: creando tabla items');
        await db.execute('''
          CREATE TABLE items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT NOT NULL
          )
        ''');
      },
    );
  }

  @override
  Future<List<Item>> getAll() async {
    final db = await database;
    final maps = await db.query('items');
    AppLogger.debug('SQLite: getAll() → ${maps.length} registros');
    return maps.map(Item.fromMap).toList();
  }

  @override
  Future<void> insert(Item item) async {
    final db = await database;
    final id = await db.insert('items', item.toMap()..remove('id'));
    AppLogger.info('SQLite: insert() → id=$id title="${item.title}"');
  }

  @override
  Future<void> update(Item item) async {
    final db = await database;
    await db.update('items', item.toMap(),
        where: 'id = ?', whereArgs: [item.id]);
    AppLogger.info('SQLite: update() → id=${item.id}');
  }

  @override
  Future<void> delete(int id) async {
    final db = await database;
    await db.delete('items', where: 'id = ?', whereArgs: [id]);
    AppLogger.info('SQLite: delete() → id=$id');
  }
}