import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final databaseName = 'quoteDatabase.db';
  static final databaseVersion = 1;

  static final categoryTableName = 'categoryTable';
  static final categoryColumnId = 'categoryId';
  static final categoryColumnName = 'name';
  static final categoryImageUrl = 'imageUrl';
  static final categoryLength = 'categoryLength';
  static final categoryInitialQuote = 'initialQuote';

  static final quoteTableName = 'quoteTable';
  static final categoryId = 'categoryId';
  static final quoteColumnId = 'quoteId';
  static final quoteColumn = 'quote';
  static final isFav = 'isFav';

  static Database database;

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  Future<Database> get getDatabase async {
    if (database != null) return database;
    database = await _initDatabase();
    return database;
  }

  static _initDatabase() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, databaseName);
    return await openDatabase(path,
        version: databaseVersion,
        onCreate: _onCreate,
        onConfigure: _onConfigure);
  }

  static Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  static Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $categoryTableName
      (
      $categoryColumnId INTEGER ,
      $categoryColumnName TEXT NOT NULL,
      $categoryImageUrl TEXT NOT NULL,
      $categoryLength TEXT NOT NULL,
      $categoryInitialQuote TEXT NOT NULL
                  )
      ''');
    await db.execute('''
    CREATE TABLE $quoteTableName
    (
    $categoryId INTEGER,
    $quoteColumnId INTEGER ,
    $quoteColumn TEXT NOT NULL,
    $isFav TEXT NOT NULL,
    "FOREIGN KEY ($categoryId) REFERENCES $categoryTableName ($categoryColumnId) ON DELETE NO ACTION ON UPDATE NO ACTION"
    )
     ''');
  }

  insertIntoCat({Map<String, dynamic> categoryTableRow}) async {
    Database db = await instance.getDatabase;
    var res = await db.insert('categoryTable', categoryTableRow);
    return res;
  }

  insertIntoDetail({Map<String, dynamic> categoryDetailTableRow}) async {
    Database db = await instance.getDatabase;
    var res = await db.insert('quoteTable', categoryDetailTableRow);
    return res;
  }

  Future queryAllCategoryTable() async {
    var res = await database.query('categoryTable');
    return res;
  }

  Future queryCat({int catId}) async {
    var res = await database
        .rawQuery('SELECT * FROM $quoteTableName WHERE $categoryId=$catId');
    return res;
  }

  Future queryQuote({int quoteId, int catId}) async {
    var res = await database.rawQuery(
        'SELECT * FROM $quoteTableName WHERE $quoteColumnId=$quoteId AND $categoryId=$catId');
    return res;
  }

  Future favQuery(String checkFav) async {
    var res = await database
        .query('quoteTable', where: "isFav LIKE ?", whereArgs: [checkFav]);
    return res;
  }

  Future favQueryDetail({String checkFav, int quoteId, int catId}) async {
    var res = await database.query('quoteTable',
        where: "isFav LIKE ? AND $quoteColumnId=? AND $categoryId=?",
        whereArgs: [checkFav, quoteId, catId]);
    return res;
  }

  Future queryAllCategoryDetail() async {
    var res = await database.query('categoryTable');
    return res;
  }

  Future update({int quoteId, String isFav, int catId}) async {
    var res = await database.update(quoteTableName, {"isFav": isFav},
        where: "$quoteColumnId = ? AND $categoryId=?",
        whereArgs: [quoteId, catId]);
    return res;
  }
}
