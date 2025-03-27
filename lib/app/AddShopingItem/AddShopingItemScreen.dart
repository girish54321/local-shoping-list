import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/state_manager.dart';
import 'package:local_app/DataBase/shop-list-database.dart';
import 'package:local_app/Helper/no_dat_view.dart';
import 'package:local_app/Helper/helper.dart';
import 'package:local_app/Networking/ShopListDataSource/ShopListDataSource.dart';
import 'package:local_app/app/AddItems/AddItemsScreen.dart';
import 'package:local_app/app/CreateShopingList/CreateShopingList.dart';
import 'package:local_app/app/getx/ShopingListController.dart';
import 'package:local_app/modal/ShopingListModal.dart';
import 'package:local_app/modal/all_shop_list_items.dart';

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
  final ShopingListController shopingListController = Get.find();

  TextEditingController? itemName = TextEditingController();
  ShopListDataSource apiResponse = ShopListDataSource();
  final countries = [
    'Argentina',
    'Australia',
    'Brazil',
    'Canada',
    'China',
    'France',
    'Germany',
    'India',
    'Indonesia',
    'Italy',
  ];
  void _addShopingItem(String itemName) {
    var item = ShopListItems(
      id: shopingListController.selectedState.value.localShopListID,
      shopListItemsId:
          shopingListController.selectedState.value.remoteShopListID,
      itemName: itemName,
      quantity: 1,
      price: 0,
      state: 'not-completed',
    );
    shopingListController.createShopListItem(item);
    var timer = Timer(Duration(seconds: 1), () => setState(() {}));
    timer.cancel();
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
                  title: Autocomplete<String>(
                    fieldViewBuilder: (
                      context,
                      controller,
                      focusNode,
                      onEditingComplete,
                    ) {
                      itemName = controller;
                      return TextField(
                        controller: itemName,
                        focusNode: focusNode,
                        onEditingComplete: () {
                          onEditingComplete();
                        },
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                            },
                            icon: Icon(Icons.close),
                          ),
                          hintText: "widget.hint",
                          hintStyle: TextStyle(color: Colors.grey[400]),
                        ),
                        onSubmitted: (value) {
                          print("Add this item");
                          print(value);
                          _addShopingItem(value);
                          FocusScope.of(context).unfocus();
                          itemName?.text = "";
                        },
                      );
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxHeight: 200),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (context, index) {
                                final String option = options.elementAt(index);
                                return ListTile(
                                  title: Text(option),
                                  onTap: () => onSelected(option),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return countries;
                      }

                      return countries.where(
                        (country) => country.toLowerCase().contains(
                          textEditingValue.text.toLowerCase(),
                        ),
                      );
                    },
                    onSelected: (suggestion) {
                      // handle user selection of a country
                    },
                  ),
                );
              }
              ShopListItems? item =
                  isCompletedList
                      ? completedList![index - 1]
                      : inprogressList![index - 1];
              bool isChecked = item?.state == 'completed' ? true : false;
              print("item");
              print(item?.quantity);
              return ListTile(
                title: Text(item?.itemName ?? "NA"),
                subtitle:
                    item?.quantity != null
                        ? Text(
                          "Quantity: ${item?.quantity?.toString()} / Price: ${item?.price}",
                        )
                        : null,
                trailing: openPopUpMenu(item),
                leading: Checkbox(
                  value: isChecked,
                  onChanged: (val) {
                    shopingListController.updateItemState(item, val);
                  },
                ),
              );
            },
          ),
        ],
      );
    });
  }

  Widget openPopUpMenu(ShopListItems? item) {
    return PopupMenuButton<String>(
      onSelected: (val) {
        if (val == "edit") {
          if (item != null) {
            shopingListController.selecteListItemStateID(
              null,
              item.shopListItemsId,
            );
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
            shopingListController.deleteShopListItem(
              item.shopListItemsId,
              item.id,
            );
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
          //TODO: Keeping this spmiple
          // IconButton(
          //   onPressed: () {
          //     Helper().goToPage(context: context, child: AddItemsScreen());
          //   },
          //   icon: Icon(Icons.add),
          // ),
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
          title: Text("Shared with"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(child: Text("GP")),
              CircleAvatar(child: Text("GP")),
            ],
          ),
        ),
      ),
    );
  }
}
