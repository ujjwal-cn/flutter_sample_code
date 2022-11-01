import 'package:go4sheq/model/notification_details.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Sore data locally
class DBProvider {
  static const String tableNotification = "notification";

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _createDB();
    return _database!;
  }

  static final DBProvider db = DBProvider._();

  DBProvider._();

  // Define DB
  Future<Database> _createDB() async {
    String dbPath = await getDatabasesPath();

    return await openDatabase(
      join(dbPath, 'device_manager.db'),
      version: 1,
      onCreate: (Database database, int version) async {
        await database.execute(
          "CREATE TABLE $tableNotification ("
          "notificationid INTEGER PRIMARY KEY AUTOINCREMENT,"
          "title TEXT,"
          "body TEXT,"
          "unread INTEGER,"
          "date INTEGER"
          ")",
        );
      },
    );
  }

  // Save new notification
  Future<int> insertNotification(NotificationDetails notificationDetails) async {
    final db = await database;
    final response = await db.insert(tableNotification, notificationDetails.toJson());

    return response;
  }

  // read all notifications
  Future<List<NotificationDetails>> readNotifications() async {
    final db = await database;
    final response = await db.query(tableNotification);

    List<NotificationDetails> notificationDetailsList = response.isNotEmpty ? response.map((c) => NotificationDetails.fromJson(c)).toList() : [];
    return notificationDetailsList;
  }

  // update a notification
  Future<int> updateNotificationAsRead({required int notificationId}) async {
    final db = await database;
    final response = await db.update(tableNotification, {"unread": 0}, where: 'notificationid = ?', whereArgs: [notificationId]);

    return response;
  }
}
