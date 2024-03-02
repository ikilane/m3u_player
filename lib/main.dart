import 'package:flutter/material.dart';
import 'package:m3u_player/LoadData.dart';
import 'package:m3u_player/common/color_extension.dart';
import 'LoginPage.dart';
import 'LoadData.dart'; // Import the HomePage.dart file where the user should be redirected if logged in
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login Demo',
      theme: ThemeData(
        backgroundColor: TColor.bg,
        primaryColor:
            TColor.primary1, // Changed to primaryColor for consistency
        // Additional theme customization can be added here
      ),
      home: FutureBuilder(
        // Use FutureBuilder to check if the user is logged in or not
        future:
            isLoggedIn(), // Call the function to check if the user is logged in
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // If the future is not yet complete, show a loading indicator
            return CircularProgressIndicator();
          } else {
            // If the future is complete, check the authentication status
            if (snapshot.data == true) {
              // If the user is logged in, navigate to the HomePage
              return LoadData();
            } else {
              // If the user is not logged in, navigate to the LoginPage
              return LoginPage();
            }
          }
        },
      ),
    );
  }

  Future<bool> isLoggedIn() async {
    // Check if the user is logged in by retrieving the authentication status from shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    return isLoggedIn;
  }
}
