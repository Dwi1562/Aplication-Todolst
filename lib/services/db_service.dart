import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:todolist_ukk/models/user_model.dart';


class DBService {
  static Database? _db;

  static Future<Database> initDb() async {
    if (_db != null) return _db!;
    final path = join(await getDatabasesPath(), 'app.db');
    _db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return _db!;
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        password TEXT NOT NULL
      )
    ''');
  }

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
}
