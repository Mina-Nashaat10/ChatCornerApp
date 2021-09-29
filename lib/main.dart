import 'package:chat_corner/app_route.dart';
import 'package:chat_corner/constants/strings.dart';
import 'package:chat_corner/navigtor_key.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ChatApp());
}

class ChatApp extends StatelessWidget {
   ChatApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Chat Corner",
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigatorKey.navState,
      onGenerateRoute: AppRoute.generateRoute,
      initialRoute: splashScreen,
    );
  }
}