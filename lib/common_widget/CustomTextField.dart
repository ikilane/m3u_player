import 'package:flutter/material.dart';
import '../common/color_extension.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String title;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool focusOnInit; // Flag for default focus

  const CustomTextField({
    super.key,
    required this.title,
    this.controller,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.focusOnInit = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.focusOnInit) {
      Future.delayed(Duration.zero, () {
        _focusNode.requestFocus();
        _openKeyboard();
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _openKeyboard() {
    FocusScope.of(context).requestFocus(_focusNode);
    // Optionally use platform-specific APIs for keyboard visibility
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      textDirection: TextDirection.rtl,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: TextStyle(
              color: TColor.text, fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(
          height: 8,
        ),
        Container(
            height: 50,
            decoration: BoxDecoration(
              color: TColor.card,
              boxShadow: const [
                BoxShadow(
                    color: Color.fromARGB(10, 0, 0, 0),
                    blurRadius: 5,
                    offset: Offset(0, 5))
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    cursorColor: TColor.primary1,
                    autocorrect: false,
                    obscureText: widget.obscureText,
                    // textDirection: TextDirection.rtl,
                    keyboardType: widget.keyboardType,
                    style: TextStyle(color: TColor.text),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 15),
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: widget.hintText,
                      hintStyle: TextStyle(
                          color: TColor.subtext,
                          fontSize: 13,
                          fontWeight: FontWeight.w100),
                      // hintTextDirection: TextDirection.rtl,
                    ),
                    focusNode: _focusNode, // Assign the FocusNode
                  ),
                ),
              ],
            )),
      ],
    );
  }
}
