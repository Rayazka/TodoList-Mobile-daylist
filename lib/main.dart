import 'package:flutter/material.dart';

import 'app.dart';
import 'controllers/todo_controller.dart';
import 'data/todo_repository.dart';

/// Menyiapkan binding platform, memuat data, lalu menjalankan Daylist.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = TodoController(PreferencesTodoRepository());
  runApp(TodoApp(controller: controller));
  controller.initialize();
}
