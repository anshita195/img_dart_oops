import 'package:img_dart_oops/models/user.dart';
import 'dart:convert';
import 'dart:io';

class Message {
  String? sender;
  String? message;
  String? timeStamp;

  Message.channel(this.sender, this.message) {
    timeStamp = DateTime.now.toString();
  }

  String msgToJson() {
    String jsonString = jsonEncode(toMap());
    return jsonString;
  }

  Map<String, String> toMap() {
    return {
      'sender': sender!,
      'message': message!,
      'timeStamp': timeStamp!,
    };
  }

  static String newMessageinChannel(String userName) {
    stdout.write("Enter the message : ");
    String? message = stdin.readLineSync();
    Message newMessage = Message.channel(userName, message);
    String messageJson = newMessage.msgToJson();
    return messageJson;
  }
}
