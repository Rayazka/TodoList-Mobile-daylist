import 'package:flutter/foundation.dart';

import '../data/todo_repository.dart';
import '../models/todo.dart';

enum DeadlineSort { newest, nearest, furthest }

/// Satu sumber state untuk Home, kalender, dan riwayat.
class TodoController extends ChangeNotifier {
  /// Menerima repository agar logika tidak bergantung pada UI/platform.
  TodoController(this._repository);
  final TodoRepository _repository;
  List<Todo> _todos = [];
  bool isLoading = true;
  bool loadFailed = false;
  String? error;
  DeadlineSort sort = DeadlineSort.newest;
  Future<void> _pendingSave = Future.value();
  bool _disposed = false;
  int _sequence = 0;
  /// Menghitung tugas yang belum selesai untuk ringkasan Home.
  int get activeCount => _todos.where((todo) => !todo.isCompleted).length;

  /// Mengembalikan salinan terurut agar UI tidak dapat mengubah state.
  List<Todo> get todos =>
      List<Todo>.unmodifiable(<Todo>[..._todos]..sort(_compare));

  /// Mengurutkan riwayat berdasarkan waktu selesai terbaru.
  List<Todo> get history =>
      _todos.where((todo) => todo.isCompleted).toList()
        ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));

  /// Memuat tugas dan memblokir mutasi bila data gagal dibaca.
  Future<void> initialize() async {
    isLoading = true;
    error = null;
    _emit();
    try {
      _todos = await _repository.load();
      loadFailed = false;
    } catch (_) {
      loadFailed = true;
      error =
          'Data belum bisa dibaca. Coba muat ulang agar data lama tetap aman.';
    }
    isLoading = false;
    _emit();
  }

  /// Menambahkan judul tervalidasi, lalu menyimpan snapshot terbaru.
  Future<void> add(String title, String description, DateTime? deadline) async {
    if (isLoading || loadFailed) return;
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) throw ArgumentError('Judul wajib diisi');
    final now = DateTime.now();
    _todos.add(
      Todo(
        id: '${now.microsecondsSinceEpoch}-${_sequence++}',
        title: cleanTitle,
        description: description.trim(),
        createdAt: now,
        deadline: deadline == null
            ? null
            : DateTime(deadline.year, deadline.month, deadline.day),
      ),
    );
    _emit();
    await _save();
  }

  /// Toggle selalu memakai data terbaru, lalu memberi tahu kedua halaman.
  Future<void> toggle(String id) async {
    if (isLoading || loadFailed) return;
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index < 0) return;
    _todos[index] = _todos[index].toggle(DateTime.now());
    _emit();
    await _save();
  }

  /// Beralih antara urutan baru, deadline terdekat, dan terjauh.
  void cycleSort() {
    sort = DeadlineSort.values[(sort.index + 1) % DeadlineSort.values.length];
    _emit();
  }

  /// Menyaring deadline berdasarkan tanggal lokal, termasuk tugas selesai.
  List<Todo> forDate(DateTime date) => todos
      .where(
        (todo) =>
            todo.deadline != null &&
            DateUtilsLocal.sameDay(todo.deadline!, date),
      )
      .toList();

  /// Mempertahankan tugas selesai di bawah dan tanpa deadline di akhir kelompok.
  int _compare(Todo a, Todo b) {
    if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
    if (sort != DeadlineSort.newest) {
      if (a.deadline == null && b.deadline != null) return 1;
      if (a.deadline != null && b.deadline == null) return -1;
      if (a.deadline != null && b.deadline != null) {
        final result = a.deadline!.compareTo(b.deadline!);
        if (result != 0) return sort == DeadlineSort.nearest ? result : -result;
      }
    }
    return b.createdAt.compareTo(a.createdAt);
  }

  /// Menyimpan secara berantai agar penulisan cepat tidak saling menimpa.
  Future<void> _save() {
    final snapshot = List<Todo>.of(_todos);
    _pendingSave = _pendingSave.then((_) async {
      try {
        await _repository.save(snapshot);
        error = null;
      } catch (_) {
        error = 'Perubahan belum tersimpan. Coba simpan lagi.';
      }
      _emit();
    });
    return _pendingSave;
  }

  /// Mengulangi penyimpanan data yang masih aman berada di memori.
  Future<void> retrySave() => _save();

  /// Menghindari notifikasi setelah pemilik controller ditutup.
  void _emit() {
    if (!_disposed) notifyListeners();
  }

  /// Melepaskan listener tanpa menghentikan penulisan yang sedang berjalan.
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

abstract final class DateUtilsLocal {
  /// Membandingkan tanggal tanpa terpengaruh komponen jam.
  static bool sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
