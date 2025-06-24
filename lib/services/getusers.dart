import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:vaxiorderv1/data/dbhelper.dart';
import 'package:vaxiorderv1/model/usermodel.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

Future<void> fetchAndStoreUsers() async {
  var connectivityResult = await Connectivity().checkConnectivity();

  if (connectivityResult == ConnectivityResult.none) {
    print('No Internet Connection');
    return;
  }
  try {
    final url = Uri.parse('http://mainapi.vaxilifecorp.com/api/user');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      final db = LocalDatabase();

      for (var userJson in jsonData) {
        User user = User.fromJson(userJson);
        await db.insertUser(user);
      }

      print('Users downloaded and stored locally.');
    } else {
      print('Failed to load users');
    }
  } on SocketException catch (e) {
    print('Network Error : ${e.message}');
  } catch (e) {
    print('Unexpected Error: $e');
  }
}
