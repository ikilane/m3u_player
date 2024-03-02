import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'LoadData.dart';
import 'common/color_extension.dart';
import 'common_widget/CustomTextField.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login(BuildContext context) async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    final apiUrl =
        'http://shoof.watch:8000/player_api.php?username=$username&password=$password&type=m3u_plus&output=ts';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        // Authentication successful
        // Store login status in SharedPreferences

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('username', username);
        await prefs.setString('password', password);
        // Navigate to LoadData page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoadData(),
          ),
        );
      } else {
        // Authentication failed
        // Show error message or handle accordingly
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Authentication Failed'),
              content: Text('Invalid username or password'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Error occurred during API call
      print('Error: $e');
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred. Please try again later.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: TColor.bg,
      body: SingleChildScrollView(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            SizedBox(
              width: media.width,
              height: media.width,
              child: ClipRect(
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.2),
                    BlendMode.dstATop,
                  ),
                  child: Image.asset(
                    "assets/img/background.jpeg",
                    width: media.width,
                    height: media.width,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Container(
              width: media.width,
              height: media.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    TColor.bg.withOpacity(0),
                    TColor.bg.withOpacity(0),
                    TColor.bg,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: media.width * 0.13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
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
                    CustomTextField(
                      title: ": رقم الهاتف",
                      hintText: "ادخل رقم هاتفك مع المقدمة",
                      obscureText: false,
                      keyboardType: TextInputType.text,
                      controller: _usernameController,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    CustomTextField(
                      title: ": كلمة المرور",
                      hintText: "ادخل كلمة المرور",
                      obscureText: true,
                      controller: _passwordController,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _login(context); // Call the login function
                      },
                      child: Text(
                        'تسجيل الدخول',
                        style: TextStyle(
                            fontFamily:
                                'Cairo'), // Apply Cairo font family here
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
