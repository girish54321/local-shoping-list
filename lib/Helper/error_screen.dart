import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

class ErrorView extends StatefulWidget {
  final String? errorMessage;
  final Function onRetry;
  const ErrorView({super.key, this.errorMessage, required this.onRetry});

  @override
  State<ErrorView> createState() => _ErrorViewState();
}

class _ErrorViewState extends State<ErrorView> {
  @override
  Widget build(BuildContext context) {
    return ElasticIn(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_outlined, size: 33),
            SizedBox(height: 16),
            Text(
              widget.errorMessage ?? "",
              style: TextStyle(fontSize: 22),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                widget.onRetry();
              },
              child: Text("Try Again"),
            ),
          ],
        ),
      ),
    );
  }
}
