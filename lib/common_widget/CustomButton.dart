import 'package:flutter/material.dart';
import '../common/color_extension.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final double height; // New variable for height

  const CustomButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.height = 50, // Default height
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: height, // Use the provided height
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: TColor.primaryG,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter)),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
              color: TColor.btnText, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
