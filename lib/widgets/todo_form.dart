import 'package:flutter/material.dart';

import '../controllers/todo_controller.dart';
import '../theme/app_theme.dart';

class TodoForm extends StatefulWidget {
  /// Menghubungkan input lokal dengan state tugas bersama.
  const TodoForm({super.key, required this.controller});
  final TodoController controller;

  /// Membuat state untuk input dan tanggal opsional.
  @override
  State<TodoForm> createState() => _TodoFormState();
}

class _TodoFormState extends State<TodoForm> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  DateTime? _deadline;

  /// Membebaskan controller input ketika form dihapus.
  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  /// Menolak judul kosong termasuk teks yang hanya berisi spasi.
  String? _validateTitle(String? value) =>
      value == null || value.trim().isEmpty ? 'Judul wajib diisi.' : null;

  /// Membuka date picker Indonesia dan menjaga keamanan setelah await.
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(9999, 12, 31),
    );
    if (mounted && result != null) setState(() => _deadline = result);
  }

  /// Memasukkan tugas segera, membersihkan form, lalu menunggu penyimpanan.
  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.controller.add(_title.text, _description.text, _deadline);
    _title.clear();
    _description.clear();
    setState(() => _deadline = null);
    FocusScope.of(context).unfocus();
  }

  /// Membangun form responsif dengan deadline yang bisa dihapus.
  @override
  Widget build(BuildContext context) => Form(
    key: _formKey,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9EBF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _title,
            validator: _validateTitle,
            maxLength: 160,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            decoration: const InputDecoration(
              labelText: 'Judul tugas',
              hintText: 'Apa yang mau kamu selesaikan?',
              counterText: '',
            ),
          ),
          TextField(
            controller: _description,
            minLines: 1,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(fontSize: 12),
            decoration: const InputDecoration(labelText: 'Catatan (opsional)'),
          ),
          const Divider(),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TextButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today_outlined, size: 16),
                label: Text(
                  _deadline == null
                      ? 'Deadline (opsional)'
                      : MaterialLocalizations.of(context)
                            .formatShortDate(_deadline!),
                  style: const TextStyle(fontSize: 11),
                ),
              ),
              if (_deadline != null)
                IconButton(
                  tooltip: 'Hapus deadline',
                  onPressed: () => setState(() => _deadline = null),
                  icon: const Icon(Icons.close, size: 17),
                ),
              FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tambah'),
              ),
            ],
          ),
          const Text(
            'Satu langkah lebih dekat.',
            style: TextStyle(fontSize: 10, color: AppTheme.muted),
          ),
        ],
      ),
    ),
  );
}
