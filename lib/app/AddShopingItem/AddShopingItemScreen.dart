import 'package:flutter/material.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/state_manager.dart';
import 'package:local_app/DataBase/shop-list-database.dart';
import 'package:local_app/Helper/no_dat_view.dart';
import 'package:local_app/Helper/helper.dart';
import 'package:local_app/app/AddItems/AddItemsScreen.dart';
import 'package:local_app/app/CreateShopingList/CreateShopingList.dart';
import 'package:local_app/app/getx/ShopingListController.dart';
import 'package:local_app/modal/ShopingListModal.dart';

class AddShopingItem extends StatefulWidget {
  final ShoppingListModel shopingList;
  const AddShopingItem({super.key, required this.shopingList});

  @override
  State<AddShopingItem> createState() => _AddShopingItemState();
}

class _AddShopingItemState extends State<AddShopingItem>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseService databaseService = DatabaseService.databaseService;
  final ShopingListController shopingListController = Get.find();

  TextEditingController? itemName = TextEditingController();

  void _addShopingItem(String itemName) {
    var item = ShoppingListItemModel(
      id: widget.shopingList.id,
      name: itemName,
      quantity: 1,
      price: 0,
      status: 0,
    );
    databaseService.addItemToShopingList(item);
    loadListItem();
    setState(() {});
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
                  value: item?.status == 1,
                  onChanged: (val) {
                    databaseService.completeShopingListItem(
                      item!,
                      val == true ? 1 : 0,
                    );
                    loadListItem();
                    setState(() {});
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
            Helper().goToPage(
              context: context,
              child: AddItemsScreen(
                shopListId: widget.shopingList.id ?? 0,
                shopListItem: item,
              ),
            );
          } else {
            Helper().goToPage(
              context: context,
              child: Createshopinglist(updateItem: widget.shopingList),
            );
          }
        }
        if (val == "delete") {
          if (item != null) {
            databaseService.deleteItem(item.id ?? 0);
            loadListItem();
          } else {
            databaseService.deleteShopList(widget.shopingList.id ?? 0);
            loadListItem();
            Navigator.of(context).pop();
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
              Helper().goToPage(
                context: context,
                child: AddItemsScreen(shopListId: widget.shopingList.id ?? 0),
              );
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
          title: Text(widget.shopingList.title ?? ""),
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
