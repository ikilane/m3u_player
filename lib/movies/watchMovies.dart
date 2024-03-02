import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:tmdb_api/tmdb_api.dart';
import '../common/CustomAppBar.dart';
import '../common/color_extension.dart';

class watchMovies extends StatefulWidget {
  final String channelName;
  final String channelPath;
  final String channelLogo;
  final String channelCategory;

  const watchMovies({
    Key? key,
    required this.channelPath,
    required this.channelName,
    required this.channelLogo,
    required this.channelCategory,
  }) : super(key: key);

  @override
  _watchMoviesState createState() => _watchMoviesState();
}

class _watchMoviesState extends State<watchMovies> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  late bool _isFavorite;

  late TMDB tmdbWithCustomLogs;
  List<Map<String, dynamic>> movieData = [];

  @override
  void initState() {
    super.initState();

    // Initialize TMDB instance with your API key
    tmdbWithCustomLogs = TMDB(
      ApiKeys(
        '177931ec00da6594c6161c3622c92a54',
        'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIxNzc5MzFlYzAwZGE2NTk0YzYxNjFjMzYyMmM5MmE1NCIsInN1YiI6IjVlYzNiNWUwMmRmZmQ4MDAyMDcwZDAwNSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.bypvInnGZwCQ31GIfodTXSkNBXkTuF6R-SUNFcqLjF8',
      ),
      logConfig: ConfigLogger(
        showLogs: true,
        showErrorLogs: true,
      ),
    );

    // Fetch movie data based on the channel name
    fetchMovieData();

    // Initialize VideoPlayerController
    _videoPlayerController = VideoPlayerController.network(widget.channelPath);
    _videoPlayerController.initialize().then((_) {
      setState(() {
        // After initialization, play the video
        _videoPlayerController.play();
      });
    });

    // Initialize ChewieController
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      fullScreenByDefault: true,
      draggableProgressBar: true,
      aspectRatio: 16 / 9,
      showOptions: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: TColor
            .primary1, // Specify the color for the played portion of the video progress
        handleColor:
            TColor.primary2, // Specify the color for the progress handle
        backgroundColor:
            TColor.card, // Specify the background color for the progress bar
        bufferedColor: TColor
            .subtext, // Specify the color for the buffered portion of the video progress
      ),
      allowFullScreen: true,
      placeholder: Container(
        color: TColor.bg,
        child: Center(
          child: CircleAvatar(
            backgroundImage: NetworkImage(widget.channelLogo),
            radius: 48,
          ),
        ),
      ),
      overlay: Stack(
        children: [
          Positioned(
            bottom: 5,
            right: 16,
            child: Image.asset(
              "assets/img/logo-icon.png", // Add your app logo image here
              width: 48,
              height: 48,
            ),
          ),
        ],
      ),
    );

    _isFavorite = false;
  }

  // Function to fetch movie data based on channel name
  void fetchMovieData() async {
    // Perform a movie search based on the channel name, specifying language as Arabic
    final response = await tmdbWithCustomLogs.v3.search
        .queryMovies(widget.channelName, language: 'ar');
    if (response.containsKey('results')) {
      final List<Map<String, dynamic>> results =
          List<Map<String, dynamic>>.from(response['results']);
      setState(() {
        movieData = results;
        print(movieData);
      });
    } else {
      print('Failed to fetch movie data: ${response['status_message']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: TColor.bg,
        appBar: CustomAppBar(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Chewie(controller: _chewieController),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    _videoPlayerController.pause();
    return true;
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController.dispose();
    _chewieController.dispose();
  }
}
