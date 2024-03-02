import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:m3u_player/movies/watchMovies.dart';
import 'package:tmdb_api/tmdb_api.dart';
import '../common/CustomAppBar.dart';
import '../common/color_extension.dart';

class movieInfo extends StatefulWidget {
  final String channelName;
  final String channelPath;
  final String channelLogo;
  final String channelCategory;

  const movieInfo({
    Key? key,
    required this.channelPath,
    required this.channelName,
    required this.channelLogo,
    required this.channelCategory,
  }) : super(key: key);

  @override
  _movieInfoState createState() => _movieInfoState();
}

class _movieInfoState extends State<movieInfo> {
  late bool _isFavorite;
  late SharedPreferences _prefs;

  late TMDB tmdbWithCustomLogs;
  List<Map<String, dynamic>> movieData = [];
  List<Map<String, dynamic>> movieCredits = [];
  String movieDirector = '';

  @override
  void initState() {
    super.initState();
    _initPrefs();
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

    fetchMovieData();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _isFavorite = _prefs.getBool(widget.channelName) ?? false;
    setState(() {});
  }

  Future<void> _toggleFavorite() async {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    // Update the list of favorite movies in SharedPreferences
    await _updateFavoriteMovies();
  }

  Future<void> _updateFavoriteMovies() async {
    // Retrieve the current list of favorite movies from SharedPreferences
    List<String>? favMovies = _prefs.getStringList('fav_movies');

    if (favMovies == null) {
      // If the list doesn't exist yet, create a new empty list
      favMovies = [];
    }

    if (_isFavorite) {
      // If the movie is being added to favorites, construct a movie object and serialize it
      Map<String, dynamic> movieData = {
        'name': widget.channelName,
        'link': widget.channelPath,
        'image': widget.channelLogo,
        'category': widget.channelCategory,
      };
      String serializedMovie = json.encode(movieData);
      // Add the serialized movie to the list
      favMovies.add(serializedMovie);
    } else {
      // If the movie is being removed from favorites, remove it from the list
      favMovies.removeWhere((movie) {
        Map<String, dynamic> movieData = json.decode(movie);
        return movieData['name'] == widget.channelName;
      });
    }

    // Store the updated list of favorite movies back to SharedPreferences
    await _prefs.setStringList('fav_movies', favMovies);
  }

  void fetchMovieData() async {
    final response = await tmdbWithCustomLogs.v3.search.queryMovies(
      widget.channelName,
      language: 'ar',
    );
    if (response.containsKey('results')) {
      final List<Map<String, dynamic>> results =
          List<Map<String, dynamic>>.from(response['results']);
      if (results.isNotEmpty) {
        final movieId = results.first['id'];
        final creditsResponse = await tmdbWithCustomLogs.v3.movies
            .getCredits(int.parse(movieId.toString()));
        if (creditsResponse.containsKey('crew')) {
          final List<Map<String, dynamic>> crew =
              List<Map<String, dynamic>>.from(creditsResponse['crew']);
          final List<Map<String, dynamic>> directors =
              crew.where((member) => member['job'] == 'Director').toList();
          String directorName = 'Unknown';
          if (directors.isNotEmpty) {
            directorName = directors.first['name'];
          }
          setState(() {
            movieData = results;
            movieCredits = crew;
            movieDirector = directorName;
          });
        } else {
          print('Failed to fetch movie credits');
        }
      }
    } else {
      print('Failed to fetch movie data: ${response['status_message']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.bg,
      appBar: CustomAppBar(),
      body: movieData.isEmpty
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(TColor.primary1),
              ),
            )
          : Stack(
              children: [
                SizedBox(
                  width: media.width,
                  height: media.width,
                  child: ClipRect(
                    child: Image.network(
                      movieData.first['backdrop_path'] != null
                          ? 'https://image.tmdb.org/t/p/w500${movieData.first['backdrop_path']}'
                          : 'https://image.tmdb.org/t/p/w500${movieData.first['poster_path']}',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(1),
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 20,
                  right: 20,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 245,
                            child: Text(
                              widget.channelName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'cairo',
                              ),
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            widget.channelCategory,
                            style: TextStyle(
                              color: TColor.subtext,
                              fontSize: 13,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'cairo',
                            ),
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                            height:
                                100, // Set the fixed height of the container
                            width: 230,
                            child: Text(
                              '${movieData.first['overview']}',
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.justify,
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: TColor.subtext,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'cairo',
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'إخراج: ' + movieDirector,
                                style: TextStyle(
                                  color: TColor.subtext,
                                  fontSize: 13,
                                  fontWeight: FontWeight.normal,
                                  fontFamily: 'cairo',
                                ),
                                textAlign: TextAlign.right,
                                textDirection: TextDirection.rtl,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                'عام: ' + '${movieData.first['release_date']}',
                                style: TextStyle(
                                  color: TColor.subtext,
                                  fontSize: 13,
                                  fontWeight: FontWeight.normal,
                                  fontFamily: 'cairo',
                                ),
                                textAlign: TextAlign.right,
                                textDirection: TextDirection.rtl,
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            child: Center(
                              child: Image.network(
                                'https://image.tmdb.org/t/p/w500${movieData.first['poster_path']}',
                                width: media.width * 0.3,
                                height: media.width * 0.4,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: _toggleFavorite,
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: TColor.subtext,
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    _isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: TColor.bg,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => watchMovies(
                                          channelName: widget.channelName,
                                          channelLogo: widget.channelLogo,
                                          channelCategory:
                                              widget.channelCategory,
                                          channelPath: widget.channelPath),
                                    ),
                                  );
                                },
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    gradient: LinearGradient(
                                      colors: TColor.primaryG,
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.play_arrow_rounded,
                                    color: TColor.bg,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: 120, // Adjust the height as needed
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(movieCredits.length, (index) {
                          final castMember = movieCredits[index];
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: TColor.primary1, width: 2),
                                  ),
                                  child: CircleAvatar(
                                    radius: 40,
                                    backgroundImage: NetworkImage(
                                      'https://image.tmdb.org/t/p/w500${castMember['profile_path']}',
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  castMember['name'],
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
