import "package:flutter/material.dart";
import "package:vaxiorderv1/screens/profilepage.dart";
import "package:video_player/video_player.dart";
import "package:connectivity_plus/connectivity_plus.dart";
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  //final String videoUrl = 'http://mainapi.vaxilifecorp.com/videos/pet_alert_episode_12_1080p.mp4'; // Replace with real ID
  bool _hasPlayed = false;

  final List<Widget> _pages = [
    const Center(child: Text("Welcome to HomePage")),
    const Center(child: Text("Search Page")),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _getPageTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Home';
      case 1:
        return 'Search';
      case 2:
        return 'Profile';
      default:
        return 'Home';
    }
  }

  Future<void> _logout(BuildContext context) async {
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _checkAndPlayVideo() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      return;
    }
    try {
      final response = await http.get(
        Uri.parse('http://mainapi.vaxilifecorp.com/api/videos'),
      );

      if (response.statusCode != 200) return;

      final String data = json.decode(response.body);
      final String videoUrl = data.split("^")[1];
      if (videoUrl == "" || videoUrl.isEmpty) return;

      final prefs = await SharedPreferences.getInstance();
      final lastUrl = prefs.getString('lastVideoUrl');
      int playCount = prefs.getInt('videoPlayCount') ?? 0;

      if (lastUrl != videoUrl) {
        playCount = 0;
        //lastUrl = videoUrl;
        await prefs.setString('lastVideoUrl', videoUrl);
        await prefs.setInt('videoPlayCount', playCount);
      }

      // Show video popup
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: playCount > 0, // dismiss allowed after 1st time
          builder: (_) => VideoPopup(
            videoUrl: videoUrl,
            canCloseAfterPlay: playCount > 0,
            onPlayed: () async {
              playCount++;
              await prefs.setInt('videoPlayCount', playCount);
            },
          ),
        );
      }
    } catch (e) {
      debugPrint("Video fetch Failed : $e");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Show video only once per navigation
    if (!_hasPlayed) {
      _hasPlayed = true;
      _checkAndPlayVideo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getPageTitle()),
        actions: _selectedIndex == 2
            ? [
                IconButton(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout),
                ),
              ]
            : null,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_business),
            label: 'Booking',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class VideoPopup extends StatefulWidget {
  final String videoUrl;
  final bool canCloseAfterPlay;
  final VoidCallback onPlayed;

  const VideoPopup({
    super.key,
    required this.videoUrl,
    required this.canCloseAfterPlay,
    required this.onPlayed,
  });

  @override
  State<VideoPopup> createState() => _VideoPopupState();
}

class _VideoPopupState extends State<VideoPopup> {
  late VideoPlayerController _controller;
  bool _hasAutoClosed = false;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        widget.onPlayed();

        _controller.addListener(() {
          final bool isEnded =
              _controller.value.position >= _controller.value.duration;
          final bool isNotPlaying = !_controller.value.isPlaying;

          if (isEnded && isNotPlaying && !_hasAutoClosed) {
            _hasAutoClosed = true;
            if (mounted) {
              Navigator.of(context).pop(); // Close the dialog
            }
          }
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _closeIfAllowed() {
    if (widget.canCloseAfterPlay) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: _controller.value.isInitialized
          ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                children: [
                  VideoPlayer(_controller),
                  if (widget.canCloseAfterPlay)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: _closeIfAllowed,
                      ),
                    )
                  else
                    const Positioned(
                      top: 8,
                      right: 8,
                      child: Icon(Icons.lock, color: Colors.white),
                    ),
                ],
              ),
            )
          : const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
    );
  }
}
