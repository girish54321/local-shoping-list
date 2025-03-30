import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_app/Helper/PullToLoadList.dart';
import 'package:local_app/Networking/ShopListDataSource/ShopListDataSource.dart';
import 'package:local_app/Networking/unti/result.dart';
import 'package:local_app/app/SavedItemsList/SaveItemInputs.dart';
import 'package:local_app/app/getx/SettingController.dart';
import 'package:local_app/modal/common_items.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';

class SavedItemsList extends StatefulWidget {
  const SavedItemsList({super.key});

  @override
  State<SavedItemsList> createState() => _SavedItemsListState();
}

class _SavedItemsListState extends State<SavedItemsList> {
  List<CommonItemsItems> items = [];
  ShopListDataSource apiResponse = ShopListDataSource();
  TextEditingController? itemName = TextEditingController();

  final SettingController settingController = Get.find();

  RefreshController refreshController = RefreshController(
    initialRefresh: false,
  );

  void getAllItems() {
    if (settingController.offlineMode.value) {
      return;
    }
    Future<Result> result = apiResponse.getCommonItems();
    result.then((value) {
      if (value is SuccessState) {
        var res = value.value as CommonItems;
        setState(() {
          items = res.items as List<CommonItemsItems>;
        });
      } else {}
    });
  }

  @override
  void initState() {
    getAllItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Saved Items')),
      body: PullToLoadList(
        refreshController: refreshController,
        onRefresh: () {},
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 12),
          itemCount: items.length,
          itemBuilder: (context, index) {
            var listItem = items[index];
            return SaveItemInputs(item: listItem);
          },
        ),
        onLoading: () {},
      ),
    );
  }
}
