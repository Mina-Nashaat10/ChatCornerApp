part of 'chat_bloc.dart';

@immutable
abstract class ChatEvent {}

// ignore: must_be_immutable
class SendMessage extends ChatEvent {
  late Chat chat;
  SendMessage({required this.chat});
}

// ignore: must_be_immutable
class GetChatsSnapshot extends ChatEvent {}

class GetMyFriendsWithLastMessage extends ChatEvent {}

// ignore: must_be_immutable
class GetChatMessages extends ChatEvent {
  late String yourEmail, friendEmail;
  GetChatMessages({required this.yourEmail, required this.friendEmail});
}

// ignore: must_be_immutable
class GetChatMessagesSnapshot extends ChatEvent {
  late String yourEmail, friendEmail;
  GetChatMessagesSnapshot({required this.yourEmail, required this.friendEmail});
}

// ignore: must_be_immutable
class SendNotificationToSpecificUserByToken extends ChatEvent {
  late User cureentUser, receivedUser;
  late String notificationContent;
  late BuildContext context;
  SendNotificationToSpecificUserByToken(
      {required this.cureentUser,
      required this.receivedUser,
      required this.notificationContent,
      required this.context});
}
