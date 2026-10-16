import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/todo.dart';

/// Kontrak penyimpanan agar state mudah diuji tanpa platform native.
abstract class TodoRepository {
  /// Membaca seluruh tugas; melempar error bila penyimpanan gagal.
  Future<List<Todo>> load();

  /// Menyimpan satu snapshot tugas secara utuh.
  Future<void> save(List<Todo> todos);
}

class PreferencesTodoRepository implements TodoRepository {
  static const _key = 'daylist.todos.v1';

  /// Memuat JSON tanpa menimpa data bila decoding gagal.
  @override
  Future<List<Todo>> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_key);
    if (raw == null) return [];
    return (jsonDecode(raw) as List<dynamic>)
        .map((item) => Todo.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Memastikan kegagalan tulis dilaporkan ke pemanggil.
  @override
  Future<void> save(List<Todo> todos) async {
    final preferences = await SharedPreferences.getInstance();
    final success = await preferences.setString(
      _key,
      jsonEncode(todos.map((todo) => todo.toJson()).toList()),
    );
    if (!success) throw StateError('Penyimpanan gagal');
  }
}
