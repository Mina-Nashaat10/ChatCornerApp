import 'package:chat_corner/constants/colors.dart';
import 'package:chat_corner/constants/sizes.dart';
import 'package:chat_corner/constants/strings.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  Widget buildScreenButton(
      String btnText, Color btnColor, Color txtColor, Function()? btnAction) {
    return Container(
      width: ScreenSize.getWidthtScreen(context) * 0.7,
      height: ScreenSize.getHeightScreen(context) * 0.07,
      child: ClipRRect(
        borderRadius: BorderRadius.all(
          Radius.circular(30),
        ),
        child: ElevatedButton(
          onPressed: btnAction,
          child: Text(
            btnText,
            style: TextStyle(
              color: txtColor,
              fontSize: 18,
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
          ),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(
              btnColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildScreenBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          alignment: Alignment.center,
          margin: EdgeInsets.fromLTRB(10, 100, 10, 0),
          child: Text(
            "Welecome to Chat Corner",
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          alignment: Alignment.center,
          margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: Image.asset(
            'assets/images/welcome_screen.jpg',
            height: ScreenSize.getHeightScreen(context) * 0.55,
            width: ScreenSize.getWidthtScreen(context) * 0.9,
            fit: BoxFit.cover,
          ),
        ),
        buildScreenButton(
          "Sign in",
          MyColor.violet,
          MyColor.white,
          () => Navigator.of(context).pushNamed(signInScreen),
        ),
        SizedBox(
          height: 15,
        ),
        buildScreenButton(
          "Sign up",
          MyColor.greyWithOpacity,
          Colors.black,
          () => Navigator.of(context).pushNamed(signUpScreen),
        ),
      ],
    );
  }

  Widget buildWelcomeScreen() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: 0,
          left: 0,
          child: Image.asset(
            'assets/images/welcome_top.png',
            width: ScreenSize.getWidthtScreen(context) * 0.3,
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: Image.asset(
            'assets/images/welcome_bottom.png',
            width: ScreenSize.getWidthtScreen(context) * 0.2,
          ),
        ),
        buildScreenBody(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: buildWelcomeScreen(),
      ),
    );
  }
}
