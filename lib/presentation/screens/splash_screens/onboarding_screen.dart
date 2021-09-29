import 'package:chat_corner/constants/colors.dart';
import 'package:chat_corner/constants/strings.dart';
import 'package:chat_corner/helpers/shared_preference.dart';
import 'package:chat_corner/presentation/widgets/splash_screen_list.dart';
import 'package:flutter/material.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  int currentPage = 0;
  PageController pageController = PageController();
  @override
  void initState() {
    super.initState();
    
  }

  Widget buildAnimatedContainer() {
    return Container(
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(
              splashScreenPages.length,
              (index) {
                return AnimatedContainer(
                  duration: Duration(
                    milliseconds: 300,
                  ),
                  height: 10,
                  width: index == currentPage ? 30 : 10,
                  margin: EdgeInsets.fromLTRB(7, 10, 7, 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: index == currentPage
                        ? MyColor.blueGrotto
                        : MyColor.blueGrotto.withOpacity(0.5),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /* 
 ElevatedButton(
                      onPressed: null,
                      child: Text(
                        "Get Started",
                        style: TextStyle(
                          color: MyColor.white,
                          fontSize: 20,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        onPrimary: MyColor.sandDollar,
                        onSurface: MyColor.sandDollar,
                      ),
                    )
                    */
  Widget buildOnboardingScreen() {
    return Stack(
      children: [
        PageView.builder(
          scrollDirection: Axis.horizontal,
          controller: pageController,
          itemCount: splashScreenPages.length,
          onPageChanged: (value) {
            setState(() {
              currentPage = value;
            });
          },
          itemBuilder: (context, index) {
            return splashScreenPages[index];
          },
        ),
        buildAnimatedContainer(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.white,
      body: buildOnboardingScreen(),
      floatingActionButton: currentPage == 2
          ? FloatingActionButton(
              onPressed: () async {
                await SharedPreference.setOnBoardingScreenIsShowing();
                Navigator.of(context).pushNamed(welcomeScreen);
              },
              child: Icon(
                Icons.keyboard_arrow_right_outlined,
                size: 32,
              ),
            )
          : Container(),
    );
  }
}
