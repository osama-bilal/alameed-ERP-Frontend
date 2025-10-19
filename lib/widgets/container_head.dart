import 'package:flutter/material.dart';

class MyContainer extends StatelessWidget {
  const MyContainer({super.key, required this.child, this.height, this.width});
  final Widget child;
  final double? height;
  final double? width;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      height: height,
      width: width,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: child,
    );
  }
}
