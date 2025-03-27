import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:local_app/DataBase/shop-list-database.dart';
import 'package:local_app/Helper/appInputText.dart';
import 'package:local_app/Helper/buttons.dart';
import 'package:local_app/app/getx/ShopingListController.dart';
import 'package:local_app/modal/all_shop_list_items.dart';

class AddItemsScreen extends StatefulWidget {
  final ShopListItems? shopListItem;
  const AddItemsScreen({super.key, this.shopListItem});

  @override
  State<AddItemsScreen> createState() => _AddItemsScreenState();
}

class _AddItemsScreenState extends State<AddItemsScreen> {
  TextEditingController? itemName = TextEditingController();
  TextEditingController? quantity = TextEditingController();
  TextEditingController? price = TextEditingController();
  final ShopingListController shopingListController = Get.find();

  final DatabaseService _databaseService = DatabaseService.databaseService;

  void updateItems() {
    shopingListController.getShopingListItemCompleted();
    shopingListController.getShopingListItemInProgress();
  }

  void updateItem() {
    var updateItem = ShopListItems(
      id: widget.shopListItem?.id ?? 0,
      itemName: itemName?.text ?? widget.shopListItem?.itemName,
      quantity: int.parse(
        quantity?.text ?? widget.shopListItem?.quantity.toString() ?? "0",
      ),
      price: int.parse(
        price?.text ?? widget.shopListItem?.price.toString() ?? "0",
      ),
      state: widget.shopListItem?.state,
    );
    shopingListController.updateShopListItem(updateItem);
  }

  void _addShopingItem() {
    var item = ShopListItems(
      id: 1,
      itemName: itemName?.text,
      quantity: int.parse(quantity?.text ?? "0"),
      price: int.parse(price?.text ?? "0"),
      state: widget.shopListItem?.state,
    );
    _databaseService.addItemToShopingList(item);
    updateItems();
    setState(() {});
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    itemName?.text = widget.shopListItem?.itemName ?? "";
    quantity?.text = widget.shopListItem?.quantity?.toString() ?? "";
    price?.text = widget.shopListItem?.price?.toString() ?? "";
    super.initState();
  }

  @override
  void dispose() {
    itemName?.dispose();
    quantity?.dispose();
    price?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppBar(
                      title: FadeInRight(
                        duration: const Duration(milliseconds: 500),
                        child: Text("Add Items"),
                      ),
                    ),
                    Column(
                      children: [
                        FadeInRight(
                          duration: const Duration(milliseconds: 500),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InputText(
                                  textInputType: TextInputType.name,
                                  textEditingController: itemName,
                                  password: false,
                                  hint: "Item Name",
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: 140,
                                      child: InputText(
                                        textInputType: TextInputType.number,
                                        textEditingController: quantity,
                                        password: false,
                                        hint: "Quantity",
                                      ),
                                    ),
                                    SizedBox(
                                      width: 140,
                                      child: InputText(
                                        textInputType: TextInputType.number,
                                        textEditingController: price,
                                        password: false,
                                        hint: "Price",
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 22),
                                AppButton(
                                  function: () {
                                    if (widget.shopListItem != null) {
                                      updateItem();
                                      return;
                                    }
                                    _addShopingItem();
                                  },
                                  child: Center(
                                    child: Text(
                                      widget.shopListItem != null
                                          ? "Update Item"
                                          : "Add Item",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
