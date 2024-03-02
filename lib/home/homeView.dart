import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:m3u_nullsafe/m3u_nullsafe.dart';
import '../common/color_extension.dart';
import '../liveChannels/watchChannel.dart';
import '../movies/movieInfo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MovieData {
  final String imagePath;
  final String title;
  final String cat;
  final String link;

  MovieData({
    required this.imagePath,
    required this.title,
    required this.cat,
    required this.link,
  });
}

class ChannelData {
  final String channelPath;
  final String channelTitle;
  final String channelLogo;
  final String channelCategory;

  ChannelData({
    required this.channelPath,
    required this.channelTitle,
    required this.channelLogo,
    required this.channelCategory,
  });
}

class Movie {
  final String title;
  final String imagePath;
  final String cat;
  final String link;

  Movie({
    required this.title,
    required this.imagePath,
    required this.cat,
    required this.link,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['title'],
      imagePath: json['imagePath'],
      cat: json['cat'],
      link: json['link'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'imagePath': imagePath,
      'cat': cat,
      'link': link,
    };
  }
}

class HomeView extends StatefulWidget {
  final Map<String, Map<String, List<M3uGenericEntry>>> categorizedTracks;

  HomeView({required this.categorizedTracks});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<MovieData> movies = [];
  List<Movie> favoriteMovies = []; // List to store favorite movies
  List<ChannelData> channels = [];
  List<ChannelData> sportChannels = [];
  bool isLoading = true;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _initPrefs();
    _populateMovies(numberOfMoviesToShow: 5);
    _populateLiveNewsChannels();
    _populateLiveSportChannels();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadFavoriteMovies();
  }

  Future<void> _loadFavoriteMovies() async {
    List<String>? favMovies = _prefs?.getStringList('fav_movies');
    List<Movie> movies = [];

    if (favMovies != null) {
      for (String movieData in favMovies) {
        if (movieData.startsWith('{') && movieData.endsWith('}')) {
          // If the movie data is in JSON format, deserialize it
          Map<String, dynamic> jsonMap = json.decode(movieData);
          movies.add(Movie(
            title: jsonMap['name'],
            imagePath: jsonMap['image'],
            cat: jsonMap['category'],
            link: jsonMap['link'],
          ));
        } else {
          // If the movie data is just a title, create a simple Movie object
          // You can adjust this based on your Movie class structure
          movies.add(Movie(
            title: movieData,
            imagePath: '', // Set appropriate default values for other fields
            cat: '',
            link: '',
          ));
        }
      }
    }

    setState(() {
      favoriteMovies = movies;
    });
  }

  void _populateMovies({int numberOfMoviesToShow = 5}) {
    widget.categorizedTracks.forEach((category, tracks) {
      if (category == 'Movies') {
        int moviesAdded = 0; // Track the number of movies added
        for (int i = 0; i < tracks.length; i++) {
          final trackList = tracks.entries.elementAt(i).value;
          trackList.shuffle();
          for (int j = 0;
              j < trackList.length && moviesAdded < numberOfMoviesToShow;
              j++) {
            final track = trackList[j];
            final title = track.title ?? 'خطأ!';
            final imagePath = getImagePathOrDefault(
              track.attributes?['tvg-logo'],
              "assets/default_movie_image.jpg",
            );

            movies.add(MovieData(
              imagePath: imagePath,
              title: title,
              link: track.link ?? '',
              cat: track.attributes?['group-title'] ?? 'غير موجود',
            ));

            moviesAdded++; // Increment the number of movies added
            if (moviesAdded >= numberOfMoviesToShow)
              break; // Exit loop if the desired number of movies is reached
          }
          if (moviesAdded >= numberOfMoviesToShow)
            break; // Exit outer loop if the desired number of movies is reached
        }
      }
    });

    setState(() {
      isLoading = false;
    });
  }

  void _populateLiveNewsChannels() {
    widget.categorizedTracks.forEach((category, tracks) {
      if (category == 'Live') {
        tracks.forEach((groupTitle, trackList) {
          trackList.shuffle();
          for (int i = 0; i < 12 && i < trackList.length; i++) {
            if (groupTitle == 'قنوات الأخبار') {
              final track = trackList[i];
              final channelTitle = track.title ?? 'Unknown Channel';
              final channelPath = track.link ?? '';
              final channelLogo = getImagePathOrDefault(
                track.attributes?['tvg-logo'],
                "assets/default_channel_logo.jpg",
              );
              final channelCategory = groupTitle;

              channels.add(ChannelData(
                channelPath: channelPath,
                channelTitle: channelTitle,
                channelLogo: channelLogo,
                channelCategory: channelCategory,
              ));
            }
          }
        });
      }
    });

    setState(() {
      isLoading = false;
    });
  }

  void _populateLiveSportChannels() {
    widget.categorizedTracks.forEach((category, tracks) {
      if (category == 'Live') {
        tracks.forEach((groupTitle, trackList) {
          trackList.shuffle();
          for (int i = 0; i < 10 && i < trackList.length; i++) {
            if (groupTitle == 'beIN Sports') {
              final track = trackList[i];
              final channelTitle = track.title ?? 'Unknown Channel';
              final channelPath = track.link ?? '';
              final channelLogo = getImagePathOrDefault(
                track.attributes?['tvg-logo'],
                "assets/default_channel_logo.jpg",
              );
              final channelCategory = groupTitle;

              sportChannels.add(ChannelData(
                channelPath: channelPath,
                channelTitle: channelTitle,
                channelLogo: channelLogo,
                channelCategory: channelCategory,
              ));
            }
          }
        });
      }
    });

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.bg,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                CarouselSlider(
                  //start movies channels
                  options: CarouselOptions(
                    height: 400.0,
                    autoPlay: true,
                    aspectRatio: 16 / 9,
                    viewportFraction: 1,
                    autoPlayInterval: const Duration(seconds: 10),
                  ),
                  items: movies.map((movie) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return LinearGradient(
                                  colors: [TColor.bg.withOpacity(0), TColor.bg],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ).createShader(bounds);
                              },
                              blendMode: BlendMode.dstATop,
                              child: CachedNetworkImage(
                                imageUrl: movie.imagePath,
                                width: media.width,
                                height: media.width,
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey,
                                ),
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                  "assets/img/background.jpeg",
                                  width: media.width,
                                  height: media.width,
                                  fit: BoxFit.cover,
                                  alignment: Alignment.center,
                                ), // Show local asset image if network image fails
                                fadeInDuration: Duration(milliseconds: 300),
                                fadeOutDuration: Duration(milliseconds: 0),
                              ),
                            ),
                            Positioned(
                              bottom: 20,
                              left: 25,
                              child: Row(
                                children: [
                                  Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: TColor.subtext,
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.favorite,
                                      color: TColor.bg,
                                      size: 20,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      gradient: LinearGradient(
                                        colors: TColor.primaryG,
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => movieInfo(
                                                channelName: movie.title,
                                                channelLogo: movie.imagePath,
                                                channelCategory: movie.cat,
                                                channelPath: movie.link),
                                          ),
                                        );
                                      },
                                      child: Icon(
                                        Icons.play_arrow_rounded,
                                        color: TColor.bg,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 60),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        constraints: BoxConstraints(
                                          maxWidth: media.width - 120,
                                          maxHeight: 60,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 0),
                                          child: SizedBox(
                                            width: 190,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Flexible(
                                                  child: RichText(
                                                    text: TextSpan(
                                                      style: TextStyle(
                                                        fontFamily: 'cairo',
                                                        color: TColor.text,
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        height: 1,
                                                      ),
                                                      text: movie.title,
                                                    ),
                                                    textAlign: TextAlign.right,
                                                    textDirection:
                                                        TextDirection.rtl,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Container(
                                        constraints: BoxConstraints(
                                          maxWidth: media.width - 120,
                                          maxHeight: 60,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 0),
                                          child: SizedBox(
                                            width: 190,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Flexible(
                                                  child: RichText(
                                                    text: TextSpan(
                                                      style: TextStyle(
                                                        fontFamily: 'cairo',
                                                        color: TColor.subtext,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        height: 1,
                                                      ),
                                                      text: movie.cat,
                                                    ),
                                                    textAlign: TextAlign.right,
                                                    textDirection:
                                                        TextDirection.rtl,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }).toList(),
                ),

                //start of fav section
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            color: TColor.primary1,
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "المفضلة",
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(
                                    color: TColor.text,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'cairo',
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.favorite_border_outlined,
                                  color: TColor.text,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 100.0,
                        autoPlay: true,
                        aspectRatio: 16 / 9,
                        viewportFraction: 0.28,
                      ),
                      items: favoriteMovies.map((movie) {
                        return Builder(
                          builder: (BuildContext context) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => movieInfo(
                                        channelPath: movie.link,
                                        channelName: movie.title,
                                        channelLogo: movie.imagePath,
                                        channelCategory: movie.cat),
                                  ),
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: ShaderMask(
                                        shaderCallback: (Rect bounds) {
                                          return LinearGradient(
                                            colors: [
                                              TColor.bg.withOpacity(0),
                                              TColor.bg.withOpacity(0.8),
                                              TColor.bg,
                                            ],
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                          ).createShader(bounds);
                                        },
                                        blendMode: BlendMode.dstATop,
                                        child: CachedNetworkImage(
                                          imageUrl: movie.imagePath,
                                          width: media.width,
                                          height: media.width / (16 / 9),
                                          fit: BoxFit.cover,
                                          alignment: Alignment.center,
                                          placeholder: (context, url) =>
                                              Container(
                                            color: Colors.grey,
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Image.asset(
                                            "assets/img/background.jpeg",
                                            width: media.width,
                                            height: media.width,
                                            fit: BoxFit.cover,
                                            alignment: Alignment.center,
                                          ),
                                          fadeInDuration:
                                              Duration(milliseconds: 300),
                                          fadeOutDuration:
                                              Duration(milliseconds: 0),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 20,
                                      left: 25,
                                      child: Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                constraints: BoxConstraints(
                                                  maxWidth: media.width - 120,
                                                  maxHeight: 60,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(width: 60),
                                          Container(
                                            height: 50,
                                            width: 50,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              color: TColor.subtext,
                                            ),
                                            alignment: Alignment.center,
                                            child: Icon(
                                              Icons.favorite,
                                              color: TColor.bg,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Container(
                                            height: 50,
                                            width: 50,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(50),
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
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            color: TColor.primary1,
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "مباشر",
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(
                                    color: TColor.text,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'cairo',
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.live_tv_outlined,
                                  color: TColor.text,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 100.0,
                        autoPlay: true,
                        aspectRatio: 16 / 9,
                        viewportFraction: 0.28,
                      ),
                      items: channels.map((channel) {
                        return Builder(
                          builder: (BuildContext context) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => watchChannel(
                                        channelPath: channel.channelPath,
                                        channelName: channel.channelTitle,
                                        channelLogo: channel.channelLogo,
                                        channelCategory:
                                            channel.channelCategory),
                                  ),
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: ShaderMask(
                                        shaderCallback: (Rect bounds) {
                                          return LinearGradient(
                                            colors: [
                                              TColor.bg.withOpacity(0),
                                              TColor.bg.withOpacity(0.8),
                                              TColor.bg,
                                            ],
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                          ).createShader(bounds);
                                        },
                                        blendMode: BlendMode.dstATop,
                                        child: CachedNetworkImage(
                                          imageUrl: channel.channelLogo,
                                          width: media.width,
                                          height: media.width / (16 / 9),
                                          fit: BoxFit.cover,
                                          alignment: Alignment.center,
                                          placeholder: (context, url) =>
                                              Container(
                                            color: Colors.grey,
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Image.asset(
                                            "assets/img/background.jpeg",
                                            width: media.width,
                                            height: media.width,
                                            fit: BoxFit.cover,
                                            alignment: Alignment.center,
                                          ),
                                          fadeInDuration:
                                              Duration(milliseconds: 300),
                                          fadeOutDuration:
                                              Duration(milliseconds: 0),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 20,
                                      left: 25,
                                      child: Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                constraints: BoxConstraints(
                                                  maxWidth: media.width - 120,
                                                  maxHeight: 60,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(width: 60),
                                          Container(
                                            height: 50,
                                            width: 50,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              color: TColor.subtext,
                                            ),
                                            alignment: Alignment.center,
                                            child: Icon(
                                              Icons.favorite,
                                              color: TColor.bg,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Container(
                                            height: 50,
                                            width: 50,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(50),
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
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(
                  height: 1, // Height of the divider
                  color: Colors.grey.withOpacity(0.5), // Color of the divider
                  thickness: 0.5, // Thickness of the divider
                  indent: 20, // Left padding of the divider
                  endIndent: 20, // Right padding of the divider
                ),
                const SizedBox(height: 20),
                // start sport seaction
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            color: TColor.primary1,
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "رياضة",
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(
                                    color: TColor.text,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'cairo',
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.sports_outlined,
                                  color: TColor.text,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 100.0,
                        autoPlay: true,
                        aspectRatio: 16 / 9,
                        viewportFraction: 0.28,
                      ),
                      items: sportChannels.map((channel) {
                        return Builder(
                          builder: (BuildContext context) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => watchChannel(
                                        channelPath: channel.channelPath,
                                        channelName: channel.channelTitle,
                                        channelLogo: channel.channelLogo,
                                        channelCategory:
                                            channel.channelCategory),
                                  ),
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: ShaderMask(
                                        shaderCallback: (Rect bounds) {
                                          return LinearGradient(
                                            colors: [
                                              TColor.bg.withOpacity(0),
                                              TColor.bg.withOpacity(0.8),
                                              TColor.bg,
                                            ],
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                          ).createShader(bounds);
                                        },
                                        blendMode: BlendMode.dstATop,
                                        child: CachedNetworkImage(
                                          imageUrl: channel.channelLogo,
                                          width: media.width,
                                          height: media.width / (16 / 9),
                                          fit: BoxFit.cover,
                                          alignment: Alignment.center,
                                          placeholder: (context, url) =>
                                              Container(
                                            color: Colors.grey,
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Image.asset(
                                            "assets/img/background.jpeg",
                                            width: media.width,
                                            height: media.width,
                                            fit: BoxFit.cover,
                                            alignment: Alignment.center,
                                          ),
                                          fadeInDuration:
                                              Duration(milliseconds: 300),
                                          fadeOutDuration:
                                              Duration(milliseconds: 0),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 20,
                                      left: 25,
                                      child: Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                constraints: BoxConstraints(
                                                  maxWidth: media.width - 120,
                                                  maxHeight: 60,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(width: 60),
                                          Container(
                                            height: 50,
                                            width: 50,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              color: TColor.subtext,
                                            ),
                                            alignment: Alignment.center,
                                            child: Icon(
                                              Icons.favorite,
                                              color: TColor.bg,
                                              size: 20,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Container(
                                            height: 50,
                                            width: 50,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(50),
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
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(TColor.primary1),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

String getImagePathOrDefault(String? imagePath, String defaultImagePath) {
  if (imagePath != null && imagePath.isNotEmpty) {
    return imagePath;
  } else {
    return defaultImagePath;
  }
}
