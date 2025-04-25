import 'package:flutter/material.dart';
import 'package:local_app/Helper/helper.dart';

class LoadingListView extends StatefulWidget {
  const LoadingListView({super.key});

  @override
  State<LoadingListView> createState() => _LoadingListViewState();
}

class _LoadingListViewState extends State<LoadingListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 4,
      itemBuilder: (context, index) {
        return Helper().loadingItem(index);
      },
    );
  }
}
