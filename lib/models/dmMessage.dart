import 'dart:io';
import 'package:img_dart_oops/database/database.dart';
import 'package:img_dart_oops/models/check.dart';
import 'package:img_dart_oops/models/user.dart';
import 'dart:convert';

class dmMessage {
  String? sender;
  String? receiver;
  String? message;

  dmMessage(this.sender, this.receiver, this.message);

  String msgToJson() {
    String jsonString = jsonEncode(toMap());
    return jsonString;
  }

  Map<String, dynamic> toMap() {
    return {
      'sender': sender!,
      'message': message!,
      'receiver': receiver!,
    };
  }

  static String newMessageinDm(String sender, String receiver) {
    stdout.write("Enter the message : ");
    String? message = stdin.readLineSync();
    dmMessage newMessage = dmMessage(sender, receiver, message);
    String messageJson = newMessage.msgToJson();
    print(
        "sender : ${newMessage.sender}, receiver : ${newMessage.receiver}, message : ${newMessage.message}");
    return messageJson;
  }

  static String createDefault(String sender, String receiver) {
    String message = 'hi, I started using the new cli version of discord!!';
    dmMessage newMessage = dmMessage(sender, receiver, message);
    String messageJson = newMessage.msgToJson();
    return messageJson;
  }

  static Future<void> sendMessage(String sender) async {
    stdout.write("Whom would you like to dm??");

    String? receiver = stdin.readLineSync();
    bool userRegisterd = await checkValidity.checkRegistration(receiver!);
    if (!userRegisterd) {
      print("A user with username $receiver does not exist");
      return;
    }
    String messageJson = newMessageinDm(sender, receiver);
    var path = 'lib/database/users.db';
    Db usersDb = Db(path);
    await usersDb.openDb();
    List<dynamic>? records = await usersDb.storeDb(true);
    String? senderRec = await usersDb.findDb(sender);
    await usersDb.deleteDb(sender);
    Map<String, dynamic>? senderMap = jsonDecode(senderRec!);
    List<dynamic>? senderDm = jsonDecode(senderMap!['dmMessages']);
    senderDm!.add(messageJson);
    senderMap['dmMessages'] = jsonEncode(senderDm);
    String sendertoDb = jsonEncode(senderMap);
    await usersDb.insertDb(sender, sendertoDb);

    if (receiver != sender) {
      await usersDb.openDb();
      records = await usersDb.storeDb(true);
      String? receiverRec = await usersDb.findDb(receiver);
      await usersDb.deleteDb(receiver);
      Map<String, dynamic>? receiverMap = jsonDecode(receiverRec!);
      List<dynamic>? receiverDm = jsonDecode(receiverMap!['dmMessages']);
      receiverDm!.add(messageJson);
      receiverMap['dmMessages'] = jsonEncode(receiverDm);
      String receivertoDb = jsonEncode(receiverMap);
      await usersDb.insertDb(receiver, receivertoDb);
    }
    print("Message sent successfully!!");
  }

  static Future<void> showDm(String receiver) async {
    stdout.write("whose dm would you like to see??");
    String? sender = stdin.readLineSync();
    bool present = await checkValidity.checkRegistration(sender!);
    if (!present) {
      print("such a user does not exist");
      return;
    }
    var path = 'lib/database/users.db';
    Db usersDb = Db(path);
    await usersDb.openDb();

    List<dynamic>? records = await usersDb.storeDb(true);
    String? receiverRec = await usersDb.findDb(receiver);
    await usersDb.closeDb();
    Map<String, dynamic>? receiverMap = jsonDecode(receiverRec!);
    List<dynamic>? receiverDm = jsonDecode(receiverMap!['dmMessages']);
    Map<String, dynamic>? receiverMsg;
    int n = receiverDm!.length;
    print("");

    for (int i = 0; i < n; i++) {
      receiverMsg = jsonDecode(receiverDm[i]);

      if (receiverMsg!["sender"] == receiver &&
          receiverMsg["receiver"] == sender) {
        print("                      ${receiverMsg["message"]}  :$receiver");
      } else if (receiverMsg['receiver'] == receiver &&
          receiverMsg["sender"] == sender &&
          receiver != sender) {
        print("$sender: ${receiverMsg['message']}");
      }
    }

    print("");
  }
}
