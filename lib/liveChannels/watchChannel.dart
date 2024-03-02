import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

import '../common/CustomAppBar.dart';
import '../common/color_extension.dart';

class watchChannel extends StatefulWidget {
  final String channelName;
  final String channelPath;
  final String channelLogo;
  final String channelCategory;

  const watchChannel({
    Key? key,
    required this.channelPath,
    required this.channelName,
    required this.channelLogo,
    required this.channelCategory,
  }) : super(key: key);

  @override
  _watchChannelState createState() => _watchChannelState();
}

class _watchChannelState extends State<watchChannel> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
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
      looping: true,
      aspectRatio: 16 / 9,
      isLive: true,
      showOptions: false,
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
            SizedBox(height: 15),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    backgroundColor: _isFavorite ? Colors.red : TColor.subtext,
                    child: IconButton(
                      icon: Icon(
                        Icons.favorite_border,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _isFavorite = !_isFavorite;
                        });
                      },
                    ),
                  ),
                  Spacer(),
                  Text(
                    widget.channelCategory,
                    style: TextStyle(
                      color: TColor.text,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8),
                  CircleAvatar(
                    child: Icon(
                      Icons.info_outlined,
                      color: Colors.white,
                    ),
                    backgroundColor: TColor.primary1,
                  ),
                  Spacer(),
                  Text(
                    widget.channelName,
                    style: TextStyle(
                      color: TColor.text,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8),
                  CircleAvatar(
                    backgroundImage: NetworkImage(widget.channelLogo),
                  ),
                ],
              ),
            ),
            SizedBox(height: 50),
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
