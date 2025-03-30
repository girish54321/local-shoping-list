import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_app/Networking/modal/error_modal.dart';

class DialogHelper {
  //show error dialog
  static void showErrorDialog({
    String? title = 'Error',
    String? description = 'Something went wrong',
    ErrorModalError? error,
  }) {
    Get.dialog(
      GetPlatform.isAndroid
          ? AlertDialog(
            title: Text("Error: ${error?.status}"),
            content: Text(error?.message ?? description!),
            actions: [
              TextButton(
                child: const Text('Okay'),
                onPressed: () {
                  Get.until((route) => !Get.isDialogOpen!);
                },
              ),
            ],
            scrollable: true,
          )
          : CupertinoAlertDialog(
            title: Text("Error: ${error?.status}"),
            content: Text(error?.message ?? description!),
            actions: [
              TextButton(
                child: const Text('Okay'),
                onPressed: () {
                  Get.until((route) => !Get.isDialogOpen!);
                },
              ),
            ],
          ),
      barrierDismissible: true,
    );
  }

  //show toast
  //show snack bar
  //show loading
  static void showLoading([String? message]) {
    Get.dialog(
      GetPlatform.isAndroid
          ? AlertDialog(
            content: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 8),
                  Text(message ?? 'Loading...'),
                ],
              ),
            ),
            scrollable: true,
          )
          : CupertinoAlertDialog(
            content: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 8),
                  Text(message ?? 'Loading...'),
                ],
              ),
            ),
          ),
      barrierDismissible: true,
    );
  }

  //hide loading
  static void hideLoading() {
    if (Get.isDialogOpen!) Get.back();
  }
}

enum DialogAction { yes, abort }

class Dialogs {
  static Future<DialogAction> yesAbortDialog(
    BuildContext context,
    String title,
    String body,
  ) async {
    final action = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(title),
          content: Text(body),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(DialogAction.abort),
              child: const Text('No'),
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () => Navigator.of(context).pop(DialogAction.yes),
            ),
          ],
        );
      },
    );
    return (action != null) ? action : DialogAction.abort;
  }
}
