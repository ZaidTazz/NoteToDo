import 'package:path_provider/path_provider.dart';
import 'package:notetodo_flutter_application/data/models/note.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';

class DatabaseHelper {
  // Singleton Object
  static DatabaseHelper _databaseHelper;
  // Singleton Database
  static Database _database;

  String todoTable = 'todo_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colDate = 'date';

  // Named constructor to create instance of the DatabaseHelper
  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper
          ._createInstance(); // This is executed only once in the application, singleton object
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and iOS to store the database.
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'notes.db';

    // To open or create the database at a given path
    var notesDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  // Creating a Database with required columns
  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $todoTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, '
        '$colDescription TEXT, $colDate TEXT)');
  }

  // Functions to perform the CRUD Operations

  // Fetch Operation: To Get all note objects from the database
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;

    var result = await db.query(todoTable, orderBy: '$colDate ASC');
    return result;
  }

  // Insert Operation: To Insert a Note object to the database
  Future<int> insertNote(Note note) async {
    Database db = await this.database;
    var result = await db.insert(todoTable, note.toMap());
    return result;
  }

  // Update Operation: To Update a Note object and save it into the database
  Future<int> updateNote(Note note) async {
    var db = await this.database;
    var result = await db.update(todoTable, note.toMap(),
        where: '$colId = ?', whereArgs: [note.id]);
    return result;
  }

  // Delete Operation: To Delete a Note object from the database
  Future<int> deleteNote(int id) async {
    var db = await this.database;
    int result =
        await db.rawDelete('DELETE FROM $todoTable WHERE $colId = $id');
    return result;
  }

  // Get the 'Map List' from the database [ List<Map> ] and convert it to 'Note List' Object [ List<Note> ]
  Future<List<Note>> getNoteList() async {
    var noteMapList =
        await getNoteMapList(); // Get 'Map List' from the database
    int count = noteMapList
        .length; // Count the number of map entries in the database table

    List<Note> noteList = [];
    // For loop to copy all the 'Map List' objects into 'Note List'
    for (int i = 0; i < count; i++) {
      noteList.add(
        Note.fromMapObject(noteMapList[i]),
      );
    }

    return noteList;
  }
}
