import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:chat_corner/data/models/user.dart';
import 'package:chat_corner/data/repository/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  late UserRepository _userRepository;
  UserBloc() : super(UserInitial()) {
    _userRepository = UserRepository();
  }

  @override
  Stream<UserState> mapEventToState(
    UserEvent event,
  ) async* {
    if (event is SignUpUserWithEmailAndPassword) {
      String result = await _userRepository.signUpUser(
        event.user,
      );
      yield UserIsSignUpWithEmailAndPassword(
        result: result,
      );
    } else if (event is SignInUserWithEmailAndPassword) {
      String result = await _userRepository.signInUserWithEmailAndPassword(
        event.email,
        event.password,
      );
      yield UserIsSignInWithEmailAndPassword(
        result: result,
      );
    } else if (event is SignInUserWithGoogle) {
      bool result = await _userRepository.signInUserWithGoogle();
      yield UserIsSignInWithGoogle(
        result: result,
      );
    } else if (event is SignOutUser) {
      bool result = await _userRepository.signOutUserWithGoogle();
      yield UserIsSignOut(
        result: result,
      );
    } else if (event is SaveImageProfileToFireStorage) {
      bool result = await _userRepository
          .saveImageProfileToFirebaseStorage(event.imageFile);
      yield ImageProfileIsSavedToFireStorage(result: result);
    } else if (event is GetUserInformation) {
      User user = await _userRepository.getUserInfo();
      yield UserInfoIsAvailable(user: user);
    } else if (event is GetAllUsersSnapShot) {
      Stream<QuerySnapshot> usersSnapshot = _userRepository.getAllUsers();
      yield UserSnapshotLoaded(usersSnapshot: usersSnapshot);
    } else if (event is UpdateUserInformation) {
      bool result = await _userRepository.updateUserInfo(event.updatedUser);
      yield UserInformationUpdated(result: result);
    }
  }
}
