import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:local_app/Helper/appInputText.dart';
import 'package:local_app/Helper/buttons.dart';
import 'package:local_app/app/getx/ShoppingController.dart';
import 'package:local_app/modal/ShopingListModal.dart';

class Createshopinglist extends StatefulWidget {
  final MainShopListItem? updateItem;
  const Createshopinglist({super.key, this.updateItem});

  @override
  State<Createshopinglist> createState() => _CreateshopinglistState();
}

class _CreateshopinglistState extends State<Createshopinglist> {
  TextEditingController nameController = TextEditingController();
  TextEditingController infoController = TextEditingController();
  final ShoppingController shopingListController = Get.find();

  void createList() async {
    if (nameController.text.isEmpty || infoController.text.isEmpty) {
      return;
    }
    final MainShopListItem shoppingList = MainShopListItem(
      shopListName: nameController.text,
      description: infoController.text,
    );
    if (widget.updateItem != null) {
      return;
    }
    shopingListController.addNewShopList(
      shoppingList.shopListName!,
      shoppingList.description!,
    );
  }

  void updateShopingList() async {
    if (nameController.text.isEmpty || infoController.text.isEmpty) {
      return;
    }
    if (widget.updateItem == null) {
      return;
    }

    final MainShopListItem updatedShoppingList = MainShopListItem(
      shopListName: nameController.text,
      description: infoController.text,
    );

    shopingListController.updateShopList(updatedShoppingList);
  }

  @override
  void initState() {
    nameController.text = widget.updateItem?.shopListName ?? "";
    infoController.text = widget.updateItem?.description ?? "";
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    infoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Shopping List')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 22.0),
        children: [
          InputText(
            textInputType: TextInputType.text,
            textEditingController: nameController,
            password: false,
            hint: "Name",
            onChnaged: (text) {},
          ),
          InputText(
            textInputType: TextInputType.text,
            textEditingController: infoController,
            password: false,
            hint: "Information",
            onChnaged: (text) {},
          ),
          const SizedBox(height: 14),
          AppButton(
            function: () {
              if (widget.updateItem != null) {
                updateShopingList();
              } else {
                createList();
              }
            },
            child: Center(
              child: Text(
                widget.updateItem != null ? "Update" : "Create",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
