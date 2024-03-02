import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:m3u_nullsafe/m3u_nullsafe.dart';
import 'package:http/http.dart' as http;
import 'package:m3u_player/home/homeView.dart';
import 'package:m3u_player/main_tab/main_tab_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'common/color_extension.dart';
import 'package:animated_icon/animated_icon.dart';

class LoadData extends StatefulWidget {
  @override
  _LoadDataState createState() => _LoadDataState();
}

class _LoadDataState extends State<LoadData> {
  String? _username;
  String? _password;
  List<M3uGenericEntry>? _tracks;
  Map<String, Map<String, List<M3uGenericEntry>>> categorizedTracks = {};

  final _progressStream = StreamController<double>();

  @override
  void initState() {
    super.initState();
    _getCredentials(); // Get stored username and password
  }

  @override
  void dispose() {
    _progressStream.close();
    super.dispose();
  }

  Future<void> _getCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username');
      _password = prefs.getString('password');
    });
    if (_username != null && _password != null) {
      // If username and password are available, load data
      _loadData(_username!, _password!);
    } else {
      // If username and password are not available, handle accordingly
      print('No stored credentials found');
    }
  }

  Future<void> _loadData(String username, String password) async {
    final apiUrl =
        'http://shoof.watch:8000/get.php?username=$username&password=$password&type=m3u_plus&output=ts';

    try {
      final cacheManager = DefaultCacheManager();
      final fileInfo = await cacheManager.getFileFromCache(apiUrl);

      if (fileInfo != null && fileInfo.file.existsSync()) {
        // If file exists in cache, parse it directly
        final fileContent = await fileInfo.file.readAsString();
        final listOfTracks = await parseFile(fileContent);
        setState(() {
          _tracks = listOfTracks;
        });

        // Categorize the tracks
        _categorizeTracks(listOfTracks);

        // Navigate to MainTabView after loading data
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                MainTabView(categorizedTracks: categorizedTracks),
          ),
        );
      } else {
        // If file does not exist in cache, download and cache it
        final client = http.Client();
        final request = http.Request('GET', Uri.parse(apiUrl));
        final streamedResponse = await client.send(request);

        final totalBytes = streamedResponse.contentLength ?? 0;
        var receivedBytes = 0;

        final responseStream = streamedResponse.stream;
        final fileBytes = <int>[];

        responseStream.listen(
          (List<int> chunk) {
            receivedBytes += chunk.length;
            final progress = receivedBytes / totalBytes;
            _progressStream.add(progress); // Emit progress
            fileBytes.addAll(chunk);
          },
          onDone: () async {
            client.close();

            if (streamedResponse.statusCode == 200) {
              await cacheManager.putFile(apiUrl, Uint8List.fromList(fileBytes));
              final fileContent = String.fromCharCodes(fileBytes);
              final listOfTracks = await parseFile(fileContent);
              setState(() {
                _tracks = listOfTracks;
              });

              // Categorize the tracks
              _categorizeTracks(listOfTracks);

              // Navigate to MainTabView after loading data
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      HomeView(categorizedTracks: categorizedTracks),
                ),
              );
            } else {
              print('Failed to load M3U file: ${streamedResponse.statusCode}');
            }
          },
          onError: (e) {
            print('Error loading M3U file: $e');
          },
        );
      }
    } catch (e) {
      print('Error loading M3U file: $e');
    }
  }

  void _categorizeTracks(List<M3uGenericEntry> tracks) {
    // Clear the previous data
    categorizedTracks.clear();

    // Categorize the tracks based on their URLs and group titles
    tracks.forEach((track) {
      final url = track.link;
      final groupTitle = track.attributes?['group-title'];

      if (url != null && groupTitle != null) {
        if (url.contains('/movie/')) {
          categorizedTracks.putIfAbsent('Movies', () => {});
          categorizedTracks['Movies']!.putIfAbsent(groupTitle, () => []);
          categorizedTracks['Movies']![groupTitle]!.add(track);
        } else if (url.contains('/series/')) {
          categorizedTracks.putIfAbsent('Series', () => {});
          categorizedTracks['Series']!.putIfAbsent(groupTitle, () => []);
          categorizedTracks['Series']![groupTitle]!.add(track);
        } else {
          categorizedTracks.putIfAbsent('Live', () => {});
          categorizedTracks['Live']!.putIfAbsent(groupTitle, () => []);
          categorizedTracks['Live']![groupTitle]!.add(track);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: TColor.bg,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          SizedBox(
            width: media.width,
            height: media.width,
            child: ClipRect(
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(1),
                      Colors.black.withOpacity(0.8),
                    ],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.srcOver,
                child: Image.asset(
                  "assets/img/background.jpeg",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Container(
            width: media.width,
            height: media.width * 0.9,
            alignment: const Alignment(0, 0),
            child: Container(
              width: media.width,
              height: media.width * 0.25,
              child: Image.asset(
                "assets/img/logo-slug.png",
                width: media.width * 0.5,
                height: media.width * 0.5,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 100.0),
              child: CircularProgressIndicator(
                color: TColor.primary1,
                strokeWidth: 2.0,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 70.0),
              child: _buildProgressText(), // Show progress
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(top: 150.0),
              child: AutoSlider(), // Add the auto slider widget here
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressText() {
    return StreamBuilder<double>(
      stream: _progressStream.stream,
      initialData: 0.0,
      builder: (context, snapshot) {
        final progress = snapshot.data!;
        return Text(
          '${(progress * 100).toStringAsFixed(2)}%',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        );
      },
    );
  }
}

class AutoSlider extends StatefulWidget {
  @override
  _AutoSliderState createState() => _AutoSliderState();
}

class _AutoSliderState extends State<AutoSlider> {
  final PageController _controller = PageController();
  final List<Map<String, dynamic>> _slides = [
    {
      'icon': AnimateIcons.list,
      'text': 'أحدث الأفلام والمسلسلات',
      'par': 'أقوى وأحدث مكتبة أفلام تشاهدها بأي وقت ومكان بأعلى جودة'
    },
    {
      'icon': AnimateIcons.liveVideo,
      'text': 'قنوات مباشرة',
      'par': 'شاهد كافة القنوات المباشرة المدفوعة والمجانية في مكان واحد'
    },
    {
      'icon': AnimateIcons.playStop,
      'text': 'مشغل رائع',
      'par':
          'مدمج في تطبيق شوف احدث وافضل مشغلات الفيديو بمميزات رائعة وجديدة كلياً'
    },
  ];
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_currentPage < _slides.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _controller.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: _controller,
        itemCount: _slides.length,
        itemBuilder: (context, index) {
          return Slide(
            icon: _slides[index]['icon'],
            text: _slides[index]['text'],
            par: _slides[index]['par'],
          );
        },
        onPageChanged: (int page) {
          setState(() {
            _currentPage = page;
          });
        },
      ),
    );
  }
}

class Slide extends StatelessWidget {
  final AnimateIcons icon;
  final String text;
  final String par;

  const Slide({required this.icon, required this.text, required this.par});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Transform.scale(
          scale: 1.5, // Adjust the scale factor as needed
          child: Container(
            child: AnimateIcon(
              key: UniqueKey(),
              onTap: () {},
              iconType: IconType.continueAnimation,
              height: 70,
              width: 70,
              color: TColor.primary1,
              animateIcon: icon,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'cairo',
          ),
          textAlign: TextAlign.justify,
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Container(
            width: 300,
            child: Text(
              par,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontFamily: 'cairo',
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
          ),
        ),
      ],
    );
  }
}
