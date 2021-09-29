import 'package:chat_corner/business_logic/bloc/chatBloc/chat_bloc.dart';
import 'package:chat_corner/business_logic/bloc/userBloc/user_bloc.dart';
import 'package:chat_corner/constants/strings.dart';
import 'package:chat_corner/data/models/user.dart';
import 'package:chat_corner/presentation/screens/auth_screens/sign_up_screen.dart';
import 'package:chat_corner/presentation/screens/chat_screens/chat_messages_screen.dart';
import 'package:chat_corner/presentation/screens/chat_screens/home_screen.dart';
import 'package:chat_corner/presentation/screens/splash_screens/onboarding_screen.dart';
import 'package:chat_corner/presentation/screens/auth_screens/sign_in_screen.dart';
import 'package:chat_corner/presentation/screens/splash_screens/splash_screen.dart';
import 'package:chat_corner/presentation/screens/splash_screens/welcome_screen.dart';
import 'package:chat_corner/presentation/screens/user_screens/image_profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppRoute {
  static Route? generateRoute(RouteSettings routeSettings) {
    String? routeName = routeSettings.name;
    switch (routeName) {
      case splashScreen:
        return MaterialPageRoute(
          builder: (context) => SplashScreen(),
        );
      case onBoardingScreen:
        return MaterialPageRoute(
          builder: (context) => OnBoardingScreen(),
        );
      case welcomeScreen:
        return MaterialPageRoute(
          builder: (context) => WelcomeScreen(),
        );
      case signInScreen:
        return MaterialPageRoute(
          builder: (context) => BlocProvider<UserBloc>(
            create: (context) => UserBloc(),
            child: SignInScreen(),
          ),
        );
      case signUpScreen:
        return MaterialPageRoute(
          builder: (context) => BlocProvider<UserBloc>(
            create: (context) => UserBloc(),
            child: SignUpScreen(),
          ),
        );
      case imageProfileScreen:
        return MaterialPageRoute(
          builder: (context) => BlocProvider<UserBloc>(
            create: (context) => UserBloc(),
            child: ImageProfileScreen(),
          ),
        );
      case homeScreen:
        return MaterialPageRoute(
          builder: (context) => HomeScreen(),
        );
      case chatMessagesScreen:
        var recievedUser = routeSettings.arguments as User;
        return MaterialPageRoute(
          builder: (context) => MultiBlocProvider(
            providers: [
              BlocProvider<ChatBloc>(
                create: (context) => ChatBloc(),
              ),
              BlocProvider<UserBloc>(
                create: (context) => UserBloc(),
              ),
            ],
            child: ChatMessagesScreen(recievedUser: recievedUser),
          ),
        );
      default:
    }
  }
}
