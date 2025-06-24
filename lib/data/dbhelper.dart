import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:vaxiorderv1/model/usermodel.dart';

class LocalDatabase {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'local.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
            CREATE TABLE users (
              Id TEXT PRIMARY KEY,
              UserName TEXT,
              repcode TEXT,
              rolecode TEXT,
              userpass TEXT
              )
          ''');
      },
    );
  }

  Future<void> insertUser(User user) async {
    final db = await database;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<User?> getUserByUserName(String userName) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'userName =?',
      whereArgs: [userName],
    );
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }
}
