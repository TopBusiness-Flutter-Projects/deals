import 'package:flutter/material.dart';
import 'package:top_sale/core/utils/app_colors.dart';
import 'package:top_sale/core/utils/get_size.dart';

class RoundedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;

  const RoundedButton({
    super.key,
    required this.text,
    required this.onPressed, required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width:getSize(context)/1,  // Full width button
      height: getSize(context)/8,              // Fixed height
      child: ElevatedButton(
        onPressed: onPressed,

        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0), // Rounded edges
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: AppColors.white,
            fontSize: getSize(context)/22,
            fontWeight: FontWeight.bold,
          ),
          textDirection: TextDirection.rtl, // For Arabic text
        ),
      ),
    );
  }
}
