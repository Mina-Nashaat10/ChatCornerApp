part of 'user_bloc.dart';

@immutable
abstract class UserState {}

class UserInitial extends UserState {}

// ignore: must_be_immutable
class UserIsSignUpWithEmailAndPassword extends UserState {
  late String result;
  UserIsSignUpWithEmailAndPassword({required this.result});
}

// ignore: must_be_immutable
class UserIsSignInWithEmailAndPassword extends UserState {
  late String result;
  UserIsSignInWithEmailAndPassword({required this.result});
}

// ignore: must_be_immutable
class UserIsSignInWithGoogle extends UserState {
  late bool result;
  UserIsSignInWithGoogle({required this.result});
}

// ignore: must_be_immutable
class UserIsSignOut extends UserState {
  late bool result;
  UserIsSignOut({required this.result});
}

// ignore: must_be_immutable
class ImageProfileIsSavedToFireStorage extends UserState {
  late bool result;
  ImageProfileIsSavedToFireStorage({required this.result});
}

// ignore: must_be_immutable
class UserInfoIsAvailable extends UserState {
  late User user;
  UserInfoIsAvailable({required this.user});
}

// ignore: must_be_immutable
class UserSnapshotLoaded extends UserState {
  late Stream<QuerySnapshot> usersSnapshot;
  UserSnapshotLoaded({required this.usersSnapshot});
}

// ignore: must_be_immutable
class UserInformationUpdated extends UserState {
  late bool result;
  UserInformationUpdated({required this.result});
}
