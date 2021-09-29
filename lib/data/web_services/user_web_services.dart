import 'dart:io';
import 'package:chat_corner/data/models/user.dart' as Models;
import 'package:chat_corner/data/services/google_services.dart';
import 'package:chat_corner/helpers/shared_preference.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class UserWebServices {
  late FirebaseFirestore _firestore;
  late FirebaseAuth _firebaseAuth;
  late GoogleServices googleServices;
  UserWebServices() {
    _firestore = FirebaseFirestore.instance;
    _firebaseAuth = FirebaseAuth.instance;
    googleServices = GoogleServices();
  }
  Future<String> getUserTokenId() async {
    OSDeviceState? osDeviceState = await OneSignal.shared.getDeviceState();
    String tokenId = osDeviceState!.userId!;
    return tokenId;
  }

  Future<String> signUpUser(Models.User user) async {
    String result = "Sign up Failed";
    try {
      UserCredential userIsSignUp =
          await _firebaseAuth.createUserWithEmailAndPassword(
              email: user.email, password: user.password);
      if (userIsSignUp.user != null) {
        String userId = await getUserTokenId();
        user.userToken = userId;
        _firestore.collection("users").add(user.toJson(user));
        result = "Sign up Successed";
        await SharedPreference.setUserEmail(user.email);
        await SharedPreference.setUserAuth(true);
      } else {
        result = "Sign up Failed";
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          result = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          result = 'The account already exists for that email.';
          break;
        case 'invalid-email':
          result = 'Your email is invalid';
          break;
        default:
          result = e.code;
      }
    } on FirebaseException catch (e) {
      result = e.code;
    }
    return result;
  }

  Future updateUserToken(String email) async {
    await _firestore
        .collection("users")
        .where('email', isEqualTo: email)
        .get()
        .then(
          (value) => value.docs.forEach(
            (element) async {
              Models.User user = Models.User.fromJson(map: element.data());
              String newUserToken = await getUserTokenId();
              user.userToken = newUserToken;
              _firestore
                  .collection("users")
                  .doc(element.id)
                  .update(user.toJson(user));
            },
          ),
        );
  }

  Future<String> signInUser(String email, String password) async {
    String result = "Sign in Failed";
    try {
      UserCredential userIsSignUp = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      if (userIsSignUp.user != null) {
        result = "Sign in Successed";
        updateUserToken(email);
        await SharedPreference.setUserEmail(email);
        await SharedPreference.setUserAuth(true);
      } else {
        result = "Sign in Failed";
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "wrong-password":
          result = "Wrong email/password combination.";
          break;
        case "ERROR_USER_NOT_FOUND":
        case "user-not-found":
          result = "No user found with this email.";
          break;
        case "ERROR_USER_DISABLED":
        case "user-disabled":
          result = "User disabled.";
          break;
        case "ERROR_TOO_MANY_REQUESTS":
        case "operation-not-allowed":
          result = "Too many requests to log into this account.";
          break;
        case "ERROR_OPERATION_NOT_ALLOWED":
        case "operation-not-allowed":
          result = "Server error, please try again later.";
          break;
        case "ERROR_INVALID_EMAIL":
        case "invalid-email":
          result = "Email address is invalid.";
          break;
        default:
          result = e.toString();
      }
    }
    return result;
  }

  Future<bool> signInWithGoogle() async {
    User? userLogging = _firebaseAuth.currentUser;
    if (userLogging == null) {
      OAuthCredential credential = await googleServices.signInWithGoogle();
      // Once signed in, return the UserCredential
      UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      User? currentUser = userCredential.user;
      if (currentUser != null) {
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
            .collection("users")
            .where('email', isEqualTo: currentUser.email)
            .get();
        if (querySnapshot.docs.isEmpty) {
          Models.User user = Models.User.withData(
            fullName: currentUser.displayName.toString(),
            email: currentUser.email.toString(),
            password: "empty",
            imageUrl: currentUser.photoURL.toString(),
            address: "empty",
            phone: currentUser.phoneNumber.toString(),
          );
          String userId = await getUserTokenId();
          user.userToken = userId;
          await _firestore.collection("users").add(user.toJson(user));
        }
        await SharedPreference.setUserEmail(currentUser.email.toString());
        await SharedPreference.setUserAuth(true);
        await SharedPreference.setImageProfileIsFound(
            currentUser.photoURL.toString());
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  Future<bool> signOutUserWithGoogle() async {
    bool userIsSignOut = await googleServices.signOutWithGoogle();
    if (userIsSignOut) {
      await _firebaseAuth.signOut();
      await SharedPreference.setImageProfileIsFound("");
      await SharedPreference.setUserAuth(false);
      return true;
    } else {
      return false;
    }
  }

  Future<bool> saveImageProfileToFirebaseStorage(File image) async {
    String email = await SharedPreference.getUserEmail();
    Reference reference = FirebaseStorage.instance
        .ref()
        .child('users/Images Profile/' + email + "/Image Profile.jpg");
    UploadTask uploadTask = reference.putData(await image.readAsBytes());
    String imageUrl =
        await (await uploadTask.whenComplete(() => null)).ref.getDownloadURL();
    await _saveImageUrlToFireStore(imageUrl, email);
    await SharedPreference.setImageProfileIsFound(imageUrl);
    return true;
  }

  Future<void> _saveImageUrlToFireStore(
      String imageUrl, String userEmail) async {
    String documentId = "";
    Models.User user = Models.User();
    await _firestore
        .collection('users')
        .where('email', isEqualTo: userEmail)
        .get()
        .then(
          (value) => value.docs.forEach(
            (element) {
              user = Models.User.fromJson(map: element.data());
              documentId = element.id;
              user.imageUrl = imageUrl;
              _firestore.collection('users').doc(documentId).update(
                    user.toJson(user),
                  );
            },
          ),
        );
  }

  Future<Models.User> getUserInfo() async {
    Models.User user = Models.User();
    String email = await SharedPreference.getUserEmail();
    await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get()
        .then(
          (value) => value.docs.forEach(
            (element) {
              user = Models.User.fromJson(map: element.data());
            },
          ),
        );
    return user;
  }

  /* Future<List<Models.User>> getAllUsers() async {
    String currentUserEmail = await SharedPreference.getUserEmail();
    List<Models.User> allUsers = [];
    Models.User user;
    /* await _firestore.collection('users').get().then(
          (value) => value.docs.forEach(
            (element) {
              user = Models.User.fromJson(map: element.data());
              if (user.email != currentUserEmail) allUsers.add(user);
            },
          ),
        ); */
    _firestore.collection("users").snapshots().listen((event) {
      event.docChanges.forEach((element) {
        user = Models.User.fromJson(map: (element.doc.data())!);
        if (user.email != currentUserEmail) allUsers.add(user);
      });
    });
    return allUsers;
  } */

  Stream<QuerySnapshot> getUserSnapshot() async* {
    yield* _firestore.collection('users').snapshots();
  }

  Future<bool> updateUserInfo(Models.User updatedUser) async {
    Models.User user = Models.User();
    String documentId;
    await _firestore
        .collection("users")
        .where('email', isEqualTo: updatedUser.email)
        .get()
        .then(
          (value) => value.docs.forEach(
            (element) {
              documentId = element.id;
              _firestore
                  .collection("users")
                  .doc(documentId)
                  .update(
                    user.toJson(
                      updatedUser,
                    ),
                  )
                  .whenComplete(() {
                _firebaseAuth.currentUser!
                    .updatePassword(updatedUser.password)
                    .whenComplete(() {
                  print("Success................");
                  return true;
                }).catchError((onError) {
                  print("Error $onError");
                });
                return false;
              });
            },
          ),
        );
    return false;
  }
}
