import 'package:hive/hive.dart';

part 'item.g.dart';

@HiveType(typeId: 0)
class Item extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  Item({this.id, required this.title, required this.description});

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
  };

  factory Item.fromMap(Map<String, dynamic> map) => Item(
    id: map['id'],
    title: map['title'],
    description: map['description'],
  );
}