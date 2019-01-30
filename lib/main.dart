import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
//  debugPrint("Hello World");
  var db = dbhelp();
  User user1 = User("User2");
  int insertResult = await db.saveUser(user1);
  debugPrint("insert result is " + insertResult.toString());
  User searchResult = await db.retrieveUser(insertResult);
  debugPrint(searchResult.toString());
  db.close();
}

class dbhelp {
  static final dbhelp _instance = dbhelp.internal();
  dbhelp.internal();
  factory dbhelp() => _instance;
  static Database _db;
  void _onCreate(Database _db, int newVersion) async {
    await _db.execute(
        "CREATE TABLE MYTABLE(ID INTEGER PRIMARY KEY autoincrement not null, userName TEXT NOT NULL)");
  }

  Future<Database> initDB() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, "appdb.db");
    Database newDB = await openDatabase(path, version: 1, onCreate: _onCreate);
    return newDB;
  }

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDB();
      return _db;
    }
  }

  Future<int> saveUser(User user) async {
    var dbClient = await db;
    int result;
    var userMap = user.toMap();
    result = await dbClient.insert("MYTABLE", userMap);
    return result;
  }

  Future<User> retrieveUser(int id) async {
    var dbClient = await db;
    if (id == null) {
      print("The ID is null, cannot find user with Id null");
      var nullResult =
          await dbClient.rawQuery("SELECT * FROM MYTABLE WHERE ID is null");
      return User.fromMap(nullResult.first);
    }
    String sql = "SELECT * FROM MYTABLE WHERE ID = $id";
    var result = await dbClient.rawQuery(sql);
    if (result.length != 0) {
      return User.fromMap(result.first);
    } else {
      return null;
    }
  }

  Future close() async {
    // always close DB after use
    var dbClient = await db;
    return dbClient.close();
  }
}

class User {
  String _userName;
  int _id;
  String get userName => _userName;
  int get id => _id;
  User(this._userName, [this._id]);
  User.map(dynamic obj) {
    this._userName = obj['userName'];
    this._id = obj['id'];
  }
  User.fromMap(Map<String, dynamic> map) {
    this._userName = map["userName"];
    if (map["id"] != null) {
      this._id = map["id"];
    } else {
      print("in fromMap, Id is null");
    }
  }
  Map<String, dynamic> toMap() {
    Map map = Map<String, dynamic>();
    map["userName"] = this._userName;
    if (_id != null) {
      map["id"] = _id;
    } else {
      print("in toMap, id is null");
    }
    return map;
  }

  @override
  String toString() {
    return "ID is ${this._id} , Username is ${this._userName} }";
  }
}
