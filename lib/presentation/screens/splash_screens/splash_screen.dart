import 'dart:async';
import 'package:chat_corner/business_logic/bloc/chatBloc/chat_bloc.dart';
import 'package:chat_corner/business_logic/bloc/userBloc/user_bloc.dart';
import 'package:chat_corner/constants/colors.dart';
import 'package:chat_corner/constants/sizes.dart';
import 'package:chat_corner/constants/strings.dart';
import 'package:chat_corner/data/models/user.dart';
import 'package:chat_corner/helpers/shared_preference.dart';
import 'package:chat_corner/navigtor_key.dart';
import 'package:chat_corner/presentation/screens/chat_screens/chat_messages_screen.dart';
import 'package:chat_corner/presentation/screens/chat_screens/people_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool showOnBoardingScreen = false;
  bool userIsLogin = false;
  late String imageProfileIsFound;

  @override
  void initState() {
    super.initState();
    configOneSignel();
  }

  void configOneSignel() {
    OneSignal.shared.setAppId('f7c87703-0332-4ad9-a1e1-d324665e9c29');
  }

  Future _getSharedPreferenceValues() async {
    showOnBoardingScreen =
        await SharedPreference.checkOnBoardingScreenIsShowingOrNot();
    userIsLogin = await SharedPreference.checkUserIfLoginOrNot();
    imageProfileIsFound = await SharedPreference.getImageProfile();
  }

  void handleNotificationPressed() {
    OneSignal.shared.setNotificationOpenedHandler((openedResult) {
      Map<String, dynamic>? map = openedResult.notification.additionalData;
      NavigatorKey.navState.currentState!
          .pushNamed(chatMessagesScreen, arguments: User.fromJson(map: (map)!));
    });
  }

  void _nextScreen() {
    Timer.periodic(
        Duration(
          seconds: 5,
        ), (timer) async {
      handleNotificationPressed();

      await _getSharedPreferenceValues();
      if (showOnBoardingScreen == false) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(onBoardingScreen, (route) => false);
      } else if (userIsLogin == false) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(welcomeScreen, (route) => false);
      } else {
        if (imageProfileIsFound == "") {
          Navigator.of(context)
              .pushNamedAndRemoveUntil(imageProfileScreen, (route) => false);
        } else {
          Navigator.of(context)
              .pushNamedAndRemoveUntil(homeScreen, (route) => false);
        }
      }
      timer.cancel();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _nextScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.fromLTRB(
                0, ScreenSize.getHeightScreen(context) * 0.25, 0, 0),
            child: Text(
              "Chat Corner",
              style: TextStyle(
                fontSize: 45,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                fontFamily: 'LobsterTwo',
              ),
            ),
          ),
          Spacer(),
          Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 50),
            alignment: Alignment.bottomCenter,
            child: Image.asset(
              'assets/images/loading-2.gif',
            ),
          ),
        ],
      ),
    );
  }
}
