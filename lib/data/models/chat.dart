class Chat {
  late String sender;
  late String receiver;
  late String message;
  late DateTime dateTime;
  Chat();
  Chat.withData({
    required this.sender,
    required this.receiver,
    required this.message,
    required this.dateTime,
  });
  Chat.fromJson(Map<String, dynamic> map) {
    this.sender = map['sender'];
    this.receiver = map['receiver'];
    this.message = map['message'];
    this.dateTime = map['date_time'].toDate();
  }
  Map<String, dynamic> toJson(Chat chat) {
    Map<String, dynamic> map = Map<String, dynamic>();
    map['sender'] = chat.sender;
    map['receiver'] = chat.receiver;
    map['message'] = chat.message;
    map['date_time'] = chat.dateTime;
    return map;
  }
}
