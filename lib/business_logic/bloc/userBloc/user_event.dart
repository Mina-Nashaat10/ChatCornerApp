part of 'user_bloc.dart';

@immutable
abstract class UserEvent {}

// ignore: must_be_immutable
class SignUpUserWithEmailAndPassword extends UserEvent {
  late User user;
  SignUpUserWithEmailAndPassword({
    required this.user,
  });
}

// ignore: must_be_immutable
class SignInUserWithEmailAndPassword extends UserEvent {
  late String email, password;
  SignInUserWithEmailAndPassword({
    required this.email,
    required this.password,
  });
}

class SignInUserWithGoogle extends UserEvent {}

class SignOutUser extends UserEvent {}

// ignore: must_be_immutable
class SaveImageProfileToFireStorage extends UserEvent {
  late File imageFile;
  SaveImageProfileToFireStorage({required this.imageFile});
}

// ignore: must_be_immutable
class GetUserInformation extends UserEvent {
  GetUserInformation();
}

class GetAllUsersSnapShot extends UserEvent {}

// ignore: must_be_immutable
class UpdateUserInformation extends UserEvent {
  late User updatedUser;
  UpdateUserInformation({required this.updatedUser});
}
