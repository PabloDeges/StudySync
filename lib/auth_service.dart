import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();

  Future<bool> login(String username, String password) async {
    final url =
        "http://${dotenv.env['SERVER']}:${dotenv.env['PORT']}/auth/login";
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final token = responseData['token'];
      await _storage.write(
          key: 'jwt_token',
          value: token); // mit Token arbeiten await getToken()
      return true;
    } else {
      return false;
    }
  }

  Future<void> logout() async {
    //clear Token aus storage
    await _storage.delete(key: 'jwt_token');
  }

  Future<String?> getToken() async {
    //Token aus Storage holen
    return await _storage.read(key: 'jwt_token');
  }

  Future<bool> register(
      {required String name, required String password}) async {
    final url =
        'http://${dotenv.env['SERVER']}:${dotenv.env['PORT']}/auth/register';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': name,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }
}
