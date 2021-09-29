import 'dart:io';

import 'package:chat_corner/business_logic/bloc/userBloc/user_bloc.dart';
import 'package:chat_corner/constants/colors.dart';
import 'package:chat_corner/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class ImageProfileScreen extends StatefulWidget {
  const ImageProfileScreen({Key? key}) : super(key: key);

  @override
  _ImageProfileScreenState createState() => _ImageProfileScreenState();
}

class _ImageProfileScreenState extends State<ImageProfileScreen> {
  final ImagePicker imagePicker = ImagePicker();
  File? file;
  late UserBloc _userBloc;
  bool nextScreenVisibility = false;
  bool waitingToUploadImage = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userBloc = BlocProvider.of<UserBloc>(context);
  }

  void _imagePicker(ImageSource source) async {
    try {
      final pickedFile = await imagePicker.pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 100,
      );
      if (pickedFile != null) {
        File? croppedImage = await ImageCropper.cropImage(
          sourcePath: pickedFile.path,
          maxHeight: 800,
          maxWidth: 600,
          aspectRatioPresets: [CropAspectRatioPreset.square],
          compressQuality: 100,
        );

        if (croppedImage != null) {
          setState(() {
            file = croppedImage;
            waitingToUploadImage = true;
          });
          _userBloc.add(SaveImageProfileToFireStorage(imageFile: croppedImage));
        }
      }
    } catch (e) {
      print("error " + e.toString());
    }
    Navigator.of(context).pop();
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
                  setState(() {
                    nextScreenVisibility = false;
                  });
                  _imagePicker(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.camera_alt_outlined,
                ),
                title: Text("Camera"),
                onTap: () {
                  setState(() {
                    nextScreenVisibility = false;
                  });
                  _imagePicker(ImageSource.camera);
                },
              ),
            ],
          )),
        );
      },
    );
  }

  Widget buildImageProfileBody() {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        return Container(
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => _buildBottomSheet(context),
                child: Container(
                  width: file == null ? 100 : 150,
                  height: file == null ? 100 : 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(80),
                    ),
                    color: Colors.grey[200],
                    border: Border.all(
                      color: Colors.yellow,
                      width: 3,
                    ),
                  ),
                  child: file == null
                      ? Icon(
                          Icons.camera_alt,
                          color: Colors.grey[800],
                          size: 28,
                        )
                      : CircleAvatar(
                          backgroundImage: FileImage(file!),
                          minRadius: 80,
                          maxRadius: 120,
                        ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Choose your image profile....",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: MyColor.white,
                ),
              ),
              SizedBox(height: 20),
              waitingToUploadImage == true
                  ? Image.asset('assets/images/loading-1.gif')
                  : Container(),
              nextScreenVisibility == true
                  ? Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(
                        top: 15,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(40),
                          ),
                        ),
                        child: ElevatedButton(
                          style: ButtonStyle(
                              padding: MaterialStateProperty.all(
                                EdgeInsets.fromLTRB(40, 10, 40, 10),
                              ),
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.yellow),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                ),
                              )),
                          onPressed: () async {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                homeScreen, (route) => false);
                          },
                          child: Text(
                            'Next',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        );
      },
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
      listener: (context, state) {
        if (state is ImageProfileIsSavedToFireStorage) {
          bool result = state.result;
          if (result) {
            buildSnackBar('Image profile saved...');
            setState(() {
              nextScreenVisibility = true;
              waitingToUploadImage = false;
            });
          } else {
            buildSnackBar('Failed to save image profile...');
          }
        }
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: MyColor.violet,
          body: buildImageProfileBody(),
        ),
      ),
    );
  }
}
