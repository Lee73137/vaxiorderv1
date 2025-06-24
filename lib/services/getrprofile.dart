import 'package:vaxiorderv1/model/userprofile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<UserProfile> fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('username');

    final response = await http.get(
      Uri.parse(
        'http://mainapi.vaxilifecorp.com/api/userinfo?empname=$savedUsername',
      ),
    );
    if (response.statusCode == 200) {
      return UserProfile.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load profile');
    }
  }
}
