class UserModel {
  UserModel({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final Data data;
  
  UserModel.fromJson(Map<String, dynamic> json){
    status = json['status'];
    message = json['message'];
    data = Data.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['data'] = data.toJson();
    return _data;
  }
}

class Data {
  Data({
    required this.userId,
    required this.name,
    required this.mobileNo,
    required this.email,
    required this.password,
  });
  late final String userId;
  late final String name;
  late final String mobileNo;
  late final String email;
  late final String password;
  
  Data.fromJson(Map<String, dynamic> json){
    userId = json['userId'];
    name = json['name'];
    mobileNo = json['mobileNo'];
    email = json['email'];
    password = json['password'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['userId'] = userId;
    _data['name'] = name;
    _data['mobileNo'] = mobileNo;
    _data['email'] = email;
    _data['password'] = password;
    return _data;
  }
}