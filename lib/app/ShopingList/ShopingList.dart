import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:local_app/Helper/no_dat_view.dart';
import 'package:local_app/Helper/PullToLoadList.dart';
import 'package:local_app/Helper/helper.dart';
import 'package:local_app/app/AddShopingItem/AddShopingItemScreen.dart';
import 'package:local_app/app/CreateShopingList/CreateShopingList.dart';
import 'package:local_app/app/getx/ShopingListController.dart';
import 'package:local_app/modal/ShopingListModal.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';

class ShopingList extends StatefulWidget {
  final List<ShoppingListModel?>? shoppingList;
  final bool isCompleted;
  const ShopingList({super.key, required this.isCompleted, this.shoppingList});

  @override
  State<ShopingList> createState() => _ShopingListState();
}

class _ShopingListState extends State<ShopingList> {
  final ShopingListController shopingListController = Get.find();

  //* Reload  List
  RefreshController refreshController = RefreshController(
    initialRefresh: false,
  );

  void startReload() {
    shopingListController.loadCompletedShopingList();
    shopingListController.loadInProgressShopingList();
    refreshController.footerMode?.value = LoadStatus.idle;
    refreshController.refreshCompleted();
  }

  Widget listOfTasks() {
    return PullToLoadList(
      refreshController: refreshController,
      onLoading: () => {},
      onRefresh: startReload,
      child:
          widget.shoppingList?.isEmpty == true
              ? NoDataView()
              : ListView.builder(
                itemCount: widget.shoppingList?.length ?? 0,
                itemBuilder: (context, index) {
                  ShoppingListModel task = widget.shoppingList![index]!;
                  return ListTile(
                    leading: Icon(
                      Icons.checklist_rounded,
                      color: widget.isCompleted ? Colors.green : Colors.orange,
                    ),
                    onTap: () {
                      shopingListController.selecteShopListID(
                        task.shopId ?? "0",
                      );
                      Helper().goToPage(
                        context: context,
                        child: AddShopingItem(shopingList: task),
                      );
                    },
                    title: Text(task.title ?? ""),
                    subtitle: Text(task.description ?? ""),
                  );
                },
              ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: listOfTasks(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Helper().goToPage(context: context, child: Createshopinglist());
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
