import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_corner/business_logic/bloc/chatBloc/chat_bloc.dart';
import 'package:chat_corner/business_logic/bloc/userBloc/user_bloc.dart';
import 'package:chat_corner/constants/colors.dart';
import 'package:chat_corner/constants/strings.dart';
import 'package:chat_corner/data/models/user.dart';
import 'package:chat_corner/helpers/shared_preference.dart';
import 'package:chat_corner/helpers/strings_to_title_case.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({Key? key}) : super(key: key);

  @override
  _PeopleScreenState createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  late UserBloc _userBloc;
  List<User> _users = [];
  late Stream<QuerySnapshot> _querySnapshot;
  bool snapShotLoaded = false;
  late String myEmail;
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _userBloc = BlocProvider.of<UserBloc>(context);
    _userBloc.add(GetAllUsersSnapShot());
    myEmail = await SharedPreference.getUserEmail();
  }

  PreferredSizeWidget buildAppBar() {
    return AppBar(
      title: Text(
        "People",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          color: Colors.black,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.white,
    );
  }

  Widget showPeopleWidget() {
    if (_users.isEmpty) {
      return Center(
        child: Text(
          "No People",
          style: TextStyle(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else {
      return ListView.builder(
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => Navigator.of(context)
                .pushNamed(chatMessagesScreen, arguments: _users[index]),
            child: Container(
              margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  child: CachedNetworkImage(
                    imageUrl: _users[index].imageUrl.toString(),
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
                  convertStringToTitleCase(
                    _users[index].fullName,
                  ),
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: "LobsterTwo",
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
          );
        },
        itemCount: _users.length,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserSnapshotLoaded) {
          setState(() {
            _querySnapshot = state.usersSnapshot;
            snapShotLoaded = true;
          });
        }
      },
      child: Scaffold(
        appBar: buildAppBar(),
        backgroundColor: Colors.white,
        body: snapShotLoaded == false
            ? Center(
                child: Image.asset('assets/images/loading-2.gif'),
              )
            : StreamBuilder<QuerySnapshot>(
                stream: _querySnapshot,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    _users.clear();
                    snapshot.data!.docs.forEach((element) {
                      Map<dynamic, dynamic> map = element.data() as Map;
                      User _user = User.fromJson(map: map);
                      if (_user.email != myEmail) _users.add(_user);
                    });
                    return showPeopleWidget();
                  } else {
                    return Center(
                      child: Image.asset('assets/images/loading-2.gif'),
                    );
                  }
                },
              ),
      ),
    );
  }
}
/*
if (snapShotLoaded == false) {
      return BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserSnapshotLoaded) {
            setState(() {
              _querySnapshot = state.usersSnapshot;
              snapShotLoaded = true;
            });
          }
        },
        child: Scaffold(
          appBar: buildAppBar(),
          body: Center(
            child: Image.asset('assets/images/loading-2.gif'),
          ),
        ),
      );
    } else {
      return StreamBuilder<QuerySnapshot>(
          stream: _querySnapshot,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              _users.clear();
              snapshot.data!.docs.forEach((element) {
                Map<dynamic, dynamic> map = element.data() as Map;
                User _user = User.fromJson(map: map);
                if (_user.email != myEmail) _users.add(_user);
              });
              return showPeopleWidget();
            } else {
              return Scaffold(
                appBar: buildAppBar(),
                body: Center(
                  child: Image.asset('assets/images/loading-2.gif'),
                ),
              );
            }
          });
    }
    */