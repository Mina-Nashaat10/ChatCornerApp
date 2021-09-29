import 'dart:async';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_corner/business_logic/bloc/chatBloc/chat_bloc.dart';
import 'package:chat_corner/business_logic/bloc/userBloc/user_bloc.dart';
import 'package:chat_corner/constants/sizes.dart';
import 'package:chat_corner/data/models/chat.dart';
import 'package:chat_corner/data/models/user.dart';
import 'package:chat_corner/helpers/shared_preference.dart';
import 'package:chat_corner/helpers/strings_to_title_case.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as intl;
import 'package:onesignal_flutter/onesignal_flutter.dart';

// ignore: must_be_immutable
class ChatMessagesScreen extends StatefulWidget {
  late User recievedUser;
  ChatMessagesScreen({Key? key, required this.recievedUser}) : super(key: key);

  @override
  _ChatMessagesScreenState createState() =>
      _ChatMessagesScreenState(recievedUser: recievedUser);
}

class _ChatMessagesScreenState extends State<ChatMessagesScreen> {
  late User cureentUser;
  late User recievedUser;
  late ChatBloc _chatBloc;
  late UserBloc _userBloc;
  late String senderEmail;
  List<Chat> chats = [];
  String message = "";
  TextEditingController messageController = TextEditingController();
  final _listViewScrollController = ScrollController();
  FocusNode focusNode = FocusNode();
  bool chatsIsLoaded = false,
      currentUserIsLoaded = false,
      chatsSnapshotIsLoaded = false;
  late Stream<QuerySnapshot> _stream;
  bool screenStarted = false;
  _ChatMessagesScreenState({required this.recievedUser});

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _chatBloc = BlocProvider.of<ChatBloc>(context);
    _userBloc = BlocProvider.of<UserBloc>(context);
    senderEmail = await SharedPreference.getUserEmail();
    _chatBloc.add(GetChatMessages(
        yourEmail: senderEmail, friendEmail: recievedUser.email));
    _userBloc.add(GetUserInformation());
    _chatBloc.add(GetChatMessagesSnapshot(
        yourEmail: senderEmail, friendEmail: recievedUser.email));
  }

  PreferredSizeWidget buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            margin: EdgeInsets.fromLTRB(2, 2, 5, 2),
            child: CachedNetworkImage(
              imageUrl: recievedUser.imageUrl.toString(),
              placeholder: (context, url) => Image.asset(
                'assets/images/profile-loading.gif',
              ),
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 5),
          Container(
            child: Text(
              convertStringToTitleCase(
                recievedUser.fullName,
              ),
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      centerTitle: true,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Colors.black,
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  bool isRTL(String text) {
    return intl.Bidi.detectRtlDirectionality(text);
  }

  void scrollListviewToEnd() {
    if (_listViewScrollController.hasClients) {
      _listViewScrollController.animateTo(
        _listViewScrollController.position.maxScrollExtent + 100,
        curve: Curves.easeOut,
        duration: const Duration(microseconds: 50),
      );
    }
  }

  Widget buildSenderWidget() {
    return Container(
      margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.fromLTRB(5, 5, 0, 10),
              child: TextField(
                onTap: () {
                  scrollListviewToEnd();
                },
                textDirection:
                    isRTL(message) ? TextDirection.rtl : TextDirection.ltr,
                focusNode: focusNode,
                controller: messageController,
                onChanged: (value) {
                  setState(() {
                    message = value;
                  });
                },
                autocorrect: true,
                minLines: 1,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                cursorColor: Colors.black,
                style: TextStyle(
                  fontSize: 18,
                ),
                decoration: InputDecoration(
                  hintText: "Typing ...",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                  contentPadding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(
                      color: Colors.grey.shade200,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(5, 5, 0, 7),
            child: IconButton(
              icon: Icon(
                Icons.send,
                color: message.isEmpty ? Colors.grey : Colors.blue,
                size: 30,
              ),
              onPressed: () async {
                if (message.isNotEmpty) {
                  Chat chat = Chat();
                  chat.sender = senderEmail;
                  chat.receiver = recievedUser.email;
                  chat.message = message.trim();
                  chat.dateTime = DateTime.now();
                  _chatBloc.add(SendMessage(chat: chat));
                  messageController.text = "";
                  _chatBloc.add(
                    SendNotificationToSpecificUserByToken(
                      cureentUser: cureentUser,
                      receivedUser: recievedUser,
                      notificationContent: message,
                      context: context,
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget showChatMessages() {
    if (_listViewScrollController.hasClients) {
      if (screenStarted == false) {
        scrollListviewToEnd();
        setState(() {
          screenStarted = true;
        });
      }
    }
    Widget widget = Expanded(
      child: StreamBuilder<QuerySnapshot>(
          stream: _stream,
          builder: (context, snapshot) {
            _chatBloc.add(GetChatMessages(
                yourEmail: senderEmail, friendEmail: recievedUser.email));
            return ListView.builder(
              controller: _listViewScrollController,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Align(
                  alignment: chats[index].receiver != recievedUser.email
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(15, 8, 10, 5),
                    padding: EdgeInsets.fromLTRB(15, 8, 15, 8),
                    constraints: BoxConstraints(
                      minWidth: 70,
                      maxWidth: ScreenSize.getWidthtScreen(context) * 0.7,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: chats[index].receiver != recievedUser.email
                          ? BorderRadius.only(
                              bottomLeft: Radius.circular(30.0),
                              topLeft: Radius.circular(30.0),
                              bottomRight: Radius.circular(30.0),
                            )
                          : BorderRadius.only(
                              bottomLeft: Radius.circular(30.0),
                              topRight: Radius.circular(30.0),
                              bottomRight: Radius.circular(30.0),
                            ),
                      color: chats[index].receiver != recievedUser.email
                          ? Colors.grey.shade300
                          : Colors.lightBlue.shade200,
                    ),
                    child: Column(
                      crossAxisAlignment: isRTL(chats[index].message)
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          chats[index].message,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: isRTL(chats[index].message)
                              ? TextAlign.right
                              : TextAlign.left,
                        ),
                        SizedBox(height: 3),
                        Text(
                          " " +
                              intl.DateFormat('hh:mm a')
                                  .format(chats[index].dateTime),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                );
              },
              itemCount: chats.length,
            );
          }),
    );

    return widget;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ChatBloc, ChatState>(listener: (context, state) {
          if (state is ChatMessagesLoaded) {
            setState(() {
              chats = [];
              chats = state.chats;
              chatsIsLoaded = true;
            });
          }
          if (state is ChatMessagesSnapshotLoaded) {
            setState(() {
              chatsSnapshotIsLoaded = true;
              _stream = state.chatMessagesSnapshot;
            });
          }
          if (state is MessageSendedSuccessful) {
            Future.delayed(
                Duration(
                  microseconds: 10,
                ),
                () => scrollListviewToEnd());
          }
        }),
        BlocListener<UserBloc, UserState>(
          listener: (context, state) {
            if (state is UserInfoIsAvailable) {
              setState(() {
                cureentUser = state.user;
                currentUserIsLoaded = true;
              });
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: buildAppBar(),
        body: chatsIsLoaded == false ||
                currentUserIsLoaded == false ||
                chatsSnapshotIsLoaded == false
            ? Center(
                child: Image.asset(
                  'assets/images/loading-2.gif',
                ),
              )
            : InkWell(
                onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
                child: Column(
                  children: [
                    showChatMessages(),
                    buildSenderWidget(),
                  ],
                ),
              ),
      ),
    );
  }
}
