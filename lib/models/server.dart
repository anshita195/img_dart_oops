import 'dart:convert';
import 'package:img_dart_oops/models/user.dart';
import 'package:img_dart_oops/database/database.dart';
import 'dart:io';
import 'package:img_dart_oops/models/permission.dart';
import 'package:img_dart_oops/models/roles.dart';
import 'package:img_dart_oops/models/check.dart';
import 'package:img_dart_oops/models/channel.dart';

class Server {
  String? serverName;
  Map<String, dynamic>? users;
  Map<String, dynamic>? categories;

  Server(this.serverName, String creator) {
    Permissions p = Permissions();
    Roles r = Roles();
    users = {
      creator: p.all!,
    };
    // print(p.all);
    categories = {
      'Admin': r.superUser!,
      'modUsers': r.modUser!,
      'General': r.baseUser!,
      'null': r.baseUser!,
    };
  }

  Server.fromDb(this.serverName);

  Future<Server> getServerObj(String serverName) async {
    var path = 'lib/database/server.db';
    Db serverDb = Db(path);
    await serverDb.openDb();
    List<dynamic>? serverRec = await serverDb.storeDb(true);
    String? record = await serverDb.findDb(serverName);
    await serverDb.closeDb();
    Server obj = Server.fromDb(serverName);

    String jsonUser = jsonDecode(record!)['users'];
    try {
      obj.users = jsonDecode(jsonUser);
    } catch (e) {
      print(jsonDecode(jsonUser).runtimeType);
      print("Error : $e");
    }
    obj.categories = jsonDecode(jsonDecode(record)['categories']);
    return obj;
  }

  static Future<void> createServer(String creator) async {
    stdout.write("Enter Server Name : ");
    String? serverName = stdin.readLineSync();
    var pathServer = 'lib/database/server.db';
    Db serverDb = Db(pathServer);
    await serverDb.openDb();

    List<dynamic>? serverRec = await serverDb.storeDb(true);

    for (var rec in serverRec!) {
      if (rec.key == serverName) {
        print(
            "A server with this name already exists!! Kindly choose a different name");
        return;
      }
    }

    Server newServer = Server(serverName, creator);
    String serverJson = jsonEncode(newServer.toMap());
    await serverDb.insertDb(serverName, serverJson);

    List<String> channels = ['default'];
    Map<String, dynamic> catChannelMap = {
      'Admin': channels,
      'modUsers': channels,
      'General': channels,
      'null': channels,
    };
    String channelList = jsonEncode(catChannelMap);
    Map<String, dynamic> categoryMap = newServer.categories!;

    var pathCat = 'lib/database/categories.db';
    Db categoryDb = Db(pathCat);
    await categoryDb.openDb();
    List<dynamic>? categoryRec = await categoryDb.storeDb(true);
    await categoryDb.insertDb(serverName, channelList);
    for (var entry in categoryMap.entries) {
      await Channel.defaultChannel(entry.key, newServer, entry.value, creator);
    }
    print("Server created successfully!!");
  }

  Map<String, String> toMap() {
    return {
      'name': serverName!,
      'users': jsonEncode(users),
      'categories': jsonEncode(categories),
    };
  }

  static String toJsonString(Server obj) {
    String? JsonString = jsonEncode(obj.toMap());
    return JsonString;
  }

  static Map<String, dynamic> fromJsonString(String jsonString) {
    Map<String, dynamic> map = jsonDecode(jsonString);

    return map;
  }

  static Future<void> addUser(
      String currentUser, String currentServer, int currPerm) async {
    Permissions p = Permissions();

    if (currPerm & p.addUser! != p.addUser) {
      print("You do not have the rights to add user to the server!!");
      return;
    }
    stdout.write("Whom would you like to add?? : ");
    String? userName = stdin.readLineSync();

    if (await checkValidity.checkRegistration(userName!) == false) {
      print("such a user does not exist");
      return;
    }
    stdout.write("role of user? [modUser/baseUser]");
    String? role = stdin.readLineSync();
    int? perm;

    var pathServ = 'lib/database/server.db';
    Db serverDb = Db(pathServ);
    await serverDb.openDb();
    List<dynamic>? records = await serverDb.storeDb(true);
    String? oldJson = await serverDb.findDb(currentServer);
    Map<String, dynamic> currServerDb = fromJsonString(oldJson!);

    Map<String, dynamic> users = jsonDecode(currServerDb['users']!);
    if (users[userName] != null) {
      print("This user is already added to the server!!");
      return;
    }
    if (role == null) {
      users[userName] = perm!;
    } else {
      Roles r = Roles();
      switch (role) {
        case 'modUser':
          users[userName] = r.modUser!;
          break;
        case 'baseUser':
          users[userName] = r.baseUser!;
          break;
      }
    }
    currServerDb['users'] = jsonEncode(users);
    String newJson = jsonEncode(currServerDb);
    await serverDb.deleteDb(currentServer);
    await serverDb.insertDb(currentServer, newJson);
    print(
        "Congratulations!! You have successfully added user $userName to the current server");
  }

  static Future<bool> enterServer(String serverName, String userName) async {
    if (await checkValidity.checkServer(serverName)) {
      if (checkValidity.checkLogin(userName)) {
        if (await checkValidity.checkServerUser(userName, serverName)) {
          return true;
        }
      }
    }
    return false;
  }

  static Future<void> printCategories(
      String username, Server server, int permission) async {
    Roles r = Roles();
    Map<String, dynamic>? categories = server.categories;

    for (var entry in categories!.entries) {
      if (entry.key != 'null') {
        await Future.delayed(Duration(seconds: 2), () async {
          print(entry.key);
        });
      }
    }
  }

  static Future<void> printmodUser(Server server) async {
    Roles r = Roles();
    Map<String, dynamic> userMap = server.users!;
    print("");
    for (var entry in userMap.entries) {
      if ((entry.value & r.modUser != 0) || (entry.value & r.superUser != 0)) {
        print(entry.key);
      }
    }
    print("");
  }
}
