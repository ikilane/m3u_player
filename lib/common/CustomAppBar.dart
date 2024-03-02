import 'package:flutter/material.dart';

import 'color_extension.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({
    Key? key, // Made nullable
  }) : super(key: key);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  void onBackPressed() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: TColor.bg,
      elevation: 0,
      automaticallyImplyLeading: false, // Set this property to false
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Search on the left
          IconButton(
            onPressed: onBackPressed, // Call local function
            icon: Icon(Icons.arrow_back, color: Colors.white),
          ),
          // Logo on the right
          Image.asset(
            "assets/img/logo-icon.png",
            width: 80,
            height: 80,
          ),
        ],
      ),
    );
  }
}
