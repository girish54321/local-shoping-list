import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:local_app/DataBase/shop-list-database.dart';
import 'package:local_app/Helper/loadingListView.dart';
import 'package:local_app/Helper/no_dat_view.dart';
import 'package:local_app/Helper/PullToLoadList.dart';
import 'package:local_app/Helper/helper.dart';
import 'package:local_app/Helper/shopListItem.dart';
import 'package:local_app/app/CreateShopingList/CreateShopingList.dart';
import 'package:local_app/app/SettingsScreen/SettingsScreen.dart';
import 'package:local_app/app/getx/SettingController.dart';
import 'package:local_app/app/getx/ShoppingController.dart';
import 'package:local_app/modal/ShopingListModal.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ShopingList extends StatefulWidget {
  final List<MainShopListItem?>? shoppingList;
  final bool isCompleted;
  const ShopingList({super.key, required this.isCompleted, this.shoppingList});

  @override
  State<ShopingList> createState() => _ShopingListState();
}

class _ShopingListState extends State<ShopingList> {
  final ShoppingController shopingListController = Get.find();
  final SettingController settingController = Get.find();

  //* Reload  List
  RefreshController refreshController = RefreshController(
    initialRefresh: false,
  );

  final SupabaseClient supabase = DatabaseService.supabase;

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
                  MainShopListItem item = widget.shoppingList![index]!;
                  return ShopListItemListTitle(
                    isCompleted: widget.isCompleted,
                    shopListItem: item,
                  );
                },
              ),
    );
  }

  Widget superbaseList() {
    return StreamBuilder(
      stream: supabase.from('shop_list').stream(primaryKey: ['id']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingListView();
        }
        ShopListModal shopListModal = ShopListModal.fromJson({
          'shopList': snapshot.data,
        });

        return ListView.builder(
          itemCount: shopListModal.shopList?.length,
          itemBuilder: (context, index) {
            MainShopListItem? item = shopListModal.shopList?[index];
            return ShopListItemListTitle(
              isCompleted: widget.isCompleted,
              shopListItem: item,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          settingController.appNetworkState.value == AppNetworkState.superbase
              ? superbaseList()
              : listOfTasks(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Helper().goToPage(context: context, child: Createshopinglist());
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
