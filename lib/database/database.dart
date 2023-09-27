import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class Db {
  var path;
  Database? currDb;
  StoreRef<dynamic, dynamic>? store;
  List<dynamic>? records;

  Db(this.path);

  //open database

  Future<void> openDb() async {
    final DatabaseFactory dbFactory = databaseFactoryIo;
    currDb = await dbFactory.openDatabase(path);
  }

  //retrieve a store (multiple records)

  Future<List<dynamic>?> storeDb(bool insert) async {
    store = StoreRef<dynamic, dynamic>.main();
    records = await store!.find(currDb!);
    if (!insert) currDb!.close();
    return records;
  }

  //insert into database

  Future<void> insertDb(dynamic key, dynamic value) async {
    await store!.record(key).put(currDb!, value);
    await currDb!.close();
  }

  //retrieve record based on key

  Future<String?> findDb(String? key) async {
    var jsonString = await store!.record(key!).get(currDb!);
    jsonString ??= '';
    return jsonString;
  }

  //delete database

  Future<void> deleteDb(key) async {
    final finder = Finder(filter: Filter.byKey(key));
    await store!.delete(currDb!, finder: finder);
  }

  //close database

  Future<void> closeDb() async {
    await currDb!.close();
  }
}
