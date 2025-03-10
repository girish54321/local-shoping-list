import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final Widget child;
  final Color? color;
  final Function() function;

  const AppButton({
    super.key,
    this.color,
    required this.child,
    required this.function,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0)),
      child: ElevatedButton(
        onPressed: function,
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(color: Colors.black),
        ),
        child: SizedBox(height: 55, child: child),
      ),
    );
  }
}
