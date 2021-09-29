import 'package:chat_corner/business_logic/bloc/chatBloc/chat_bloc.dart';
import 'package:chat_corner/constants/strings.dart';
import 'package:chat_corner/data/models/chat.dart';
import 'package:chat_corner/data/models/user.dart';
import 'package:chat_corner/data/web_services/user_web_services.dart';
import 'package:chat_corner/helpers/shared_preference.dart';
import 'package:chat_corner/helpers/strings_to_title_case.dart';
import 'package:chat_corner/navigtor_key.dart';
import 'package:chat_corner/presentation/screens/chat_screens/chat_messages_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class ChatWebServices {
  late FirebaseFirestore _firestore;
  ChatWebServices() {
    _firestore = FirebaseFirestore.instance;
  }

  Future<bool> sendMessage(Chat chat) async {
    await _firestore
        .collection("chats")
        .add(Chat().toJson(chat))
        .whenComplete(() {
      return true;
    });
    return false;
  }

  Stream<QuerySnapshot> getChatMessagesSnapshot(
      String yourEmail, String friendEmail) async* {
    yield* _firestore
        .collection("chats")
        .where('sender', isEqualTo: friendEmail)
        .where('receiver', isEqualTo: yourEmail)
        .snapshots();
  }

  Future<List<Chat>> getChatMessages(
      String yourEmail, String friendEmail) async {
    List<Chat> _yourChats = [];
    await _firestore
        .collection("chats")
        .where('sender', isEqualTo: yourEmail)
        .where('receiver', isEqualTo: friendEmail)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        _yourChats.add(Chat.fromJson(element.data()));
      });
    });
    List<Chat> _friendChats = [];
    await _firestore
        .collection("chats")
        .where('sender', isEqualTo: friendEmail)
        .where('receiver', isEqualTo: yourEmail)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        _friendChats.add(Chat.fromJson(element.data()));
      });
    });

    List<Chat> _chats = [];
    int i = 0, j = 0;
    while (i < _yourChats.length && j < _friendChats.length) {
      if (_yourChats[i].dateTime.isBefore(_friendChats[j].dateTime)) {
        _chats.add(_yourChats[i]);
        i++;
      } else {
        _chats.add(_friendChats[j]);
        j++;
      }
    }
    while (i < _yourChats.length) {
      _chats.add(_yourChats[i]);
      i++;
    }

    while (j < _friendChats.length) {
      _chats.add(_friendChats[j]);
      j++;
    }
    _chats = _sortChatMessagesByDateTimeFromSmallToBigger(_chats);
    return _chats;
  }

  List<Chat> _sortChatMessagesByDateTimeFromSmallToBigger(List<Chat> _chats) {
    int i, j;
    Chat key;
    for (i = 1; i < _chats.length; i++) {
      key = _chats[i];
      j = i - 1;

      /* Move elements of arr[0..i-1], that are
        greater than key, to one position ahead
        of their current position */
      while (j >= 0 && _chats[j].dateTime.isAfter(key.dateTime)) {
        _chats[j + 1] = _chats[j];
        j = j - 1;
      }
      _chats[j + 1] = key;
    }
    return _chats;
  }

  Stream<QuerySnapshot> getChatsSnapShot() async* {
    String myEmail = await SharedPreference.getUserEmail();
    yield* _firestore
        .collection("chats")
        .where('receiver', isEqualTo: myEmail)
        .snapshots();
  }

  Future<Map<String, dynamic>> getMyFriendsWithLastMessage() async {
    List<String> _users = [];
    String myEmail = await SharedPreference.getUserEmail();
    // get all messages that i sended to firends
    await _firestore
        .collection("chats")
        .where('sender', isEqualTo: myEmail)
        .orderBy('date_time')
        .get()
        .then((value) {
      value.docs.forEach((element) {
        _users.add(Chat.fromJson(element.data()).receiver);
      });
    });
    // get all messages that i recieved from firends
    await _firestore
        .collection("chats")
        .where('receiver', isEqualTo: myEmail)
        .orderBy('date_time')
        .get()
        .then((value) {
      value.docs.forEach((element) {
        _users.add(Chat.fromJson(element.data()).sender);
      });
    });
    // get my all friend that send me or recieved from me
    List<String> distincatUsers = _users.toSet().toList();
    List<User> _myFriends = [];
    List<Chat> lastMessages = [];
    int i = 0;
    while (i < distincatUsers.length) {
      await _firestore
          .collection("users")
          .where('email', isEqualTo: distincatUsers[i])
          .get()
          .then((value) {
        value.docs.forEach((e) {
          _myFriends.add(User.fromJson(map: e.data()));
        });
      });
      // get last message that i send it to my friend
      bool foundMessageForMe = false, foundMessageForMyFriend = false;
      Chat myMessage = Chat();
      await _firestore
          .collection("chats")
          .where('sender', isEqualTo: myEmail)
          .where('receiver', isEqualTo: distincatUsers[i])
          .orderBy('date_time', descending: true)
          .limit(1)
          .get()
          .then((value) {
        value.docs.forEach((element) {
          foundMessageForMe = true;
          myMessage = Chat.fromJson(element.data());
        });
      });
      // get last message that i send it to my friend
      Chat friendMessage = Chat();
      await _firestore
          .collection("chats")
          .where('sender', isEqualTo: distincatUsers[i])
          .where('receiver', isEqualTo: myEmail)
          .orderBy('date_time', descending: true)
          .limit(1)
          .get()
          .then((value) {
        value.docs.forEach((element) {
          foundMessageForMyFriend = true;
          friendMessage = Chat.fromJson(element.data());
        });
      });
      if (foundMessageForMe == true && foundMessageForMyFriend == true) {
        if (myMessage.dateTime.isBefore(friendMessage.dateTime)) {
          lastMessages.add(friendMessage);
        } else {
          lastMessages.add(myMessage);
        }
      } else {
        if (foundMessageForMe == true) {
          lastMessages.add(myMessage);
        } else {
          lastMessages.add(friendMessage);
        }
      }
      i++;
    }
    lastMessages = _sortLastMessagesByDateTimeFromBiggerToSmall(lastMessages);
    Map<String, dynamic> map = {
      'my_friends': _myFriends,
      'last_message': lastMessages,
    };
    return map;
  }

  List<Chat> _sortLastMessagesByDateTimeFromBiggerToSmall(
      List<Chat> lastMessages) {
    int i, j;
    Chat key;
    for (i = 1; i < lastMessages.length; i++) {
      key = lastMessages[i];
      j = i - 1;

      /* Move elements of arr[0..i-1], that are
        greater than key, to one position ahead
        of their current position */
      while (j >= 0 && lastMessages[j].dateTime.isAfter(key.dateTime)) {
        lastMessages[j + 1] = lastMessages[j];
        j = j - 1;
      }
      lastMessages[j + 1] = key;
    }
    List<Chat> sortedLastMessagesList = [];
    i = lastMessages.length - 1;
    while (i >= 0) {
      sortedLastMessagesList.add(lastMessages[i]);
      i--;
    }
    return sortedLastMessagesList;
  }

  bool sendNotificationByUserToken(User cureentUser, User recievedUser,
      String notificationContent, BuildContext context) {
    OneSignal.shared
        .postNotification(
      OSCreateNotification(
        playerIds: [recievedUser.userToken.toString()],
        content: notificationContent,
        heading: convertStringToTitleCase(cureentUser.fullName) +
            " send new message",
        additionalData: cureentUser.toJson(cureentUser),
      ),
    )
        .whenComplete(() {
      return true;
    });
    return false;
  }
}
