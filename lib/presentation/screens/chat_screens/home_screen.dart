import 'package:chat_corner/business_logic/bloc/chatBloc/chat_bloc.dart';
import 'package:chat_corner/constants/colors.dart';
import 'package:chat_corner/business_logic/bloc/userBloc/user_bloc.dart';
import 'package:chat_corner/data/models/user.dart';
import 'package:chat_corner/presentation/screens/chat_screens/chat_screen.dart';
import 'package:chat_corner/presentation/screens/chat_screens/people_screen.dart';
import 'package:chat_corner/presentation/screens/chat_screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int screenIndex = 0;
  late List<Widget> _widgetsOptions = [
    BlocProvider(
      create: (context) => ChatBloc(),
      child: ChatScreen(),
    ),
    BlocProvider(
      create: (context) => UserBloc(),
      child: PeopleScreen(),
    ),
    BlocProvider(
      create: (context) => UserBloc(),
      child: ProfileScreen(),
    ),
  ];
  String imageProfileUrl = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Widget buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.chat,
          ),
          label: "Chats",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.people,
          ),
          label: "People",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.account_box,
          ),
          label: "Profile",
        ),
      ],
      currentIndex: screenIndex,
      onTap: (value) {
        setState(() {
          screenIndex = value;
        });
      },
      iconSize: 20,
      selectedFontSize: 15,
      unselectedFontSize: 13,
      selectedItemColor: MyColor.violet,
      unselectedItemColor: Colors.black,
      showSelectedLabels: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: buildBottomNavigationBar(),
      body: _widgetsOptions.elementAt(screenIndex),
    );
  }
}
