import 'dart:io';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class Helper {
  goToPage({required BuildContext context, required Widget child}) {
    if (Platform.isAndroid) {
      Navigator.push(
        context,
        PageTransition(type: PageTransitionType.rightToLeft, child: child),
      );
    }
    if (Platform.isIOS) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => child));
    }
  }
}
