import 'package:flutter/material.dart';

import '../controllers/todo_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/todo_form.dart';
import '../widgets/todo_tile.dart';

class HomePage extends StatelessWidget {
  /// Menggunakan controller yang sama dengan kalender.
  const HomePage({super.key, required this.controller});
  final TodoController controller;

  /// Menampilkan input, tugas aktif, dan kelompok selesai dalam satu scroll.
  @override
  Widget build(BuildContext context) {
    final todos = controller.todos;
    final firstCompleted = todos.indexWhere((todo) => todo.isCompleted);
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      children: [
        const Text(
          'SATU PER SATU, JADI SELESAI.',
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 1.6,
            color: AppTheme.muted,
          ),
        ),
        const SizedBox(height: 12),
        const Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'Ruang untuk '),
              TextSpan(
                text: 'harimu.',
                style: TextStyle(color: AppTheme.accent),
              ),
            ],
          ),
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.5,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          controller.activeCount == 0
              ? 'Mulai satu hal kecil hari ini.'
              : 'Ada ${controller.activeCount} hal yang menunggu. Yuk, mulai pelan-pelan.',
          style: const TextStyle(fontSize: 12, color: AppTheme.muted),
        ),
        const SizedBox(height: 24),
        TodoForm(controller: controller),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Text(
                'Tugas kamu  ${controller.activeCount}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            TextButton.icon(
              onPressed: controller.cycleSort,
              icon: const Icon(Icons.swap_vert, size: 17),
              label: Text(switch (controller.sort) {
                DeadlineSort.newest => 'Deadline',
                DeadlineSort.nearest => 'Terdekat',
                DeadlineSort.furthest => 'Terjauh',
              }, style: const TextStyle(fontSize: 11)),
            ),
          ],
        ),
        if (todos.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Text(
              'Belum ada tugas. Tambahkan rencana pertamamu.',
              style: TextStyle(color: AppTheme.muted),
            ),
          ),
        for (var i = 0; i < todos.length; i++) ...[
          if (i == firstCompleted)
            const Padding(
              padding: EdgeInsets.only(top: 24, bottom: 8),
              child: Text(
                'SELESAI',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.5,
                  color: AppTheme.muted,
                ),
              ),
            ),
          TodoTile(
            key: ValueKey(todos[i].id),
            todo: todos[i],
            onToggle: () => controller.toggle(todos[i].id),
          ),
        ],
        const Padding(
          padding: EdgeInsets.only(top: 24),
          child: Text(
            'Sedikit progres, setiap hari.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: AppTheme.muted),
          ),
        ),
      ],
    );
  }
}
