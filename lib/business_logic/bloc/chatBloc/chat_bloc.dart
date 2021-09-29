import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:chat_corner/data/models/chat.dart';
import 'package:chat_corner/data/models/user.dart';
import 'package:chat_corner/data/repository/chat_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  late ChatRepository _chatRepository;
  ChatBloc() : super(ChatInitial()) {
    _chatRepository = ChatRepository();
  }

  @override
  Stream<ChatState> mapEventToState(
    ChatEvent event,
  ) async* {
    if (event is SendMessage) {
      bool messageIsSendSuccessful =
          await _chatRepository.sendMessage(event.chat);
      yield MessageSendedSuccessful(
          messageIsSendSuccessful: messageIsSendSuccessful);
    } else if (event is GetChatsSnapshot) {
      Stream<QuerySnapshot> chatMessagesSnapshot =
          _chatRepository.getChatsSnapShot();
      yield ChatsSnapshotLoaded(chatsSnapshot: chatMessagesSnapshot);
    } else if (event is GetChatMessages) {
      List<Chat> chats = await _chatRepository.getChatMessages(
          event.yourEmail, event.friendEmail);
      yield ChatMessagesLoaded(chats: chats);
    } else if (event is GetMyFriendsWithLastMessage) {
      Map<String, dynamic> map =
          await _chatRepository.getMyFriendsWithLastMessage();
      yield MyFriendsListWithLastMessageIsLoaded(map: map);
    } else if (event is SendNotificationToSpecificUserByToken) {
      bool isSend = _chatRepository.sendNotificationByUserToken(
          event.cureentUser,
          event.receivedUser,
          event.notificationContent,
          event.context);
      yield NotificationSendedSuccessfully(isSend: isSend);
    } else if (event is GetChatMessagesSnapshot) {
      Stream<QuerySnapshot> chatMessagesSnapshot = _chatRepository
          .getChatMessagesSnapshot(event.yourEmail, event.friendEmail);
      yield ChatMessagesSnapshotLoaded(
          chatMessagesSnapshot: chatMessagesSnapshot);
    }
  }
}
