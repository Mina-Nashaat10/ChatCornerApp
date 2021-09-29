import 'package:chat_corner/constants/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreference {
  static late SharedPreferences _sharedPreferences;
  static Future<SharedPreferences> _getInstatnce() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    return _sharedPreferences;
  }

  static Future<bool> checkOnBoardingScreenIsShowingOrNot() async {
    await _getInstatnce();
    bool onBoardingIsShow =
        _sharedPreferences.getBool(onBoardingScreenKey) ?? false;
    return onBoardingIsShow;
  }

  static Future<void> setOnBoardingScreenIsShowing() async {
    await _getInstatnce();
    await _sharedPreferences.setBool(onBoardingScreenKey, true);
  }

  static Future<bool> checkUserIfLoginOrNot() async {
    await _getInstatnce();
    bool isLogin = _sharedPreferences.getBool(userLoginKey) ?? false;
    return isLogin;
  }

  static Future<void> setUserAuth(bool value) async {
    await _getInstatnce();
    await _sharedPreferences.setBool(userLoginKey, value);
  }

  static Future<void> setUserEmail(String email) async {
    await _getInstatnce();
    await _sharedPreferences.setString(userEmailKey, email);
  }

  static Future<String> getUserEmail() async {
    await _getInstatnce();
    String email = _sharedPreferences.getString(userEmailKey) ?? "";
    return email;
  }

  static Future<String> getImageProfile() async {
    await _getInstatnce();
    String imageIsFound = _sharedPreferences.getString(imageProfileKey) ?? "";
    return imageIsFound;
  }

  static Future<void> setImageProfileIsFound(String imageUrl) async {
    await _getInstatnce();
    await _sharedPreferences.setString(imageProfileKey, imageUrl);
  }
}
