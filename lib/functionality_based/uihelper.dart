import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color semiTransparentWhite = Color(0x33FFFFFF);
  static const Color shadowColor = Color(0x33000000);
  static const Color volumeIcon = Color(0xFF4169E1);
  static const Color bookmarkIcon = Color(0xFFFF6347);
  static const Color successGreen = Colors.green;
  static const Color errorRed = Colors.redAccent;
}

class CustomIconButton extends StatelessWidget {
  final IconData iconData;
  final VoidCallback onPressed;

  const CustomIconButton({
    Key? key,
    required this.iconData,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 35,
        width: 35,
        decoration: const BoxDecoration(
          color: AppColors.semiTransparentWhite,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(
            iconData,
            size: 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class CustomCardButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double height;
  final double? width;
  final Color color;
  final double textSize;

  const CustomCardButton({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.height,
    this.width,
    required this.color,
    required this.textSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 20,
              offset: Offset(0, 8),
            )
          ],
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.interTight(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: textSize,
            ),
          ),
        ),
      ),
    );
  }
}