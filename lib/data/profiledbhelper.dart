import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:vaxiorderv1/model/userprofile.dart';

class DBHelper {
  static Future<Database> _db() async {
    return openDatabase(
      join(await getDatabasesPath(), 'profile.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE profile(id TEXT, rolecode TEXT, usercode TEXT, email TEXT, phonenumber TEXT, username TEXT, repcode TEXT, fullname TEXT)',
        );
      },
      version: 1,
    );
  }

  static Future<void> saveProfile(UserProfile profile) async {
    final db = await _db();
    await db.delete('profile');
    await db.insert('profile', profile.toMap());
  }

  static Future<UserProfile?> getProfile() async {
    final db = await _db();
    final List<Map<String, dynamic>> maps = await db.query('profile');
    if (maps.isEmpty) return null;
    return UserProfile.fromJson(maps.first);
  }
}
