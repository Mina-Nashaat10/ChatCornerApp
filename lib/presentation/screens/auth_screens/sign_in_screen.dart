import 'package:chat_corner/business_logic/bloc/userBloc/user_bloc.dart';
import 'package:chat_corner/constants/colors.dart';
import 'package:chat_corner/constants/sizes.dart';
import 'package:chat_corner/constants/strings.dart';
import 'package:chat_corner/data/models/user.dart';
import 'package:chat_corner/helpers/shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  var emailController = TextEditingController();
  var passController = TextEditingController();
  GlobalKey<FormState> signInFormKey = GlobalKey();
  var emailNode = FocusNode();
  var passNode = FocusNode();
  bool passVisible = false;
  late UserBloc _userBloc;
  bool waitingToSignIn = false;
  bool formValidation = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userBloc = BlocProvider.of<UserBloc>(context);
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passController.dispose();
    emailNode.dispose();
    passNode.dispose();
  }

  Widget signInTextFormField(
      {required TextEditingController controller,
      required bool secureText,
      required TextInputType? textInputType,
      required String hintText,
      required String errorText,
      required FocusNode node,
      required IconData iconData,
      FocusNode? nextNode}) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
      width: ScreenSize.getWidthtScreen(context) * 0.90,
      child: TextFormField(
        onTap: () {
          if (formValidation == true) {
            signInFormKey.currentState!.reset();
            setState(() {
              formValidation = false;
            });
          }
        },
        autocorrect: true,
        focusNode: node,
        obscureText: controller == passController ? !passVisible : secureText,
        controller: controller,
        cursorColor: MyColor.blueGrotto,
        cursorHeight: 25,
        cursorWidth: 2,
        keyboardType: textInputType,
        maxLines: 1,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 20),
          hintText: hintText,
          hintMaxLines: 1,
          hintStyle: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade400,
          ),
          errorStyle: TextStyle(
            color: Colors.red,
            fontSize: 11,
            fontWeight: FontWeight.normal,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            gapPadding: 10,
          ),
          prefixIcon: Icon(
            iconData,
            color: MyColor.violet,
          ),
          suffixIcon: controller == passController
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      passVisible = !passVisible;
                    });
                  },
                  icon: passVisible == true
                      ? Icon(
                          Icons.visibility,
                          size: 22,
                          color: MyColor.violet,
                        )
                      : Icon(
                          Icons.visibility_off,
                          size: 22,
                          color: MyColor.violet,
                        ),
                )
              : null,
        ),
        onFieldSubmitted: (value) => controller == emailController
            ? FocusScope.of(context).requestFocus(nextNode)
            : FocusScope.of(context).unfocus(),
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        showCursor: true,
        validator: (value) {
          if (value!.isEmpty) {
            return errorText;
          }
        },
      ),
    );
  }

  Widget buildSignInBody() {
    return ListView(
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(0, 47, 0, 15),
          alignment: Alignment.center,
          child: Text(
            "Sign In",
            style: TextStyle(
              fontSize: 20,
              color: MyColor.violet,
            ),
          ),
        ),
        Container(
          alignment: Alignment.center,
          margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: Image.asset(
            'assets/images/signin_screen.jpg',
            height: ScreenSize.getHeightScreen(context) * 0.35,
            width: ScreenSize.getWidthtScreen(context) * 0.9,
            fit: BoxFit.cover,
          ),
        ),
        Container(
          child: Form(
            key: signInFormKey,
            child: Column(
              children: [
                signInTextFormField(
                  controller: emailController,
                  secureText: false,
                  textInputType: TextInputType.emailAddress,
                  hintText: "Enter your email address",
                  errorText: "Email address is required",
                  node: emailNode,
                  iconData: Icons.email,
                  nextNode: passNode,
                ),
                SizedBox(
                  height: 10,
                ),
                signInTextFormField(
                  controller: passController,
                  secureText: true,
                  textInputType: TextInputType.visiblePassword,
                  hintText: "Enter your password",
                  errorText: "Password is required",
                  node: passNode,
                  iconData: Icons.lock,
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: ScreenSize.getWidthtScreen(context) * 0.5,
                  height: ScreenSize.getHeightScreen(context) * 0.08,
                  margin: EdgeInsets.only(bottom: 15),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(
                      Radius.circular(30),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          formValidation = true;
                        });
                        if (signInFormKey.currentState!.validate()) {
                          String userEmail = emailController.text.toString();
                          String userPassword = passController.text.toString();
                          _userBloc.add(
                            SignInUserWithEmailAndPassword(
                              email: userEmail,
                              password: userPassword,
                            ),
                          );
                          _userBloc.add(GetUserInformation());
                          setState(() {
                            waitingToSignIn = true;
                          });
                        }
                      },
                      child: Text(
                        "Sign in",
                        style: TextStyle(
                          color: MyColor.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          MyColor.violet,
                        ),
                      ),
                    ),
                  ),
                ),
                waitingToSignIn == true
                    ? Image.asset(
                        'assets/images/loading-2.gif',
                      )
                    : Container(),
                SizedBox(
                  height: 7,
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an Account ? ",
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed(signUpScreen)
                              .then((value) {
                            signInFormKey.currentState?.reset();
                            emailController.text = "";
                            passController.text = "";
                          });
                        },
                        child: Text(
                          "Sign up",
                          style: TextStyle(
                            color: MyColor.violet,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSignInScreen() {
    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          child: Image.asset('assets/images/welcome_top.png'),
          width: ScreenSize.getWidthtScreen(context) * 0.25,
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Image.asset('assets/images/signin_bottom.png'),
          width: ScreenSize.getWidthtScreen(context) * 0.40,
        ),
        buildSignInBody(),
      ],
    );
  }

  void buildSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) async {
        String result;
        if (state is UserIsSignInWithEmailAndPassword) {
          result = state.result;
          if (result == "Sign in Successed") {
            buildSnackBar(result + "...");
          } else {
            buildSnackBar(result);
            setState(() {
              waitingToSignIn = false;
            });
          }
        } else if (state is UserInfoIsAvailable) {
          bool userIsLogin = await SharedPreference.checkUserIfLoginOrNot();
          if (userIsLogin) {
            User user = User();
            user = state.user;
            if (user.imageUrl == null || user.imageUrl == "") {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  imageProfileScreen, (route) => false);
            } else {
              await SharedPreference.setImageProfileIsFound(
                  user.imageUrl.toString());
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(homeScreen, (route) => false);
            }
          }
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: buildSignInScreen(),
        ),
      ),
    );
  }
}
