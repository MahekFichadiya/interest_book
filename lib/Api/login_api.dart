import "dart:convert";
import 'package:interest_book/Api/UrlConstant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Model/UserModel.dart';

class LoginAPI {
  Future<bool> userLogin(String email, String password) async {
    final Url = Uri.parse(UrlConstant.LoginApi);
    final prefs = await SharedPreferences.getInstance();
    var body = {"email": email, "password": password};
    final newbody = json.encode(body);
    var responce = await http.post(Url, body: newbody);
    print(responce);
    print(responce.statusCode);
    print(responce.body);
    if (responce.statusCode == 200 || responce.statusCode == 201) {
      var data = json.decode(responce.body);
      print(data);
      var userData = data;
      UserModel user = UserModel.fromJson(userData);
      prefs.setString("name", user.data.name);
      prefs.setString("email", user.data.email);
      prefs.setString("mobileNo", user.data.mobileNo);
      prefs.setString("password", user.data.password);
      prefs.setString("userId", user.data.userId);
      print('userId: $prefs.getString("userId")');
      print(userData);
      var userId = prefs.getString("userId");
      print("userId: $userId");
      print(responce.body);
      return true;
    } else {
      return false;
    }
  }
}
