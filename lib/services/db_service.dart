// Semua fungsi yang berhubungan dengan database SQLite
// Menangani login, register, dan simpan task

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/task_model.dart';

class DBService {
  static Database? _db;

  // Inisialisasi database SQLite
  static Future<Database> initDb() async {
    if (_db != null) return _db!;
    final path = join(await getDatabasesPath(), 'app.db');
    _db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return _db!;
  }

  // Membuat tabel user dan task saat pertama kali install
  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        date TEXT NOT NULL,
        isCompleted INTEGER NOT NULL,
        category TEXT,
        isPinned INTEGER,
        hasReminder INTEGER
      )
    ''');
  }

  // FUNGSI USER
  static Future<int> registerUser(UserModel user) async {
    final db = await initDb();
    return await db.insert('users', user.toMap());
  }

  static Future<UserModel?> login(String username, String password) async {
    final db = await initDb();
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }

  // FUNGSI TASK
  static Future<int> insertTask(TaskModel task) async {
    final db = await initDb();
    return await db.insert('tasks', task.toMap());
  }

  static Future<List<TaskModel>> getAllTasks() async {
  final db = await initDb();

  final List<Map<String, dynamic>> maps = await db.query('tasks');

  return List.generate(maps.length, (i) {
    return TaskModel.fromMap(maps[i]);
  });
}


  static Future<List<TaskModel>> getTasks() async {
    final db = await initDb();
    final List<Map<String, dynamic>> maps =
        await db.query('tasks', orderBy: 'isPinned DESC, date ASC');

    return List.generate(maps.length, (i) => TaskModel.fromMap(maps[i]));
  }

  static Future<int> updateTask(TaskModel task) async {
    final db = await initDb();
    return await db
        .update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  static Future<int> deleteTask(int id) async {
    final db = await initDb();
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

// Ambil task berdasarkan kategori
static Future<List<TaskModel>> getTasksByCategory(String category) async {
  final db = await initDb();

  if (category == 'Semua') {
    return getTasks(); // Panggil fungsi ambil semua task
  }

  final List<Map<String, dynamic>> maps = await db.query(
    'tasks',
    where: 'category = ?',
    whereArgs: [category],
    orderBy: 'isPinned DESC, date ASC',
  );

  return List.generate(maps.length, (i) => TaskModel.fromMap(maps[i]));
}
}
