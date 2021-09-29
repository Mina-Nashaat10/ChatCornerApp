part of 'chat_bloc.dart';

@immutable
abstract class ChatState {}

class ChatInitial extends ChatState {}

// ignore: must_be_immutable
class MessageSendedSuccessful extends ChatState {
  late bool messageIsSendSuccessful;
  MessageSendedSuccessful({required this.messageIsSendSuccessful});
}

// ignore: must_be_immutable
class ChatsSnapshotLoaded extends ChatState {
  late Stream<QuerySnapshot> chatsSnapshot;
  ChatsSnapshotLoaded({required this.chatsSnapshot});
}

// ignore: must_be_immutable
class MyFriendsListWithLastMessageIsLoaded extends ChatState {
  late Map<String, dynamic> map;
  MyFriendsListWithLastMessageIsLoaded({required this.map});
}

// ignore: must_be_immutable
class ChatMessagesLoaded extends ChatState {
  late List<Chat> chats;
  ChatMessagesLoaded({required this.chats});
}

// ignore: must_be_immutable
class ChatMessagesSnapshotLoaded extends ChatState {
  late Stream<QuerySnapshot> chatMessagesSnapshot;
  ChatMessagesSnapshotLoaded({required this.chatMessagesSnapshot});
}

// ignore: must_be_immutable
class NotificationSendedSuccessfully extends ChatState {
  late bool isSend;
  NotificationSendedSuccessfully({required this.isSend});
}
