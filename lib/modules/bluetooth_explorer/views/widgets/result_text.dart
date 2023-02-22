import 'package:flutter/material.dart';

class ResultText extends StatelessWidget {
  final String content;
  final Color? textColor;
  const ResultText({super.key, required this.content, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        content,
        style: TextStyle(color: textColor),
      ),
    );
  }
}
