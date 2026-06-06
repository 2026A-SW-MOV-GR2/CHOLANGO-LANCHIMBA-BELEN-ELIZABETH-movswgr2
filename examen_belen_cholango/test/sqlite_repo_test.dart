import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:examen_belen_cholango/repositories/sqlite_item_repository.dart';
import 'package:examen_belen_cholango/models/item.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('SqliteItemRepository', () {
    late SqliteItemRepository repo;

    setUp(() => repo = SqliteItemRepository());

    test('insert y getAll devuelven el item guardado', () async {
      await repo.insert(Item(title: 'Test SQL', description: 'Desc SQL'));
      final items = await repo.getAll();
      expect(items.any((i) => i.title == 'Test SQL'), isTrue);
    });

    test('delete elimina el item correctamente', () async {
      await repo.insert(Item(title: 'Borrar', description: '...'));
      final before = await repo.getAll();
      final target = before.firstWhere((i) => i.title == 'Borrar');
      await repo.delete(target.id!);
      final after = await repo.getAll();
      expect(after.any((i) => i.title == 'Borrar'), isFalse);
    });
  });
}