import 'package:flutter/material.dart';

import '../models/todo.dart';
import '../theme/app_theme.dart';

class TodoTile extends StatelessWidget {
  /// Menampilkan tugas bersama callback status dari pemilik state.
  const TodoTile({super.key, required this.todo, required this.onToggle});
  final Todo todo;
  final VoidCallback onToggle;

  /// Merender checkbox, catatan, serta deadline tanpa mengubah model.
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: Checkbox(
                semanticLabel: todo.title,
                value: todo.isCompleted,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                onChanged: (_) => onToggle(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todo.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: todo.isCompleted ? AppTheme.muted : null,
                      decoration: todo.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  if (todo.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        todo.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.muted,
                        ),
                      ),
                    ),
                  if (todo.deadline != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.pale,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          '◷ ${MaterialLocalizations.of(context).formatShortDate(todo.deadline!)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.accent,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      const Divider(height: 1),
    ],
  );
}
