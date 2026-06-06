import '../models/item.dart';

abstract class IItemRepository {
  Future<List<Item>> getAll();
  Future<void> insert(Item item);
  Future<void> update(Item item);
  Future<void> delete(int id);
}