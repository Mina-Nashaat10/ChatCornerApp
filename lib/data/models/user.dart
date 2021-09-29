class User {
  late String fullName;
  late String email;
  late String password;
  late String? imageUrl;
  late String address;
  late String phone;
  late String? userToken;
  User();

  User.withData({
    required this.fullName,
    required this.email,
    required this.password,
    required this.address,
    required this.phone,
    this.imageUrl,
    this.userToken,
  });

  User.fromJson({required Map<dynamic, dynamic> map}) {
    this.fullName = map['name'];
    this.email = map['email'];
    this.password = map['password'];
    this.imageUrl = map['image_profile'];
    this.address = map['address'];
    this.phone = map['phone'];
    this.userToken = map['user_token'];
  }

  Map<String, dynamic> toJson(User user) {
    Map<String, dynamic> map = Map<String, dynamic>();
    map['name'] = user.fullName;
    map['email'] = user.email;
    map['password'] = user.password;
    map['image_profile'] = user.imageUrl;
    map['address'] = user.address;
    map['phone'] = user.phone;
    map['user_token'] = user.userToken;
    return map;
  }
}
