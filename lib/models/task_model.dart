// Model data Task yang disimpan user
class TaskModel {
  int? id;
  String title;
  DateTime date;
  bool isCompleted;
  String category;
  bool? isPinned;
  bool hasReminder;

  TaskModel({
    this.id,
    required this.title,
    required this.date,
    required this.isCompleted,
    required this.category,
    required this.isPinned,
    required this.hasReminder,
  });

  // Convert objek ke Map untuk disimpan ke SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(), // Simpan sebagai ISO string
      'isCompleted': isCompleted ? 1 : 0,
      'category': category,
      'isPinned': isPinned == true ? 1 : 0,
      'hasReminder': hasReminder == true ? 1 : 0,
    };
  }

  // Convert dari Map SQLite ke objek TaskModel
  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'],
      title: map['title'],
      date: DateTime.parse(map['date']), // Parse ISO string ke DateTime
      isCompleted: map['isCompleted'] == 1,
      category: map['category'] ?? '',
      isPinned: (map['isPinned'] ?? 0) == 1,
      hasReminder: (map['hasReminder'] ?? 0) == 1,
    );
  }

  TaskModel copyWith({
    int? id,
    String? title,
    DateTime? date,
    bool? isCompleted,
    String? category,
    bool? isPinned,
    bool? hasReminder,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
      isPinned: isPinned ?? this.isPinned,
      hasReminder: hasReminder ?? this.hasReminder,
    );
  }
}
