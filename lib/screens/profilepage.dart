import 'package:flutter/material.dart';
import 'package:vaxiorderv1/model/userprofile.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:vaxiorderv1/services/getrprofile.dart';
import 'package:vaxiorderv1/data/profiledbhelper.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserProfile? _user;
  bool _isLoading = true;
  bool _isOffline = false;

  Future<void> _loadProfile() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult != ConnectivityResult.none) {
      try {
        final profile = await ApiService.fetchUserProfile();
        await DBHelper.saveProfile(profile);
        setState(() {
          _user = profile;
          _isOffline = false;
          _isLoading = false;
        });
        return;
      } catch (_) {}
    }

    final local = await DBHelper.getProfile();
    setState(() {
      _user = local;
      _isOffline = true;
      _isLoading = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_user == null) {
      return const Center(child: Text("No profile data available"));
    }

    return RefreshIndicator(
      onRefresh: _loadProfile,
      child: ListView(
        children: [
          Container(
            color: Colors.deepPurple,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                if (_isOffline)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      "⚠️ Offline Mode",
                      style: TextStyle(color: Colors.amberAccent),
                    ),
                  ),
                CircleAvatar(
                  radius: 50,
                  //backgroundImage: NetworkImage(_user!.imageUrl),
                ),
                const SizedBox(height: 10),
                Text(
                  _user!.username,
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
                Text(
                  _user!.email,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              /*_stat("Followers", _user!.followers),
              _stat("Following", _user!.following),
              _stat("Posts", _user!.posts),*/
            ],
          ),
        ],
      ),
    );
  }
}
