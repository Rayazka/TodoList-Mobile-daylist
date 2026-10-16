/// Tugas immutable; deadline selalu berupa tanggal lokal tanpa jam.
class Todo {
  /// Membuat tugas baru dengan identitas dan waktu pencatatan tetap.
  const Todo({
    required this.id,
    required this.title,
    required this.createdAt,
    this.description = '',
    this.deadline,
    this.completedAt,
  });
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? deadline;
  final DateTime? completedAt;
  /// Menentukan status dari waktu selesai agar tidak ada dua sumber status.
  bool get isCompleted => completedAt != null;

  /// Mengganti status tanpa mengubah objek asli.
  Todo toggle(DateTime now) => Todo(
    id: id,
    title: title,
    description: description,
    createdAt: createdAt,
    deadline: deadline,
    completedAt: isCompleted ? null : now,
  );

  /// Mengubah tugas menjadi data yang dapat disimpan sebagai JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
    'deadline': deadline?.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
  };

  /// Membaca tugas tersimpan; data rusak diteruskan sebagai kegagalan baca.
  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String? ?? '',
    createdAt: DateTime.parse(json['createdAt'] as String),
    deadline: json['deadline'] == null
        ? null
        : DateTime.parse(json['deadline'] as String),
    completedAt: json['completedAt'] == null
        ? null
        : DateTime.parse(json['completedAt'] as String),
  );
}
