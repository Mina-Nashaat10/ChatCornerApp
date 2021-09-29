import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_corner/business_logic/bloc/chatBloc/chat_bloc.dart';
import 'package:chat_corner/constants/colors.dart';
import 'package:chat_corner/constants/strings.dart';
import 'package:chat_corner/data/models/chat.dart';
import 'package:chat_corner/data/models/user.dart';
import 'package:chat_corner/helpers/shared_preference.dart';
import 'package:chat_corner/helpers/strings_to_title_case.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<User> myFriends = [];
  List<Chat> lastMessages = [];
  late ChatBloc _chatBloc;
  String myEmail = "";
  late Stream<QuerySnapshot> _querySnapshot;
  bool snapShotLoaded = false;
  List<Chat> searchLastMessagesList = [];
  bool lastMessageWithMyFriendsIsLoaded = false;
  var searchBarController = TextEditingController();
  bool searchBarIsActive = false;
  var focusNode = FocusNode();

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _chatBloc = BlocProvider.of<ChatBloc>(context);
    _chatBloc.add(GetChatsSnapshot());
    _chatBloc.add(GetMyFriendsWithLastMessage());
    myEmail = await SharedPreference.getUserEmail();
  }

  Widget getUserImageProfile() {
    return FutureBuilder(
      builder: (context, snapshot) {
        Widget widget;
        if (snapshot.hasData) {
          widget = Container(
            width: 45,
            height: 45,
            margin: EdgeInsets.fromLTRB(2, 2, 5, 2),
            child: CachedNetworkImage(
              imageUrl: snapshot.data.toString(),
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
          );
        } else {
          widget = Image.asset(
            'assets/images/profile-loading.gif',
            width: 40,
            height: 40,
          );
        }
        return widget;
      },
      future: SharedPreference.getImageProfile(),
    );
  }

  PreferredSizeWidget buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: Text(
        'Conversations',
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          letterSpacing: 1.5,
        ),
      ),
      bottom: buildSearchBar(),
      elevation: 0,
      actions: [
        Container(
          child: IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.black,
              size: 25,
            ),
            onPressed: () {
              FocusScope.of(context).requestFocus(focusNode);
              setState(() {
                searchBarIsActive = true;
              });
            },
          ),
        ),
        getUserImageProfile(),
      ],
    );
  }

  void searchFun(String query) {
    searchLastMessagesList = [];
    String friendEmail;
    lastMessages.forEach((element) {
      if (element.sender == myEmail) {
        friendEmail = element.receiver;
      } else {
        friendEmail = element.sender;
      }
      if (getFullName(friendEmail)
          .toLowerCase()
          .contains(query.toLowerCase())) {
        searchLastMessagesList.add(element);
      }
    });
  }

  PreferredSizeWidget buildSearchBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight),
      child: Container(
        height: 45,
        margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: TextField(
          focusNode: focusNode,
          controller: searchBarController,
          autocorrect: true,
          cursorColor: Colors.black,
          onChanged: (value) {
            setState(() {
              searchFun(value);
            });
          },
          onTap: () {
            setState(() {
              searchBarIsActive = true;
            });
          },
          onSubmitted: (value) {
            setState(() {
              searchBarIsActive = false;
              searchLastMessagesList = [];
              searchLastMessagesList.addAll(lastMessages);
              searchBarController.text = "";
            });
          },
          decoration: InputDecoration(
            hintText: "search...",
            hintStyle: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
              height: 1,
            ),
            isDense: true,
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey.shade600,
            ),
            fillColor: Colors.grey.shade100,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide(
                width: 0,
                style: BorderStyle.none,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String getFullName(String email) {
    String fullName = "";
    myFriends.forEach((element) {
      if (element.email == email) {
        fullName = element.fullName;
      }
    });
    //date = DateFormat('hh:mm a').format(element.dateTime);
    return fullName;
  }

  String getImageUrl(String email) {
    String imageUrl = "";
    myFriends.forEach((element) {
      if (element.email == email) {
        imageUrl = element.imageUrl!;
      }
    });
    //date = DateFormat('hh:mm a').format(element.dateTime);
    return imageUrl;
  }

  User getUser(String email) {
    late User user;
    myFriends.forEach((element) {
      if (element.email == email) {
        user = element;
      }
    });
    return user;
  }

  Widget buildMyChatsWidget() {
    if (searchLastMessagesList.isEmpty) {
      return Text(
        'No Chats',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      );
    } else {
      return ListView.builder(
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              searchBarController.text = "";
              FocusScope.of(context).requestFocus(FocusNode());
              Navigator.of(context).pushNamed(
                chatMessagesScreen,
                arguments: searchLastMessagesList[index].sender == myEmail
                    ? getUser(searchLastMessagesList[index].receiver)
                    : getUser(searchLastMessagesList[index].sender),
              );
            },
            child: ListTile(
              leading: Container(
                width: 50,
                height: 50,
                child: CachedNetworkImage(
                  imageUrl: searchLastMessagesList[index].sender == myEmail
                      ? getImageUrl(
                          searchLastMessagesList[index].receiver.toString())
                      : getImageUrl(
                          searchLastMessagesList[index].sender.toString()),
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
              title: Text(
                searchLastMessagesList[index].sender == myEmail
                    ? convertStringToTitleCase(getFullName(
                        searchLastMessagesList[index].receiver.toString()))
                    : convertStringToTitleCase(getFullName(
                        searchLastMessagesList[index].sender.toString())),
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: "LobsterTwo",
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              subtitle: Container(
                margin: EdgeInsets.only(left: 4),
                child: Text(
                  searchLastMessagesList[index].message,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              trailing: Text(
                DateFormat('hh:mm a')
                    .format(searchLastMessagesList[index].dateTime),
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
        itemCount: searchLastMessagesList.length,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state is ChatsSnapshotLoaded) {
          _querySnapshot = state.chatsSnapshot;
          snapShotLoaded = true;
        }
        if (state is MyFriendsListWithLastMessageIsLoaded) {
          setState(() {
            myFriends = state.map['my_friends'];
            lastMessages = state.map['last_message'];
            searchLastMessagesList = [];
            searchLastMessagesList = lastMessages;
            lastMessageWithMyFriendsIsLoaded = true;
          });
        }
      },
      child: InkWell(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Scaffold(
          appBar: buildAppBar(),
          backgroundColor: Colors.white,
          body: snapShotLoaded == false
              ? Center(
                  child: Image.asset(
                    'assets/images/loading-2.gif',
                  ),
                )
              : Center(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _querySnapshot,
                    builder: (context, snapshot) {
                      if (searchBarIsActive == false) {
                        _chatBloc.add(GetMyFriendsWithLastMessage());
                      }
                      if (lastMessageWithMyFriendsIsLoaded == true) {
                        return buildMyChatsWidget();
                      } else {
                        return Image.asset(
                          'assets/images/loading-2.gif',
                        );
                      }
                    },
                  ),
                ),
        ),
      ),
    );
  }
}
/*
if (snapShotLoaded == false) {
      return BlocListener<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatsSnapshotLoaded) {
            setState(() {
              _querySnapshot = state.chatsSnapshot;
              snapShotLoaded = true;
            });
          }
        },
        child: Scaffold(
          appBar: buildAppBar(),
          backgroundColor: Colors.white,
          body: Center(
            child: Image.asset(
              'assets/images/loading-2.gif',
            ),
          ),
        ),
      );
    } else {
      return InkWell(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Scaffold(
          appBar: buildAppBar(),
          backgroundColor: Colors.white,
          body: Center(
            child: StreamBuilder<QuerySnapshot>(
                stream: _querySnapshot,
                builder: (context, snapshot) {
                  //_chatBloc.add(GetMyFriendsWithLastMessage());
                  if (snapshot.hasData) {
                    return BlocBuilder<ChatBloc, ChatState>(
                      builder: (context, state) {
                        if (state is MyFriendsListWithLastMessageIsLoaded) {
                          myFriends = state.map['my_friends'];
                          searchFriendsList = myFriends;
                          lastMessages = state.map['last_message'];
                          return buildMyChatsWidget();
                        } else {
                          return Image.asset(
                            'assets/images/loading-2.gif',
                          );
                        }
                      },
                    );
                  } else {
                    return Image.asset(
                      'assets/images/loading-2.gif',
                    );
                  }
                }),
          ),
        ),
      );*/