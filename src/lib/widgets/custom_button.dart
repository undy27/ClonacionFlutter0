import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        SystemSound.play(SystemSoundType.click);
        onPressed();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
      ),
      child: Text(text),
    );
  }
}
