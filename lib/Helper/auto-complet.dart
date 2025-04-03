import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_app/Helper/DialogHelper.dart';
import 'package:local_app/Networking/ShopListDataSource/ShopListDataSource.dart';
import 'package:local_app/Networking/unti/result.dart';
import 'package:local_app/app/getx/SettingController.dart';
import 'package:local_app/app/getx/ShopingListController.dart';
import 'package:local_app/modal/addCommonItems.dart';
import 'package:local_app/modal/common_items.dart';
import 'package:local_app/modal/operation_response.dart';

class AutoComplet extends StatefulWidget {
  final bool isOwner;
  final Function(CommonItemsItems) onItemTap;
  const AutoComplet({
    super.key,
    required this.isOwner,
    required this.onItemTap,
  });

  @override
  State<AutoComplet> createState() => _AutoCompletState();
}

class _AutoCompletState extends State<AutoComplet> {
  List<CommonItemsItems> items = [];
  ShopListDataSource apiResponse = ShopListDataSource();
  TextEditingController? itemName = TextEditingController();

  final SettingController settingController = Get.find();
  final ShopingListController shopingListController = Get.find();

  void getAllItems() {
    if (settingController.offlineMode.value) {
      return;
    }
    Future<Result> result = apiResponse.getCommonItems();
    result.then((value) {
      if (value is SuccessState) {
        var res = value.value as CommonItems;
        setState(() {
          items = res.items as List<CommonItemsItems>;
        });
      } else {}
    });
  }

  Future<void> confiemAdd(String text) async {
    if (text.isEmpty) {
      return;
    }
    CommonItemsItems newItem = CommonItemsItems(
      itemName: text,
      price: 1,
      description: text,
      quantity: 1,
    );

    itemName?.text = "";
    if (settingController.offlineMode.value) {
      itemName?.text = "";
      FocusScope.of(context).unfocus();
      widget.onItemTap(newItem);
      return;
    }

    final action = await Dialogs.yesAbortDialog(
      context,
      'Add $text?',
      'Are you sure?',
    );
    if (action == DialogAction.yes) {
      var item = AddCommonItems(
        itemName: text,
        description: text,
        quantity: "1",
        price: "1",
      );
      shopingListController.addNewSavedItem(item);
      Future.delayed(const Duration(seconds: 2), () {
        itemName?.text = "";
        FocusScope.of(context).unfocus();
        widget.onItemTap(newItem);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getAllItems();
  }

  @override
  void dispose() {
    super.dispose();
    itemName?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return ListTile(
        title: TextField(
          enabled: widget.isOwner,
          controller: itemName,
          onEditingComplete: () {},
          decoration: InputDecoration(
            suffixIcon: IconButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
              },
              icon: Icon(Icons.close),
            ),
            hintText: "Search item...",
            hintStyle: TextStyle(color: Colors.grey[400]),
          ),
          onSubmitted: (value) {
            confiemAdd(value);
          },
        ),
      );
    }
    return ListTile(
      title: Autocomplete<CommonItemsItems>(
        fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
          itemName = controller;
          return TextField(
            enabled: widget.isOwner,
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
              hintText: "Search item...",
              hintStyle: TextStyle(color: Colors.grey[400]),
            ),
            onSubmitted: (value) {
              confiemAdd(value);
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
                    final option = options.elementAt(index);
                    return ListTile(
                      title: Text(option.itemName ?? ""),
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
            return items;
          }
          return items.where(
            (item) => item.itemName!.toLowerCase().contains(
              textEditingValue.text.toLowerCase(),
            ),
          );
        },
        onSelected: (suggestion) {
          FocusScope.of(context).unfocus();
          itemName?.text = suggestion.itemName ?? "";
          itemName?.text = "";
          widget.onItemTap(suggestion);
        },
      ),
    );
  }
}
