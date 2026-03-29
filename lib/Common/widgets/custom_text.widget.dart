import 'package:flutter/material.dart';

class CustomTextWidget extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final Color? color;
  final double? letterSpacing;
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool? softWrap;
  final TextDecoration? decoration;

  const CustomTextWidget(
      {super.key,
      required this.text,
      this.textAlign,
      this.maxLines,
      this.overflow,
      this.color,
      this.letterSpacing,
      this.fontWeight,
      this.fontSize,
      this.softWrap,
      this.decoration});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          color: color,
          letterSpacing: letterSpacing,
          fontSize: fontSize,
          fontWeight: fontWeight,
          decoration: decoration,
          decorationColor: color),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }
}
