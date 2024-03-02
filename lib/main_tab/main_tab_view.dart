import 'package:flutter/material.dart';
import 'package:m3u_nullsafe/m3u_nullsafe.dart';
import '../common/color_extension.dart';
import '../home/homeView.dart';

class MainTabView extends StatefulWidget {
  final Map<String, Map<String, List<M3uGenericEntry>>> categorizedTracks;

  const MainTabView({Key? key, required this.categorizedTracks})
      : super(key: key);

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView>
    with TickerProviderStateMixin {
  int selectTab = 0;
  TabController? controller;
  bool isSearchOverlayVisible = false;

  @override
  void initState() {
    super.initState();

    controller = TabController(
        length: 5, vsync: this, initialIndex: 2); // Set initial index to 2
    controller?.addListener(() {
      selectTab = controller?.index ?? 0;
      if (mounted) {
        setState(() {});
      }
    });
  }

  void toggleSearchOverlay() {
    setState(() {
      isSearchOverlayVisible = !isSearchOverlayVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.bg,
        elevation: 0,
        automaticallyImplyLeading: false, // Set this property to false
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Search on the left
            IconButton(
              onPressed: () {
                toggleSearchOverlay(); // Toggle search overlay visibility
              },
              icon: Icon(Icons.search, color: Colors.white),
            ),
            // Logo on the right
            Image.asset(
              "assets/img/logo-icon.png",
              width: 80,
              height: 80,
            ),
          ],
        ),
      ),

      body: Stack(
        children: [
          // Main content of the screen
          Container(
            color: TColor.bg,
            child: TabBarView(
              controller: controller,
              children: [
                Container(), // Placeholder for other tabs
                Container(), // Placeholder for other tabs
                HomeView(categorizedTracks: widget.categorizedTracks),
                Container(), // Placeholder for other tabs
                Container(), // Placeholder for other tabs
              ],
            ),
          ),
          // Search overlay
          isSearchOverlayVisible
              ? Overlay(
                  initialEntries: [
                    OverlayEntry(
                      builder: (context) => Positioned.fill(
                        child: GestureDetector(
                          onTap: () {
                            toggleSearchOverlay();
                          },
                          child: Container(
                            color: Colors.black.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ),
                    OverlayEntry(
                      builder: (context) => Center(
                        child: Container(
                          alignment:
                              Alignment.topCenter, // Align at the top center
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          padding: EdgeInsets.all(0),
                          child: TextField(
                            textDirection: TextDirection.rtl,
                            cursorColor: TColor.primary1,
                            style: TextStyle(color: TColor.text),
                            decoration: InputDecoration(
                              hintText: "إبحث عن قناة او فيلم او مسلسل...",
                              hintStyle: TextStyle(
                                  color: TColor.subtext, fontSize: 12),
                              hintTextDirection: TextDirection.rtl,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: TColor.subtext),
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: TColor
                                        .primary1), // Set the color for focused state
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                              suffixIcon:
                                  Icon(Icons.search, color: TColor.subtext),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 12.0),
                              alignLabelWithHint:
                                  true, // Align the hint text with the start of the input field
                              hintMaxLines:
                                  1, // Ensure that the hint is on a single line
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Container(),
        ],
      ),
      backgroundColor: TColor.bg,
      // No FloatingActionButton
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: TColor.bg),
        child: BottomAppBar(
          color: TColor.tabBg,
          elevation: 0,
          child: TabBar(
            controller: controller,
            indicatorColor: Colors.transparent,
            dividerColor: Colors.transparent,
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            unselectedLabelStyle: TextStyle(
              color: TColor.subtext,
              fontSize: 9,
              fontFamily: "cairo",
              fontWeight: FontWeight.w600,
            ),
            labelStyle: TextStyle(
              color: TColor.primary2,
              fontSize: 9,
              fontFamily: "cairo",
              fontWeight: FontWeight.w600,
            ),
            labelColor: TColor.primary2,
            unselectedLabelColor: TColor.subtext,
            tabs: const [
              Tab(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Icon(Icons.sports_football_outlined, size: 25),
                    ),
                    SizedBox(height: 0),
                    Expanded(
                      child: Text("رياضة"),
                    ),
                  ],
                ),
              ),
              Tab(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Icon(Icons.live_tv_outlined, size: 25),
                    ),
                    SizedBox(height: 0),
                    Expanded(
                      child: Text("مباشر"),
                    ),
                  ],
                ),
              ),
              Tab(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Icon(Icons.home_outlined, size: 25),
                    ),
                    SizedBox(height: 0),
                    Expanded(
                      child: Text("الرئيسية"),
                    ),
                  ],
                ),
              ),
              Tab(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Icon(Icons.local_movies_outlined, size: 25),
                    ),
                    SizedBox(height: 0),
                    Expanded(
                      child: Text("أفلام"),
                    ),
                  ],
                ),
              ),
              Tab(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Icon(Icons.movie_creation_outlined, size: 25),
                    ),
                    SizedBox(height: 0),
                    Expanded(
                      child: Text("مسلسلات"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
