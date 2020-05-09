import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'todolist.dart';

class DBHelper{
  static Database _db;
  static const String ID = 'id';
  static const String ITEM = 'item';
  static const String TABLE = 'ToDoTable';
  static const String DB_NAME = 'todo.db';

  Future<Database> get db async{
    if(_db != null){
      return _db;
    }
    _db = await initDb();
    return _db;
  }
  initDb() async{
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path= join(documentsDirectory.path, DB_NAME);
    var db = await openDatabase(path,version:1,onCreate:_onCreate);
    return db;
  }

 _onCreate(Database db, int version) async {
    await db.execute('''CREATE TABLE IF NOT EXISTS $TABLE (
      $ID INTEGER PRIMARY KEY,
      $ITEM TEXT
      )''');
  }

  Future<ToDo> save(ToDo todovariable) async{
    var dbClient = await db;
    todovariable.id = await dbClient.insert(TABLE, todovariable.toMap());
    return todovariable;
  }

  Future<List<ToDo>> gettodo() async{
    var dbClient = await db;
    List<Map> maps = await dbClient.query(TABLE,columns:[ID,ITEM]);
    //List<Map> maps = await dbClient.
    List<ToDo> todoarray =[];
    if(maps.length>0){
      for(int i=0; i<maps.length; i++){
        todoarray.add(ToDo.fromMap(maps[i])); 
      }
    }
    return todoarray;
  }

  Future<int>delete (int id) async{
    var dbClient = await db;
    return await dbClient.delete(TABLE, where:'$ID=?', whereArgs:[id]);
  }

  Future<int>update (ToDo todovariable) async{
    var dbClient = await db;
    return await dbClient.update(TABLE, todovariable.toMap(), 
    where:'$ID=?' , whereArgs: [todovariable.id]);
  }

 Future close() async{
   var dbClient = await db;
   dbClient.close();
 } 

}