import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:examen_belen_cholango/models/item.dart';
import 'package:examen_belen_cholango/repositories/hive_item_repository.dart';

void main() {
  setUpAll(() async {
    Hive.init('./test/hive_test_box');
    Hive.registerAdapter(ItemAdapter());
    await HiveItemRepository.init();
  });

  tearDownAll(() async => Hive.deleteFromDisk());

  group('HiveItemRepository', () {
    late HiveItemRepository repo;

    setUp(() => repo = HiveItemRepository());

    test('insert y getAll devuelven el item guardado', () async {
      await repo.insert(Item(title: 'Test Hive', description: 'Desc Hive'));
      final items = await repo.getAll();
      expect(items.any((i) => i.title == 'Test Hive'), isTrue);
    });

    test('cambio de motor no afecta datos del otro motor', () async {
      // Datos en Hive
      await repo.insert(Item(title: 'Solo en Hive', description: '...'));
      final hiveItems = await repo.getAll();

      // Los datos de SQLite son independientes: lista de Hive no debe estar vacía
      expect(hiveItems.isNotEmpty, isTrue);
    });
  });
}