import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_app/Helper/DialogHelper.dart';
import 'package:page_transition/page_transition.dart';
import 'package:progress_indicators/progress_indicators.dart';

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

  goBack() {
    Get.back();
  }

  dismissKeyBoard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  showLoading([String? message]) {
    DialogHelper.showLoading(message);
  }

  hideLoading() {
    Get.until((route) => !Get.isDialogOpen!);
  }

  Widget loadingItem(int index) {
    return Container(
      height: 80,
      margin: EdgeInsets.all(6),
      child: GlowingProgressIndicator(
        duration: Duration(milliseconds: (index + 5) * 100),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.4),
            borderRadius: const BorderRadius.all(Radius.circular(4)),
          ),
        ),
      ),
    );
  }
}
