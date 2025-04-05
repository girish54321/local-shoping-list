import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_app/Helper/DialogHelper.dart';
import 'package:local_app/Helper/helper.dart';
import 'package:local_app/Networking/ShopListDataSource/ShopListDataSource.dart';
import 'package:local_app/Networking/unti/result.dart';
import 'package:local_app/app/getx/ShopingListController.dart';
import 'package:local_app/modal/addCommonItems.dart';
import 'package:local_app/modal/common_items.dart';
import 'package:local_app/modal/operation_response.dart';
import 'package:rules/rules.dart';

class SaveItemInputs extends StatefulWidget {
  final CommonItemsItems? item;
  final bool? isCreateNewItem;
  final Function? reloadList;
  const SaveItemInputs({
    super.key,
    this.item,
    this.isCreateNewItem,
    this.reloadList,
  });

  @override
  State<SaveItemInputs> createState() => _SaveItemInputsState();
}

class _SaveItemInputsState extends State<SaveItemInputs> {
  CommonItemsItems? inputState;
  final _formKey = GlobalKey<FormState>();

  final ShopingListController shopingListController = Get.find();

  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController quantityTextEditingController = TextEditingController();
  TextEditingController priceTextEditingController = TextEditingController();
  ShopListDataSource apiResponse = ShopListDataSource();

  @override
  void initState() {
    super.initState();
    autoFill();
  }

  void autoFill() {
    if (widget.item != null) {
      nameTextEditingController.text = widget.item?.itemName ?? "";
      quantityTextEditingController.text =
          widget.item?.quantity?.toString() ?? "";
      priceTextEditingController.text = widget.item?.price?.toString() ?? "";
    }
    setState(() {
      inputState = widget.item;
    });
  }

  Future<void> deleteItem() async {
    final action = await Dialogs.yesAbortDialog(
      context,
      'Delete selected Item?',
      'Are you sure?',
    );
    if (action == DialogAction.abort) {
      return;
    }

    var result = await apiResponse.deleteCommonItems({
      "itemId": widget.item?.commonItemsId ?? "",
    });
    if (result.status == LoadingStatus.success) {
      if (result.data?.success == true) {
        if (widget.reloadList != null) {
          widget.reloadList!();
        }
        DialogHelper.showErrorDialog(
          isError: false,
          description: "Common items deleted successfully",
        );
      }
    }
  }

  Future<void> updateItems() async {
    if (_formKey.currentState!.validate()) {
      if (widget.isCreateNewItem != null && widget.isCreateNewItem! == true) {
        var item = AddCommonItems(
          itemName: nameTextEditingController.text,
          description: nameTextEditingController.text,
          quantity: quantityTextEditingController.text,
          price: priceTextEditingController.text,
        );
        shopingListController.addNewSavedItem(item);
        if (widget.reloadList != null) {
          widget.reloadList!();
        }
        Helper().goBack();
        return;
      }

      var result = await apiResponse.updateCommonItems({
        "itemId": widget.item?.commonItemsId ?? "",
        "itemName": nameTextEditingController.text,
        "description": nameTextEditingController.text,
        "quantity": quantityTextEditingController.text,
        "price": priceTextEditingController.text,
      });
      if (result.status == LoadingStatus.success) {
        if (result.data?.success == true) {
          if (widget.reloadList != null) {
            widget.reloadList!();
          }
          DialogHelper.showErrorDialog(
            isError: false,
            description: "Common items updated successfully",
          );
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    nameTextEditingController.dispose();
    quantityTextEditingController.dispose();
    priceTextEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 8.0,
                left: 8.0,
                right: 8.0,
                bottom: 14.0,
              ),
              child: TextFormField(
                controller: nameTextEditingController,
                validator: (text) {
                  final rule = Rule(
                    text,
                    name: 'Item Name',
                    isRequired: true,
                    minLength: 2,
                  );
                  if (rule.hasError) {
                    return rule.error;
                  } else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderSide: BorderSide()),
                  hintText: 'Item Name',
                  labelText: 'Item Name',
                  prefixIcon: const Icon(Icons.dining_outlined),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 8.0,
                right: 8.0,
                bottom: 14.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: quantityTextEditingController,
                      keyboardType: TextInputType.number,
                      validator: (text) {
                        final rule = Rule(
                          text,
                          name: 'Quantity',
                          isRequired: true,
                          greaterThan: 1,
                        );
                        if (rule.hasError) {
                          return rule.error;
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderSide: BorderSide()),
                        hintText: 'Quantity',
                        labelText: 'Quantity',
                        prefixIcon: const Icon(Icons.numbers),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: priceTextEditingController,
                      validator: (text) {
                        final rule = Rule(
                          text,
                          name: 'Price',
                          isRequired: true,
                          greaterThan: 1,
                        );
                        if (rule.hasError) {
                          return rule.error;
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderSide: BorderSide()),
                        hintText: 'Price',
                        labelText: 'Price',
                        prefixIcon: const Icon(Icons.request_page),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 8.0,
                right: 8.0,
                bottom: 14.0,
              ),
              child: Row(
                children: [
                  Expanded(child: SizedBox()),
                  widget.isCreateNewItem == null
                      ? Expanded(
                        child: ElevatedButton(
                          onPressed: deleteItem,
                          child: Text("Delete"),
                        ),
                      )
                      : SizedBox(),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: updateItems,
                      child: Text(
                        widget.isCreateNewItem == null ? "Update" : "Create",
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Text('Price: ${inputState?.price?.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}
