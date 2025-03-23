import 'package:flutter/material.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/state_manager.dart';
import 'package:local_app/DataBase/shop-list-database.dart';
import 'package:local_app/Helper/no_dat_view.dart';
import 'package:local_app/Helper/helper.dart';
import 'package:local_app/Networking/ShopListDataSource/ShopListDataSource.dart';
import 'package:local_app/Networking/unti/result.dart';
import 'package:local_app/app/AddItems/AddItemsScreen.dart';
import 'package:local_app/app/CreateShopingList/CreateShopingList.dart';
import 'package:local_app/app/getx/ShopingListController.dart';
import 'package:local_app/modal/ShopingListModal.dart';
import 'package:local_app/modal/operation_response.dart';

class AddShopingItem extends StatefulWidget {
  final ShoppingListModel? shoppingListModel;
  const AddShopingItem({super.key, this.shoppingListModel});

  @override
  State<AddShopingItem> createState() => _AddShopingItemState();
}

class _AddShopingItemState extends State<AddShopingItem>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseService databaseService = DatabaseService.databaseService;
  final ShopingListController shopingListController = Get.find();

  TextEditingController? itemName = TextEditingController();
  ShopListDataSource apiResponse = ShopListDataSource();

  void _addShopingItem(String itemName) {
    var item = ShoppingListItemModel(
      itemId: shopingListController.selectedState.value.remoteShopListID,
      name: itemName,
      quantity: 1,
      price: 0,
      status: 0,
    );
    shopingListController.createShopListItem(item);
  }

  void loadListItem() {
    shopingListController.getShopingListItemCompleted();
    shopingListController.getShopingListItemInProgress();
    shopingListController.loadCompletedShopingList();
    shopingListController.loadInProgressShopingList();
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
    itemName?.dispose();
    super.dispose();
  }

  Widget listOfItem(bool isCompletedList) {
    return Obx(() {
      var completedList = shopingListController.completedShopingListItem.value;
      var inprogressList =
          shopingListController.inprogressShopingListItem.value;
      return Stack(
        children: [
          (isCompletedList && completedList!.isEmpty ||
                  !isCompletedList && inprogressList!.isEmpty)
              ? Center(child: NoDataView())
              : SizedBox(),
          ListView.builder(
            itemCount:
                ((isCompletedList ? completedList : inprogressList)?.length ??
                    0) +
                1,
            itemBuilder: (context, index) {
              if (index == 0) {
                if (isCompletedList) {
                  return SizedBox();
                }
                return ListTile(
                  title: TextField(
                    controller: itemName,
                    textInputAction: TextInputAction.go,
                    onSubmitted: (value) {
                      _addShopingItem(value);
                      itemName?.text = "";
                    },
                    decoration: InputDecoration(
                      labelText: "Enter your item name",
                    ),
                  ),
                );
              }
              ShoppingListItemModel? item =
                  isCompletedList
                      ? completedList![index - 1]
                      : inprogressList![index - 1];
              return ListTile(
                title: Text(item?.name ?? "Nice "),
                subtitle:
                    item?.quantity != null
                        ? Text(
                          "Quantity: ${item?.quantity?.toString()} / Price: ${item?.price}",
                        )
                        : null,
                trailing: openPopUpMenu(item),
                leading: Checkbox(
                  value: item?.completed == "completed" ? true : false,
                  onChanged: (val) {
                    Future<Result> result = apiResponse.updateShopListItemState(
                      {"shopListId": item?.itemId, "isCompleted": val},
                    );
                    result.then((value) {
                      if (value is SuccessState) {
                        Helper().hideLoading();
                        var res = value.value as OperationResponse;
                        if (res.success == true) {
                          loadListItem();
                          setState(() {});
                        }
                      }
                    });
                  },
                ),
              );
            },
          ),
        ],
      );
    });
  }

  Widget openPopUpMenu(ShoppingListItemModel? item) {
    return PopupMenuButton<String>(
      onSelected: (val) {
        if (val == "edit") {
          if (item != null) {
            shopingListController.selecteListItemStateID(null, item.itemId);
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
            shopingListController.deleteShopListItem(item.itemId ?? "0");
          } else {
            shopingListController.deleteShopList();
          }
          setState(() {});
          return;
        }
      },
      itemBuilder: (BuildContext context) {
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
        ].map((AppMenuItem choice) {
          return PopupMenuItem<String>(value: choice.id, child: choice.widget);
        }).toList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Shopping Item'),
        actions: [
          IconButton(
            onPressed: () {
              Helper().goToPage(context: context, child: AddItemsScreen());
            },
            icon: Icon(Icons.add),
          ),
          openPopUpMenu(null),
        ],
        bottom: TabBar(
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
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[listOfItem(false), listOfItem(true)],
      ),
      bottomNavigationBar: SafeArea(
        child: ListTile(
          title: Text("Nice View"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.card_travel),
              // Padding(padding: EdgeInsets.only(left: 6), child: Text("209/-")),
            ],
          ),
        ),
      ),
    );
  }
}
