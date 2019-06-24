import 'dart:async';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vocaner/model.dart';

class DBAdapter {
  DBAdapter._();

  static final DBAdapter db = DBAdapter._();
  static Database _database;
  static final formatter = new DateFormat('yyyy-MM-dd');

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await initDb();
    print("Database is ready!");
    return _database;
  }

  initDb() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "vocaner.db");
    return await openDatabase(path,
        version: 2,
        onOpen: (db) {},
        onCreate: _onCreate,
        onUpgrade: _onUpgrade);
  }

  void _onCreate(Database db, int version) async {
    await db.execute("CREATE TABLE Word("
        "id INTEGER PRIMARY KEY, "
        "name TEXT, "
        "transcription TEXT, "
        "description TEXT, "
        "date TEXT, "
        "status INTEGER"
        ");");
    print("Database has been created!");
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    for (int v = oldVersion + 1; v <= newVersion; v++) {
      switch (v) {
        case 2:
          {
            await db
                .execute("CREATE UNIQUE INDEX idx_word_name ON Word (name);");
          }
          break;
        case 3:
          {
            //statements;
          }
          break;
      }
      print("Database is on version " + v.toString());
    }
  }

  Future<List<Word>> getAllWords() async {
    final db = await database;
    var result =
        await db.rawQuery('SELECT * FROM Word ORDER BY date DESC, id DESC');
    List<Word> list =
        result.isNotEmpty ? result.map((w) => Word.fromMap(w)).toList() : [];
    print("Words read: " + list.length.toString());
    return list;
  }

  Future<List<Word>> getNewWords() async {
    final db = await database;
    var result = await db.rawQuery(
        'SELECT * FROM Word WHERE status = 0 ORDER BY date DESC, id DESC');
    List<Word> list =
        result.isNotEmpty ? result.map((w) => Word.fromMap(w)).toList() : [];
    print("Words read: " + list.length.toString());
    return list;
  }

  deleteAllWords() async {
    final db = await database;
    db.rawDelete("DELETE FROM Word");
  }

  // ========== CRUD ========== //
  createWord(Word w) async {
    final db = await database;
    var nextId = (await db.rawQuery("SELECT MAX(id)+1 as nextId FROM Word"))
        .first["nextId"];
    var now = formatter.format(new DateTime.now());
    var id = await db.rawInsert(
        "INSERT INTO Word (id,name,transcription,description,date,status)"
        " VALUES (?,?,?,?,?,?)",
        [nextId, w.name, w.transcription, w.description, now, 0]);
    print("Word has been created with id = " + id.toString());
    return id;
  }

  getWord(int id) async {
    final db = await database;
    var result = await db.query("Word", where: "id = ?", whereArgs: [id]);
    return result.isNotEmpty ? Word.fromMap(result.first) : null;
  }

  updateWord(Word w) async {
    final db = await database;
    var result =
        await db.update("Word", w.toMap(), where: "id = ?", whereArgs: [w.id]);
    print("Word has been updated");
    return result;
  }

  deleteWord(int id) async {
    final db = await database;
    var result = db.delete("Word", where: "id = ?", whereArgs: [id]);
    print("Word has been removed");
    return result;
  }
  // ========== CRUD END ========== //
}
