import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_app/Helper/PullToLoadList.dart';
import 'package:local_app/Helper/helper.dart';
import 'package:local_app/Helper/no_dat_view.dart';
import 'package:local_app/app/AddShopingItem/AddShopingItemScreen.dart';
import 'package:local_app/app/getx/SettingController.dart';
import 'package:local_app/app/getx/ShoppingController.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';

class MyShareUserListScreen extends StatefulWidget {
  const MyShareUserListScreen({super.key});

  @override
  State<MyShareUserListScreen> createState() => _ShareUserListScreenState();
}

class _ShareUserListScreenState extends State<MyShareUserListScreen> {
  final ShoppingController shopingListController = Get.find();
  final SettingController settingController = Get.find();

  //* Reload  List
  RefreshController refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }

  void startReload() {
    shopingListController.getMySharedList();
    refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var list = shopingListController.mySharedList.value;
      return PullToLoadList(
        refreshController: refreshController,
        onLoading: () => {},
        onRefresh: startReload,
        child:
            list.isEmpty == true
                ? NoDataView()
                : ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    var item = list[index]!;
                    return ListTile(
                      onTap: () {
                        if (settingController.offlineMode.value) {
                          shopingListController.selecteShopListID(
                            item.id,
                            null,
                          );
                        } else {
                          shopingListController.selecteShopListID(
                            null,
                            item.shopListId ?? "",
                          );
                        }
                        Helper().goToPage(
                          context: context,
                          child: AddShopingItem(
                            shoppingListModel: item.shopListModal,
                          ),
                        );
                      },
                      leading: Icon(Icons.people_outline),
                      title: Text(item.shopListModal?.shopListName ?? ""),
                      subtitle: Text(item.shopListModal?.description ?? ""),
                    );
                  },
                ),
      );
    });
  }
}
