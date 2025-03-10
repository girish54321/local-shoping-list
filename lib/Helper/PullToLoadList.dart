import 'package:flutter/material.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';

class PullToLoadList extends StatelessWidget {
  final RefreshController refreshController;
  final Function() onRefresh;
  final Function() onLoading;
  final Widget child;
  const PullToLoadList({
    Key? key,
    required this.refreshController,
    required this.onRefresh,
    required this.child,
    required this.onLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      controller: refreshController,
      onRefresh: onRefresh,
      onLoading: onLoading,
      child: child,
    );
  }
}
