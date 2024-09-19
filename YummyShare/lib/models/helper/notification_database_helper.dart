// Importing necessary packages for SQLite database operations and path manipulation
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:yummyshare/models/core/notification_item.dart';

// Class to manage a local SQLite database for storing notifications
class Notification_DB_helper {
  // Instance of the SQLite database
  Database? _database;

  // Table name for notifications in the SQLite database
  String tableName = "notifications";

  // Getter for the database instance, initializing if necessary
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  // Asynchronous method to initialize the SQLite database
  Future<Database> initDatabase() async {
    final path = join(await getDatabasesPath(), 'notification_database.db');
    return openDatabase(
      path,
      version: 1,
      onOpen: (db) async {
        // Check if the table exists
        bool tableExists = await doesTableExist(db, tableName);

        if (!tableExists) {
          // If the table doesn't exist, create it
          await createTable(db);
        }
      },
      onCreate: _createDatabase,
    );
  }

  // Asynchronous method to create the notifications table in the SQLite database
  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        reference INTEGER PRIMARY KEY AUTOINCREMENT,
        id TEXT,
        title TEXT,
        message TEXT,
        isRead INTEGER,
        timestamp TEXT
      )
    ''');
  }

  // Function to check if a table exists in the SQLite database
  Future<bool> doesTableExist(Database db, String tableName) async {
    var result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='$tableName'",
    );
    return result.isNotEmpty;
  }

  // Asynchronous method to create the notifications table if it doesn't exist
  Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableName (
        reference INTEGER PRIMARY KEY AUTOINCREMENT,
        id TEXT,
        title TEXT,
        message TEXT,
        isRead INTEGER,
        timestamp TEXT
      )
    ''');
  }

  // Asynchronous method to insert a notification into the SQLite database
  Future<void> insertNotification(NotificationItem notification) async {
    final db = await database;
    print("${notification.id} this is user ID");
    await db.insert('notifications', notification.toMap());
  }

  // Asynchronous method to delete the notifications table (for debugging purposes)
  Future<void> deleteTable() async {
    final db = await database;
    await db.execute('DROP TABLE IF EXISTS $tableName');
  }

  // Asynchronous method to retrieve all notifications from the SQLite database
  Future<List<NotificationItem>> getAllNotifications() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('SELECT * FROM notifications');
    return List.generate(maps.length, (i) {
      return NotificationItem.fromMap(maps[i]);
    });
  }

  // Asynchronous method to delete a notification from the SQLite database
  Future<void> deleteNotification(NotificationItem notification) async {
    final db = await database;
    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [notification.id],
    );
  }
}
