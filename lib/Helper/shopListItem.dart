import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_app/Helper/helper.dart';
import 'package:local_app/app/AddShopingItem/AddShopingItemScreen.dart';
import 'package:local_app/app/SettingsScreen/SettingsScreen.dart';
import 'package:local_app/app/getx/SettingController.dart';
import 'package:local_app/app/getx/ShoppingController.dart';
import 'package:local_app/modal/ShopingListModal.dart';
import 'package:local_app/modal/all_shop_list_items.dart';

class ShopListItemListTitle extends StatelessWidget {
  final MainShopListItem? shopListItem;
  final bool isCompleted;
  const ShopListItemListTitle({
    super.key,
    this.shopListItem,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final ShoppingController shopingListController = Get.find();
    final SettingController settingController = Get.find();

    return ListTile(
      leading: Icon(
        Icons.checklist_rounded,
        color:
            shopListItem?.todo_state == "completed"
                ? Colors.green
                : Colors.orange,
      ),
      trailing:
          shopListItem?.state == "not-completed"
              ? Icon(Icons.check_outlined, color: Colors.green)
              : null,
      onTap: () {
        if (settingController.appNetworkState.value ==
            AppNetworkState.offline) {
          shopingListController.selecteShopListID(shopListItem?.id, null, null);
        }
        if (settingController.appNetworkState.value ==
            AppNetworkState.superbase) {
          shopingListController.selecteShopListID(
            shopListItem?.id,
            null,
            shopListItem?.superBaseId,
          );
          print("superBaseId: ${shopListItem?.superBaseId}");
        }
        if (settingController.appNetworkState.value == AppNetworkState.api) {
          shopingListController.selecteShopListID(
            null,
            shopListItem?.shopListId ?? "",
            null,
          );
        }
        Helper().goToPage(
          context: context,
          child: AddShopingItem(shoppingListModel: shopListItem),
        );
      },
      title: Text(shopListItem?.shopListName ?? ""),
      subtitle: Text(shopListItem?.description ?? ""),
    );
  }
}

class AddShopingItemUI extends StatefulWidget {
  final ShopListItems? item;
  final bool isChecked;
  final bool isOwner;
  final Widget? trailing;
  final Function(bool?) onChanged;
  const AddShopingItemUI({
    super.key,
    this.item,
    required this.isChecked,
    required this.isOwner,
    this.trailing,
    required this.onChanged,
  });

  @override
  State<AddShopingItemUI> createState() => _AddShopingItemUIState();
}

class _AddShopingItemUIState extends State<AddShopingItemUI> {
  final ShoppingController shopingListController = Get.find();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.item?.itemName ?? "NA"),
      subtitle:
          widget.item?.quantity != null
              ? Text(
                "Quantity: ${widget.item?.quantity?.toString()} / Price: ${widget.item?.price}",
              )
              : null,
      trailing: widget.isOwner ? widget.trailing : null,
      leading: Checkbox(
        value: widget.isChecked,
        onChanged:
            widget.isOwner
                ? (val) {
                  // setState(() {});
                  widget.onChanged(val);
                  shopingListController.updateItemState(widget.item, val);
                }
                : null,
      ),
    );
  }
}
