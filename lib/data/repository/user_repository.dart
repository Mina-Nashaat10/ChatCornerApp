import 'dart:io';

import 'package:chat_corner/data/models/user.dart';
import 'package:chat_corner/data/web_services/user_web_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class UserRepository {
  late UserWebServices _userWebServices;
  UserRepository() {
    _userWebServices = UserWebServices();
  }
  Future<String> signUpUser(User user) async {
    String result = await _userWebServices.signUpUser(user);
    return result;
  }

  Future<String> signInUserWithEmailAndPassword(
      String email, String pass) async {
    String result = await _userWebServices.signInUser(email, pass);
    return result;
  }

  Future<bool> signInUserWithGoogle() async {
    bool result = await _userWebServices.signInWithGoogle();
    return result;
  }

  Future<bool> signOutUserWithGoogle() async {
    bool result = await _userWebServices.signOutUserWithGoogle();
    return result;
  }

  Future<bool> saveImageProfileToFirebaseStorage(File image) async {
    bool result =
        await _userWebServices.saveImageProfileToFirebaseStorage(image);
    return result;
  }

  Future<User> getUserInfo() async {
    User user = await _userWebServices.getUserInfo();
    return user;
  }

  Stream<QuerySnapshot> getAllUsers()async*{
    Stream<QuerySnapshot> allUsers = _userWebServices.getUserSnapshot();
    yield* allUsers;
  }

  Future<bool> updateUserInfo(User updatedUser) async {
    bool result = await _userWebServices.updateUserInfo(updatedUser);
    return result;
  }
}
