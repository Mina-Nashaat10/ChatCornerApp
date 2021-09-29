import 'package:chat_corner/data/models/chat.dart';
import 'package:chat_corner/data/models/user.dart';
import 'package:chat_corner/data/web_services/chat_web_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class ChatRepository {
  late ChatWebServices _chatWebServices;
  ChatRepository() {
    _chatWebServices = ChatWebServices();
  }

  Future<bool> sendMessage(Chat chat) async {
    bool messageIsSendSuccessful = await _chatWebServices.sendMessage(chat);
    return messageIsSendSuccessful;
  }

  Stream<QuerySnapshot> getChatsSnapShot() async* {
    yield* _chatWebServices.getChatsSnapShot();
  }

  Future<Map<String, dynamic>> getMyFriendsWithLastMessage() async {
    Map<String, dynamic> map = Map<String, dynamic>();
    map = await _chatWebServices.getMyFriendsWithLastMessage();
    return map;
  }

  Stream<QuerySnapshot> getChatMessagesSnapshot(
      String yourEmail, String friendEmail) async* {
    yield* _chatWebServices.getChatMessagesSnapshot(yourEmail, friendEmail);
  }

  Future<List<Chat>> getChatMessages(
      String yourEmail, String friendEmail) async {
    List<Chat> _chats =
        await _chatWebServices.getChatMessages(yourEmail, friendEmail);
    return _chats;
  }

  bool sendNotificationByUserToken(User cureentUser, User recievedUser,
      String notificationContent, BuildContext context) {
    return _chatWebServices.sendNotificationByUserToken(
        cureentUser, recievedUser, notificationContent, context);
  }
}
