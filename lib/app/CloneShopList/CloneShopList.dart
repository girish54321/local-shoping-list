import 'package:flutter/material.dart';
import 'package:local_app/Helper/DialogHelper.dart';
import 'package:local_app/Helper/cloneShopList.dart';
import 'package:local_app/modal/ShopingListModal.dart';
import 'package:local_app/modal/all_shop_list_items.dart';

class CloneShopList extends StatefulWidget {
  final MainShopListItem? shoppingListModel;
  final List<ShopListItems> allItems;

  const CloneShopList({
    super.key,
    this.shoppingListModel,
    required this.allItems,
  });

  @override
  State<CloneShopList> createState() => _CloneShopListState();
}

class _CloneShopListState extends State<CloneShopList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Clone Ropo")),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.shoppingListModel?.shopListName ?? "",
              style: TextStyle(fontSize: 19),
            ),
          ),
          ...widget.allItems.map((item) {
            return ShopListItemUI(item: item);
          }),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              final action = await Dialogs.yesAbortDialog(
                context,
                'Clone?',
                'Are you sure?',
              );
              if (action == DialogAction.yes) {
                Future.delayed(const Duration(seconds: 1), () {
                  CloneShoplistHelper().cloneShopListMain(
                    widget.shoppingListModel!,
                    widget.allItems,
                  );
                });
              }
            },
            child: Text("Clone"),
          ),
        ],
      ),
    );
  }
}

class ShopListItemUI extends StatelessWidget {
  final ShopListItems? item;
  const ShopListItemUI({super.key, this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(item?.itemName ?? "NA"),
      subtitle:
          item?.quantity != null
              ? Text(
                "Quantity: ${item?.quantity?.toString()} / Price: ${item?.price}",
              )
              : null,
      leading: Checkbox(value: false, onChanged: (bool? value) {}),
    );
  }
}
