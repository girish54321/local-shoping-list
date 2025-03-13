import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

class NoDataView extends StatelessWidget {
  final String? title;
  const NoDataView({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return ElasticIn(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.no_food, size: 33),
          SizedBox(height: 16),
          Text(
            title ?? 'No Shopping List Found',
            style: TextStyle(fontSize: 22),
          ),
        ],
      ),
    );
  }
}
