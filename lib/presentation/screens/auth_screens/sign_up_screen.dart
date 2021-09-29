import 'package:chat_corner/business_logic/bloc/userBloc/user_bloc.dart';
import 'package:chat_corner/constants/colors.dart';
import 'package:chat_corner/constants/sizes.dart';
import 'package:chat_corner/constants/strings.dart';
import 'package:chat_corner/data/models/user.dart' as models;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var passController = TextEditingController();
  var addressController = TextEditingController();
  var phoneController = TextEditingController();
  GlobalKey<FormState> signUpFormKey = GlobalKey();
  var nameNode = FocusNode();
  var emailNode = FocusNode();
  var passNode = FocusNode();
  var addressNode = FocusNode();
  var phoneNode = FocusNode();
  bool passVisible = false;
  late UserBloc userBloc;
  bool signUpIsPressed = false;
  bool formValidation = false;

  @override
  void initState() {
    super.initState();
    userBloc = BlocProvider.of<UserBloc>(context);
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    passController.dispose();
    nameNode.dispose();
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
      margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
      width: ScreenSize.getWidthtScreen(context) * 0.90,
      child: TextFormField(
        onTap: () {
          if (formValidation == true) {
            signUpFormKey.currentState!.reset();
            setState(() {
              formValidation = false;
            });
          }
        },
        maxLength: controller == phoneController ? 11 : null,
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
        onFieldSubmitted: (value) => controller == phoneController
            ? FocusScope.of(context).unfocus()
            : FocusScope.of(context).requestFocus(nextNode),
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

  Widget buildOrDivider() {
    return Container(
      margin: EdgeInsets.fromLTRB(40, 10, 40, 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Divider(
              color: Colors.black,
              thickness: 1,
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            "OR",
            style: TextStyle(
              color: MyColor.violet,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Expanded(
            child: Divider(
              color: Colors.black,
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget socialWidget(String socialImage, Function()? socialAction) {
    return GestureDetector(
      onTap: socialAction,
      child: Container(
        margin: EdgeInsets.fromLTRB(15, 0, 15, 10),
        width: 52,
        height: 52,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: MyColor.grey,
          ),
          shape: BoxShape.circle,
        ),
        child: SvgPicture.asset(
          socialImage,
        ),
      ),
    );
  }

  Widget buildSocialMediaWidget() {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 30),
      child: ClipRRect(
        borderRadius: BorderRadius.all(
          Radius.circular(30),
        ),
        child: ElevatedButton.icon(
          onPressed: () {
            userBloc.add(SignInUserWithGoogle());
            setState(() {
              signUpIsPressed = false;
            });
          },
          style: ButtonStyle(
            padding: MaterialStateProperty.all(
              EdgeInsetsDirectional.fromSTEB(15, 7, 15, 7),
            ),
            backgroundColor: MaterialStateProperty.all(Colors.grey.shade400),
          ),
          icon: SvgPicture.asset(
            'assets/icons/google.svg',
            height: 30,
            width: 30,
          ),
          label: Text(
            "Sign in with google",
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSignUpForm() {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        return Form(
          key: signUpFormKey,
          child: Column(
            children: [
              signInTextFormField(
                controller: nameController,
                secureText: false,
                textInputType: TextInputType.name,
                hintText: "Enter your name",
                errorText: "Your name is required",
                node: nameNode,
                iconData: Icons.person,
                nextNode: emailNode,
              ),
              signInTextFormField(
                controller: emailController,
                secureText: false,
                textInputType: TextInputType.emailAddress,
                hintText: "Enter your email",
                errorText: "Your email is required",
                node: emailNode,
                iconData: Icons.email,
                nextNode: passNode,
              ),
              signInTextFormField(
                controller: passController,
                secureText: true,
                textInputType: TextInputType.visiblePassword,
                hintText: "Enter your password",
                errorText: "Your password is required",
                node: passNode,
                iconData: Icons.lock,
                nextNode: addressNode,
              ),
              signInTextFormField(
                controller: addressController,
                secureText: false,
                textInputType: TextInputType.streetAddress,
                hintText: "Enter your address",
                errorText: "Your address is required",
                node: addressNode,
                iconData: Icons.location_city,
                nextNode: phoneNode,
              ),
              signInTextFormField(
                controller: phoneController,
                secureText: false,
                textInputType: TextInputType.phone,
                hintText: "Enter your phone",
                errorText: "Your phone is required",
                node: phoneNode,
                iconData: Icons.phone,
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                width: ScreenSize.getWidthtScreen(context) * 0.5,
                height: ScreenSize.getHeightScreen(context) * 0.08,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(
                    Radius.circular(30),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        formValidation = true;
                      });
                      if (signUpFormKey.currentState!.validate()) {
                        String userName = nameController.text.toString();
                        String userEmail = emailController.text.toString();
                        String userPassword = passController.text.toString();
                        String userAddress = addressController.text.toString();
                        String userPhone = phoneController.text.toString();
                        if (!userName.contains(" ")) {
                          buildSnackBar(
                              "Please enter your first name & last name");
                        } else if (phoneController.text.length != 11) {
                          buildSnackBar("Please enter correct phone");
                        } else {
                          models.User user = models.User.withData(
                            fullName: userName,
                            email: userEmail,
                            password: userPassword,
                            address: userAddress,
                            phone: userPhone,
                          );
                          userBloc
                              .add(SignUpUserWithEmailAndPassword(user: user));
                          setState(() {
                            signUpIsPressed = true;
                          });
                        }
                      }
                    },
                    child: Text(
                      "Sign up",
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
              SizedBox(
                height: 7,
              ),
              signUpIsPressed == true
                  ? Image.asset('assets/images/loading-2.gif')
                  : Container(),
              SizedBox(
                height: 7,
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an Account ? ",
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(signInScreen)
                            .then((value) {
                          signUpFormKey.currentState?.reset();
                          nameController.text = "";
                          emailController.text = "";
                          passController.text = "";
                        });
                      },
                      child: Text(
                        "Sign in",
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
                height: 10,
              ),
              buildOrDivider(),
              buildSocialMediaWidget(),
            ],
          ),
        );
      },
    );
  }

  Widget buildSignUpBody() {
    return ListView(
      children: [
        Container(
          alignment: Alignment.center,
          margin: EdgeInsets.fromLTRB(0, 25, 0, 0),
          child: Text(
            "Sign up",
            style: TextStyle(
              fontSize: 22,
              color: MyColor.violet,
            ),
          ),
        ),
        Container(
          child: Image.asset(
            'assets/images/signup_screen.jpg',
            height: ScreenSize.getHeightScreen(context) * 0.35,
            width: ScreenSize.getWidthtScreen(context) * 0.9,
            fit: BoxFit.cover,
          ),
        ),
        buildSignUpForm(),
      ],
    );
  }

  Widget buildSignUpScreen() {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          width: ScreenSize.getWidthtScreen(context) * 0.20,
          child: Image.asset(
            'assets/images/signup_top.png',
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          width: ScreenSize.getWidthtScreen(context) * 0.25,
          child: Image.asset(
            'assets/images/welcome_bottom.png',
          ),
        ),
        buildSignUpBody(),
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
        if (state is UserIsSignUpWithEmailAndPassword) {
          setState(() {
            signUpIsPressed = false;
          });
          String result = state.result;
          if (result == "Sign up Successed") {
            buildSnackBar(result + "...");
            Navigator.of(context)
                .pushNamedAndRemoveUntil(imageProfileScreen, (route) => false);
          } else {
            buildSnackBar(result);
            setState(() {
              signUpIsPressed = false;
            });
          }
        } else if (state is UserIsSignInWithGoogle) {
          setState(() {
            signUpIsPressed = false;
          });
          bool result = state.result;
          if (result) {
            buildSnackBar("Signed in with google successfully...");
            Navigator.of(context)
                .pushNamedAndRemoveUntil(homeScreen, (route) => false);
          } else {
            buildSnackBar("Failed to signed in with google...");
            setState(() {
              signUpIsPressed = false;
            });
          }
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Scaffold(
          backgroundColor: MyColor.white,
          body: buildSignUpScreen(),
        ),
      ),
    );
  }
}
