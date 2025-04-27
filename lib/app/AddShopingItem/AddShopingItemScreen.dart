import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/state_manager.dart';
import 'package:local_app/DataBase/shop-list-database.dart';
import 'package:local_app/Helper/PullToLoadList.dart';
import 'package:local_app/Helper/auto-complet.dart';
import 'package:local_app/Helper/loadingListView.dart';
import 'package:local_app/Helper/no_dat_view.dart';
import 'package:local_app/Helper/helper.dart';
import 'package:local_app/Helper/shopListItem.dart';
import 'package:local_app/Networking/ShopListDataSource/ShopListDataSource.dart';
import 'package:local_app/Networking/unti/result.dart';
import 'package:local_app/app/AddItems/add_items_screen.dart';
import 'package:local_app/app/CloneShopList/CloneShopList.dart';
import 'package:local_app/app/CreateShopingList/CreateShopingList.dart';
import 'package:local_app/app/SettingsScreen/SettingsScreen.dart';
import 'package:local_app/app/ShareUserListScreen/ShareUserListScreen.dart';
import 'package:local_app/app/getx/SettingController.dart';
import 'package:local_app/app/getx/ShoppingController.dart';
import 'package:local_app/modal/ShopingListModal.dart';
import 'package:local_app/modal/all_shop_list_items.dart';
import 'package:local_app/modal/common_items.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppMenuItem {
  final String id;
  final Widget widget;
  AppMenuItem(this.id, this.widget);
}

class AddShopingItem extends StatefulWidget {
  final MainShopListItem? shoppingListModel;
  const AddShopingItem({super.key, this.shoppingListModel});

  @override
  State<AddShopingItem> createState() => _AddShopingItemState();
}

class _AddShopingItemState extends State<AddShopingItem>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseService databaseService = DatabaseService.databaseService;

  final ShoppingController shopingListController = Get.find();
  final SettingController settingController = Get.find();

  ShopListDataSource apiResponse = ShopListDataSource();
  final SupabaseClient supabase = DatabaseService.supabase;

  //* Reload  List
  RefreshController inprogressRefreshController = RefreshController(
    initialRefresh: false,
  );
  RefreshController completedRefreshController = RefreshController(
    initialRefresh: false,
  );

  void _addShopingItem(CommonItemsItems commonItems) {
    var item = ShopListItems(
      id: shopingListController.selectedState.value.localShopListID,
      shopListId: shopingListController.selectedState.value.remoteShopListID,
      shopListItemsId:
          shopingListController.selectedState.value.remoteShopListID,
      itemName: commonItems.itemName,
      superBaseId:
          shopingListController.selectedState.value.superBaseShopListID,
      quantity: commonItems.quantity,
      description: "NA",
      price: commonItems.price,
      state: 'not-completed',
    );
    shopingListController.createShopListItem(item);
    var timer = Timer(Duration(seconds: 1), () => setState(() {}));
    timer.cancel();
  }

  void loadListItem() {
    if (settingController.appNetworkState.value == AppNetworkState.superbase) {
      return;
    }
    shopingListController.getShopingListItemCompleted();
    shopingListController.getShopingListItemInProgress();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadListItem();
  }

  @override
  void dispose() {
    _tabController.dispose();
    inprogressRefreshController.dispose();
    completedRefreshController.dispose();
    super.dispose();
  }

  Widget listOfItem(bool isCompletedList, bool isOwner) {
    return Obx(() {
      var completedList = shopingListController.completedShopingListItem.value;
      var inprogressList =
          shopingListController.inprogressShopingListItem.value;

      final inProgressStatus =
          shopingListController.inprogressShopingListItem.value.status;
      final completedStatus =
          shopingListController.completedShopingListItem.value.status;

      var isLoading =
          inProgressStatus == LoadingStatus.loading ||
          completedStatus == LoadingStatus.loading;

      if (isLoading) {
        return LoadingListView();
      }

      return Stack(
        children: [
          (isCompletedList && completedList.data!.isEmpty ||
                  !isCompletedList && inprogressList.data!.isEmpty)
              ? Center(child: NoDataView())
              : SizedBox(),
          PullToLoadList(
            refreshController:
                isCompletedList
                    ? completedRefreshController
                    : inprogressRefreshController,
            onLoading: () {},
            onRefresh: () {
              loadListItem();
              if (isCompletedList) {
                completedRefreshController.footerMode?.value = LoadStatus.idle;
                completedRefreshController.refreshCompleted();
              } else {
                inprogressRefreshController.footerMode?.value = LoadStatus.idle;
                inprogressRefreshController.refreshCompleted();
              }
            },
            child: ListView.builder(
              itemCount:
                  ((isCompletedList ? completedList : inprogressList)
                          .data
                          ?.length ??
                      0) +
                  1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  if (isCompletedList) {
                    return SizedBox();
                  }
                  return AutoComplet(
                    isOwner: isOwner,
                    onItemTap: (item) {
                      _addShopingItem(item);
                    },
                  );
                }
                ShopListItems? item =
                    isCompletedList
                        ? completedList.data![index - 1]
                        : inprogressList.data![index - 1];
                bool isChecked = item.state == 'completed' ? true : false;
                return AddShopingItemUI(
                  isChecked: isChecked,
                  isOwner: isOwner,
                  onChanged: (val) {
                    setState(() {});
                  },
                  item: item,
                  trailing: openPopUpMenu(item),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget openPopUpMenu(ShopListItems? item) {
    return PopupMenuButton<String>(
      onSelected: (val) {
        var isOwner = shopingListController.isOwner.value;
        var offline =
            settingController.appNetworkState.value == AppNetworkState.offline;

        var appNetworkState = settingController.appNetworkState.value;

        // var allowAction =
        //     offline
        //         ? true
        //         : isOwner
        //         ? true
        //         : false;
        var allowAction = true;

        if (val == "clone" && !offline) {
          var completedList =
              shopingListController.completedShopingListItem.value;
          var inprogressList =
              shopingListController.inprogressShopingListItem.value;
          var allItems = [...?completedList.data, ...?inprogressList.data];
          Helper().goToPage(
            context: context,
            child: CloneShopList(
              allItems: allItems,
              shoppingListModel: widget.shoppingListModel,
            ),
          );
          return;
        }

        if (!allowAction) {
          return;
        }

        if (val == "edit") {
          if (item != null) {
            if (appNetworkState == AppNetworkState.superbase) {
              shopingListController.selecteListItemStateID(
                null,
                null,
                item.shopListItemsId,
              );
            } else {
              shopingListController.selecteListItemStateID(
                null,
                item.shopListItemsId,
                null,
              );
            }
            Helper().goToPage(
              context: context,
              child: AddItemsScreen(shopListItem: item),
            );
          } else {
            Helper().goToPage(
              context: context,
              child: Createshopinglist(updateItem: widget.shoppingListModel),
            );
          }
        }
        if (val == "delete") {
          if (item != null) {
            if (appNetworkState == AppNetworkState.superbase) {
              shopingListController.deleteShopListItem(
                null,
                null,
                item.shopListItemsId,
              );
            } else {
              shopingListController.deleteShopListItem(
                item.shopListItemsId,
                item.id,
                null,
              );
            }
          } else {
            shopingListController.deleteShopList();
          }
          setState(() {});
          return;
        }
      },
      itemBuilder: (BuildContext context) {
        var offline =
            settingController.appNetworkState.value == AppNetworkState.offline;
        return [
          AppMenuItem(
            "edit",
            const ListTile(leading: Icon(Icons.edit), title: Text("Edit")),
          ),
          AppMenuItem(
            "delete",
            const ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text("Delete"),
            ),
          ),
          if (item == null && !offline)
            AppMenuItem(
              "clone",
              const ListTile(
                leading: Icon(Icons.offline_pin_outlined, color: Colors.green),
                title: Text("Clone"),
              ),
            ),
        ].map((AppMenuItem choice) {
          return PopupMenuItem<String>(value: choice.id, child: choice.widget);
        }).toList();
      },
    );
  }

  Widget superBaseList() {
    return StreamBuilder(
      stream: supabase
          .from('shop_list_item')
          .stream(primaryKey: ['shopListItemsId'])
          .eq(
            'shopListId',
            shopingListController.selectedState.value.superBaseShopListID!,
          ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LoadingListView();
        }

        final List<dynamic> data = snapshot.data!;
        return ListView.builder(
          itemCount: data.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return AutoComplet(
                isOwner: true,
                onItemTap: (item) {
                  _addShopingItem(item);
                },
              );
            }
            final itemData = data[index - 1];
            ShopListItems item = ShopListItems.fromJson(itemData);
            bool isChecked = item.state == 'completed';

            return AddShopingItemUI(
              key: ValueKey(item.id?.toString()),
              isChecked: isChecked,
              isOwner: true,
              onChanged: (val) {},
              item: item,
              trailing: openPopUpMenu(item),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var isOwner = shopingListController.isOwner.value;
      var offline =
          settingController.appNetworkState.value == AppNetworkState.offline;
      var isSuperbase =
          settingController.appNetworkState.value == AppNetworkState.superbase;
      var allowAction =
          offline
              ? true
              : isOwner
              ? true
              : false;
      return Scaffold(
        appBar: AppBar(
          title: Text('Add Shopping Item'),
          actions: [openPopUpMenu(null)],
          bottom:
              isSuperbase
                  ? null
                  : TabBar(
                    controller: _tabController,
                    onTap: (index) {
                      if (index == 1) {}
                    },
                    tabs: const <Widget>[
                      Tab(icon: Icon(Icons.check)),
                      Tab(icon: Icon(Icons.check_circle_outline)),
                    ],
                  ),
        ),
        // body: listOfItem(),
        body:
            isSuperbase
                ? superBaseList()
                : TabBarView(
                  controller: _tabController,
                  children: [
                    listOfItem(false, allowAction),
                    listOfItem(true, allowAction),
                  ],
                ),
        bottomNavigationBar: SafeArea(
          child: ListTile(
            title: Text("Shared with others"),
            subtitle:
                !offline && isOwner
                    ? Text("Share your list with others!")
                    : Text("Not available in offline mode!"),
            trailing: FloatingActionButton(
              onPressed:
                  !offline
                      ? () {
                        Helper().goToPage(
                          context: context,
                          child: ShareUserListScreen(),
                        );
                      }
                      : null,
              child: Icon(Icons.add),
            ),
          ),
        ),
      );
    });
  }
}
