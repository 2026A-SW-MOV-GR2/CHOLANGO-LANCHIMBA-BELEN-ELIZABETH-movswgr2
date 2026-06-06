import 'package:hive/hive.dart';
import '../models/item.dart';
import '../utils/app_logger.dart';
import 'i_item_repository.dart';

class HiveItemRepository implements IItemRepository {
  static const _boxName = 'items_box';

  Box<Item> get _box => Hive.box<Item>(_boxName);

  static Future<void> init() async {
    AppLogger.info('Hive: abriendo box "$_boxName"');
    await Hive.openBox<Item>(_boxName);
  }

  @override
  Future<List<Item>> getAll() async {
    final items = _box.values.toList();
    AppLogger.debug('Hive: getAll() → ${items.length} registros');
    return items;
  }

  @override
  Future<void> insert(Item item) async {
    final key = await _box.add(item);
    item.id = key;
    AppLogger.info('Hive: insert() → key=$key title="${item.title}"');
  }

  @override
  Future<void> update(Item item) async {
    await _box.put(item.id, item);
    AppLogger.info('Hive: update() → key=${item.id}');
  }

  @override
  Future<void> delete(int id) async {
    await _box.delete(id);
    AppLogger.info('Hive: delete() → key=$id');
  }
}