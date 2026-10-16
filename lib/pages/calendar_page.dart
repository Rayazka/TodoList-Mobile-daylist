import 'package:flutter/material.dart';

import '../controllers/todo_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/todo_tile.dart';

class CalendarPage extends StatefulWidget {
  /// Memakai deadline dan riwayat dari state Home.
  const CalendarPage({super.key, required this.controller});
  final TodoController controller;

  /// Mempertahankan bulan dan tab ketika berpindah halaman.
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selected = DateUtils.dateOnly(DateTime.now());
  late DateTime _month = DateTime(_selected.year, _selected.month);
  bool _history = false;
  static const _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  /// Menangani pergantian bulan dan tahun melalui normalisasi DateTime.
  void _moveMonth(int offset) {
    final next = DateTime(_month.year, _month.month + offset);
    if (next.year < 1900 || next.year > 9999) return;
    setState(() {
      _month = next;
      _selected = next;
    });
  }

  /// Memilih tanggal dan langsung menampilkan agendanya.
  void _selectDate(DateTime date) => setState(() {
    _selected = date;
    _history = false;
  });

  /// Membangun kalender Senin–Minggu dengan indikator tugas dan hari ini.
  Widget _buildCalendar() {
    final offset = _month.weekday - 1;
    final days = DateTime(_month.year, _month.month + 1, 0).day;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
      ),
      itemCount: offset + days,
      itemBuilder: (context, index) {
        if (index < offset) return const SizedBox.shrink();
        final date = DateTime(_month.year, _month.month, index - offset + 1);
        final selected = DateUtilsLocal.sameDay(date, _selected);
        final today = DateUtilsLocal.sameDay(date, DateTime.now());
        final hasTasks = widget.controller.forDate(date).isNotEmpty;
        return Semantics(
          selected: selected,
          label: MaterialLocalizations.of(context).formatFullDate(date),
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Material(
              color: selected ? AppTheme.accent : Colors.transparent,
              shape: CircleBorder(
                side: today && !selected
                    ? const BorderSide(color: AppTheme.accent)
                    : BorderSide.none,
              ),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => _selectDate(date),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        fontSize: 12,
                        color: selected ? Colors.white : null,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hasTasks
                            ? (selected ? Colors.white : AppTheme.accent)
                            : Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Menampilkan agenda tanggal terpilih atau seluruh riwayat selesai.
  @override
  Widget build(BuildContext context) {
    final items = _history
        ? widget.controller.history
        : widget.controller.forDate(_selected);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _months[_month.month - 1].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    '${_month.year}',
                    style: const TextStyle(
                      color: AppTheme.muted,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Bulan sebelumnya',
              onPressed: () => _moveMonth(-1),
              icon: const Icon(Icons.chevron_left),
            ),
            IconButton(
              tooltip: 'Bulan berikutnya',
              onPressed: () => _moveMonth(1),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            for (final day in ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'])
              Expanded(
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: AppTheme.muted),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        _buildCalendar(),
        const SizedBox(height: 20),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('Agenda')),
            ButtonSegment(value: true, label: Text('Riwayat selesai')),
          ],
          selected: {_history},
          onSelectionChanged: (selection) =>
              setState(() => _history = selection.first),
        ),
        const SizedBox(height: 24),
        Text(
          _history
              ? 'SEMUA TUGAS SELESAI'
              : MaterialLocalizations.of(context).formatFullDate(_selected),
          style: const TextStyle(fontSize: 11, color: AppTheme.muted),
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              _history
                  ? 'Belum ada tugas selesai. Setiap langkah kecil tetap berarti.'
                  : 'Tidak ada deadline di tanggal ini. Ruang kosong untuk rencana baru.',
              style: const TextStyle(color: AppTheme.muted, height: 1.7),
            ),
          ),
        for (final todo in items)
          TodoTile(
            key: ValueKey(todo.id),
            todo: todo,
            onToggle: () => widget.controller.toggle(todo.id),
          ),
      ],
    );
  }
}
