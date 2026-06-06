import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/storage_provider.dart';
import 'item_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final sp = context.watch<StorageProvider>();
    final isSqlite = sp.mode == StorageMode.sqlite;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Border List'),
        // ✅ CHIP INDICADOR DE ORIGEN ACTIVO
        actions: [
          Chip(
            label: Text(
              isSqlite ? 'SQLite' : 'NoSQL',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: isSqlite ? Colors.blue[100] : Colors.orange[100],
          ),
          const SizedBox(width: 8),
          // ✅ SWITCH EN APP BAR
          Switch(
            value: !isSqlite,
            onChanged: (val) => context
                .read<StorageProvider>()
                .switchMode(val ? StorageMode.hive : StorageMode.sqlite),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: sp.loading
          ? const Center(child: CircularProgressIndicator())
          : sp.items.isEmpty
          ? Center(
        child: Text(
          'Sin registros en ${isSqlite ? "SQLite" : "Hive"}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      )
          : ListView.builder(
        itemCount: sp.items.length,
        itemBuilder: (ctx, i) {
          final item = sp.items[i];
          return ListTile(
            leading: Icon(
              isSqlite ? Icons.table_rows : Icons.folder_open,
              color: isSqlite ? Colors.blue : Colors.orange,
            ),
            title: Text(item.title),
            subtitle: Text(item.description),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ItemFormScreen(item: item),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () =>
                      context.read<StorageProvider>().removeItem(item.id!),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ItemFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}