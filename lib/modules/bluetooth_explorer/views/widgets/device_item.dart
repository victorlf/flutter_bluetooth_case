import 'package:flutter/material.dart';

class DeviceItem extends StatelessWidget {
  final String content;
  final void Function() onPressed;
  const DeviceItem({super.key, required this.content, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
          // backgroundColor: Colors.yellow.shade900,
          fixedSize: const Size(50.0, 30.0)),
      child: Text(content),
    );
  }
}
