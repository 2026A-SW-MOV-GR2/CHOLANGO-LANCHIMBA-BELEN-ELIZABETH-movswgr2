import 'package:flutter/foundation.dart';
import '../models/item.dart';
import '../repositories/i_item_repository.dart';
import '../repositories/sqlite_item_repository.dart';
import '../repositories/hive_item_repository.dart';
import '../utils/app_logger.dart';

enum StorageMode { sqlite, hive }

class StorageProvider extends ChangeNotifier {
  StorageMode _mode = StorageMode.sqlite;
  List<Item> _items = [];
  bool _loading = false;

  StorageMode get mode => _mode;
  List<Item> get items => _items;
  bool get loading => _loading;

  IItemRepository get _repo => _mode == StorageMode.sqlite
      ? SqliteItemRepository()
      : HiveItemRepository();

  Future<void> switchMode(StorageMode newMode) async {
    if (_mode == newMode) return;
    AppLogger.info('Conmutando motor: $_mode → $newMode');
    _mode = newMode;
    await loadItems();
  }

  Future<void> loadItems() async {
    _loading = true;
    notifyListeners();
    try {
      _items = await _repo.getAll();
      AppLogger.debug('Provider: ${_items.length} items cargados desde $_mode');
    } catch (e) {
      AppLogger.error('Provider: error al cargar items → $e');
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> addItem(String title, String desc) async {
    await _repo.insert(Item(title: title, description: desc));
    await loadItems();
  }

  Future<void> editItem(Item item) async {
    await _repo.update(item);
    await loadItems();
  }

  Future<void> removeItem(int id) async {
    await _repo.delete(id);
    await loadItems();
  }
}