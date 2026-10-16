import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/app.dart';
import 'package:todo_app/controllers/todo_controller.dart';
import 'package:todo_app/data/todo_repository.dart';
import 'package:todo_app/models/todo.dart';

class MemoryRepository implements TodoRepository {
  List<Todo> data = [];
  bool failSave = false;
  bool failLoad = false;

  /// Mengembalikan snapshot untuk menguji state tanpa plugin platform.
  @override
  Future<List<Todo>> load() async {
    if (failLoad) throw StateError('read failed');
    return List.of(data);
  }

  /// Menyimulasikan persistensi dan kegagalan penyimpanan.
  @override
  Future<void> save(List<Todo> todos) async {
    if (failSave) throw StateError('write failed');
    data = List.of(todos);
  }
}

/// Memverifikasi alur utama dan konsistensi state lintas halaman.
void main() {
  test('Sorting, toggle, serialisasi, dan persistensi', () async {
    final repository = MemoryRepository();
    final controller = TodoController(repository);
    await controller.initialize();
    await controller.add(' Tanpa tanggal ', '', null);
    await controller.add('Dekat', ' Catatan ', DateTime(2026, 10, 16, 15));
    await controller.add('Jauh', '', DateTime(2026, 10, 20));
    controller.cycleSort();
    expect(controller.todos.map((t) => t.title), [
      'Dekat',
      'Jauh',
      'Tanpa tanggal',
    ]);
    final first = controller.todos.first;
    await controller.toggle(first.id);
    expect(controller.todos.last.id, first.id);
    expect(controller.history.single.title, 'Dekat');
    expect(controller.forDate(DateTime(2026, 10, 16)).single.deadline!.hour, 0);
    controller.cycleSort();
    expect(controller.todos.first.title, 'Jauh');
    expect(controller.todos.last.id, first.id);
    final restored = Todo.fromJson(controller.todos.last.toJson());
    expect(restored.isCompleted, isTrue);
    expect(restored.description, 'Catatan');
    await controller.toggle(first.id);
    expect(controller.history, isEmpty);
    final reopened = TodoController(repository);
    await reopened.initialize();
    expect(reopened.todos.length, 3);
    controller.dispose();
    reopened.dispose();
  });

  test('Gagal simpan bisa diulang; gagal baca tidak menimpa data', () async {
    final repository = MemoryRepository();
    final controller = TodoController(repository);
    await controller.initialize();
    repository.failSave = true;
    await controller.add('Tetap di memori', '', null);
    expect(controller.error, isNotNull);
    expect(controller.todos.length, 1);
    repository.failSave = false;
    await controller.retrySave();
    expect(controller.error, isNull);
    repository.failLoad = true;
    final blocked = TodoController(repository);
    await blocked.initialize();
    await blocked.add('Jangan timpa', '', null);
    expect(repository.data.single.title, 'Tetap di memori');
    controller.dispose();
    blocked.dispose();
  });

  testWidgets('Validasi, tambah, centang, dan riwayat pada layar kecil', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = TodoController(MemoryRepository());
    await controller.initialize();
    await tester.pumpWidget(TodoApp(controller: controller));
    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();
    expect(find.text('Judul wajib diisi.'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'Belajar Flutter');
    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();
    expect(find.text('Belajar Flutter'), findsOneWidget);
    await tester.ensureVisible(find.byType(Checkbox).first);
    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
    expect(controller.history.single.title, 'Belajar Flutter');
    await tester.tap(find.text('Kalender & Riwayat'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Riwayat selesai'));
    await tester.pumpAndSettle();
    expect(find.text('Belajar Flutter'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  });
}
