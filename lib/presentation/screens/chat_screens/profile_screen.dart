import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_corner/business_logic/bloc/userBloc/user_bloc.dart';
import 'package:chat_corner/constants/colors.dart';
import 'package:chat_corner/constants/sizes.dart';
import 'package:chat_corner/constants/strings.dart';
import 'package:chat_corner/data/models/user.dart';
import 'package:chat_corner/helpers/shared_preference.dart';
import 'package:chat_corner/helpers/strings_to_title_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserBloc _userBloc;
  late String imageUrl;
  late User user;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  bool passwordIsVisible = false;
  bool controllersWithValues = false;
  bool saveImageToFireStore = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userBloc = BlocProvider.of<UserBloc>(context);
    _userBloc.add(GetUserInformation());
  }

  Widget getUserImageProfile() {
    return Container(
        padding: EdgeInsets.all(10.0),
        width: ScreenSize.getWidthtScreen(context) * 0.33,
        height: ScreenSize.getHeightScreen(context) * 0.2,
        margin: EdgeInsets.fromLTRB(
            2, (ScreenSize.getHeightScreen(context) * 0.08) / 2, 5, 2),
        child: CachedNetworkImage(
          imageUrl: user.imageUrl.toString(),
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
        ));
  }

  /*  Future<ui.Image> getImage(String path) async {
    Completer<ImageInfo> completer = Completer();
    var img = new NetworkImage(path);
    img
        .resolve(ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info);
    }));
    ImageInfo imageInfo = await completer.future;
    return imageInfo.image;
  } */

  void _imagePicker(ImageSource source) async {
    try {
      final ImagePicker imagePicker = ImagePicker();
      final pickedFile = await imagePicker.pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 100,
      );
      if (pickedFile != null) {
        File? croppedImage = await ImageCropper.cropImage(
          sourcePath: pickedFile.path,
          maxHeight: 600,
          maxWidth: 400,
          aspectRatioPresets: [CropAspectRatioPreset.square],
          compressQuality: 100,
        );
        if (croppedImage != null) {
          _userBloc.add(SaveImageProfileToFireStorage(imageFile: croppedImage));
          _userBloc.add(GetUserInformation());
          setState(() {
            saveImageToFireStore = true;
          });
        }
      }
    } catch (e) {
      print("error " + e.toString());
    }
    Navigator.of(context).pop();
  }

  void buildAlertDialog() {
    var alertDialog = AlertDialog(
      title: Text("Message"),
      content: Text("Do you want logout ?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("No"),
        ),
        TextButton(
          onPressed: () async {
            _userBloc.add(SignOutUser());
          },
          child: Text("Yes"),
        ),
      ],
    );
    showDialog(
      context: context,
      builder: (context) => alertDialog,
    );
  }

  PreferredSizeWidget buildAppBar() {
    return AppBar(
      title: Text(
        'Profile',
        style: TextStyle(
          color: Colors.black,
          fontSize: 23,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            Icons.logout,
            color: Colors.black,
            size: 22,
          ),
          onPressed: () {
            buildAlertDialog();
          },
        ),
      ],
    );
  }

  void _buildBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Container(
              child: Wrap(
            children: [
              ListTile(
                leading: Icon(
                  Icons.photo_album,
                ),
                title: Text("Photos Gallery"),
                onTap: () {
                  _imagePicker(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.camera_alt_outlined,
                ),
                title: Text("Camera"),
                onTap: () {
                  _imagePicker(ImageSource.camera);
                },
              ),
            ],
          )),
        );
      },
    );
  }

  Widget buildTextField(TextEditingController controller,
      TextInputType inputType, String placeHolder) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
      child: TextField(
        controller: controller,
        obscureText: controller == passController ? !passwordIsVisible : false,
        keyboardType: inputType,
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
        ),
        decoration: InputDecoration(
          hintText: placeHolder,
          hintStyle: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
          suffix: controller == passController
              ? (passwordIsVisible == false
                  ? InkWell(
                      onTap: () {
                        setState(() {
                          passwordIsVisible = true;
                        });
                      },
                      child: Icon(
                        Icons.visibility_off,
                        color: Colors.black,
                      ),
                    )
                  : InkWell(
                      onTap: () {
                        setState(() {
                          passwordIsVisible = false;
                        });
                      },
                      child: Icon(
                        Icons.visibility,
                        color: Colors.black,
                      ),
                    ))
              : null,
        ),
      ),
    );
  }

  Widget buildCard(TextEditingController controller, TextInputType inputType,
      String title, String value) {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 5, 20, 5),
      width: ScreenSize.getWidthtScreen(context),
      child: Card(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 5),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCardWithTextField(
      TextEditingController controller, TextInputType inputType, String title) {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 5, 20, 5),
      width: ScreenSize.getWidthtScreen(context),
      child: Card(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              buildTextField(controller, inputType, "enter your $title"),
            ],
          ),
        ),
      ),
    );
  }

  void buildSnackBar(String msg) {
    var snackBar = SnackBar(
      content: Text(msg),
      elevation: 0,
      duration: Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget buildProfileHeader() {
    return Container(
      height: 220,
      margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
      child: Stack(
        children: [
          Container(
            height: 250,
          ),
          Column(
            children: [
              Stack(
                fit: StackFit.loose,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        child: getUserImageProfile(),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 100.0, left: 90.0),
                        child: GestureDetector(
                          onTap: () => _buildBottomSheet(context),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                child: Text(
                  convertStringToTitleCase(user.fullName),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildProfileScreenBody() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(),
      body: saveImageToFireStore == true
          ? Center(
              child: Image.asset('assets/images/loading-2.gif'),
            )
          : BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state is UserInfoIsAvailable) {
                  user = state.user;
                  if (controllersWithValues == false) {
                    nameController.text =
                        convertStringToTitleCase(user.fullName);
                    emailController.text = user.email;
                    addressController.text =
                        convertStringToTitleCase(user.address);
                    phoneController.text = user.phone;
                    passController.text = user.password;
                    controllersWithValues = true;
                  }
                  return GestureDetector(
                    onTap: () =>
                        FocusScope.of(context).requestFocus(FocusNode()),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          buildProfileHeader(),
                          Container(
                            child: Column(
                              children: [
                                buildCardWithTextField(
                                  nameController,
                                  TextInputType.text,
                                  "Name",
                                ),
                                buildCard(
                                  emailController,
                                  TextInputType.emailAddress,
                                  "E-mail",
                                  user.email,
                                ),
                                buildCardWithTextField(
                                  passController,
                                  TextInputType.visiblePassword,
                                  "Passowrd",
                                ),
                                buildCardWithTextField(
                                  addressController,
                                  TextInputType.streetAddress,
                                  "Address",
                                ),
                                user.phone == "null"
                                    ? Container()
                                    : buildCardWithTextField(
                                        phoneController,
                                        TextInputType.phone,
                                        "Phone",
                                      ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(bottom: 10),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(30),
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        String name = nameController.text;
                                        String email = user.email;
                                        String password = passController.text;
                                        String address = addressController.text;
                                        String phone = phoneController.text;
                                        if (name.isEmpty) {
                                          buildSnackBar(
                                              "your name is required");
                                        } else if (password.isEmpty) {
                                          buildSnackBar(
                                              "your password is required");
                                        } else if (address.isEmpty) {
                                          buildSnackBar(
                                              "your address is required");
                                        } else if (phone.isEmpty) {
                                          buildSnackBar(
                                              "your phone is required");
                                        } else {
                                          User updatedUser = User.withData(
                                            fullName: name,
                                            email: email,
                                            password: password,
                                            address: address,
                                            phone: phone,
                                            imageUrl: user.imageUrl,
                                          );
                                          _userBloc.add(
                                            UpdateUserInformation(
                                              updatedUser: updatedUser,
                                            ),
                                          );
                                          setState(() {
                                            _userBloc.add(GetUserInformation());
                                          });
                                        }
                                      },
                                      style: ButtonStyle(
                                        padding: MaterialStateProperty.all(
                                          EdgeInsets.fromLTRB(35, 10, 35, 10),
                                        ),
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                          MyColor.navyBlue,
                                        ),
                                      ),
                                      child: Text(
                                        "Save",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontFamily: "LobsterTwo",
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Center(
                    child: Image.asset('assets/images/loading-2.gif'),
                  );
                }
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) async {
        if (state is UserIsSignOut) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil(signInScreen, (route) => false);
        } else if (state is ImageProfileIsSavedToFireStorage) {
          buildSnackBar("Your image saved successfully...");
          setState(() {
            saveImageToFireStore = false;
          });
        } else if (state is UserInformationUpdated) {
          buildSnackBar("Your information updated ...");
        }
      },
      child: buildProfileScreenBody(),
    );
  }
}
/*
return */