import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

part 'main.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open([EntitySchema], directory: dir.path);
  runApp(MyApp(isar: isar));
}

@freezed
class Entity with _$Entity {
  const factory Entity({
    required int id,
    required String name,
  }) = _Entity;
}

@collection
class EntitySchema {
  Id id = Isar.autoIncrement;
  late String name;
}

class MyApp extends StatelessWidget {
  final Isar isar;
  const MyApp({super.key, required this.isar});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo App',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: HomePage(isar: isar),
    );
  }
}

class HomePage extends StatefulWidget {
  final Isar isar;
  const HomePage({super.key, required this.isar});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<EntitySchema> items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await widget.isar.entitySchemas.where().findAll();
    setState(() => items = data);
  }

  Future<void> _add() async {
    final entity = EntitySchema()..name = 'Item ${DateTime.now().millisecondsSinceEpoch}';
    await widget.isar.writeTxn(() async {
      await widget.isar.entitySchemas.put(entity);
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demo App')),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, i) => ListTile(title: Text(items[i].name)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        child: const Icon(Icons.add),
      ),
    );
  }
}
