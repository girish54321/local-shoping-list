import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_app/Helper/DialogHelper.dart';
import 'package:local_app/Helper/PullToLoadList.dart';
import 'package:local_app/Networking/ShopListDataSource/ShopListDataSource.dart';
import 'package:local_app/Networking/unti/result.dart';
import 'package:local_app/app/getx/ShoppingController.dart';
import 'package:local_app/modal/user_email_list_response.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';

class ShareUserListScreen extends StatefulWidget {
  const ShareUserListScreen({super.key});

  @override
  State<ShareUserListScreen> createState() => _ShareUserListScreenState();
}

class _ShareUserListScreenState extends State<ShareUserListScreen> {
  final ShoppingController shopingListController = Get.find();

  //* Reload  List
  RefreshController refreshController = RefreshController(
    initialRefresh: false,
  );
  ShopListDataSource apiResponse = ShopListDataSource();
  TextEditingController? userNameText = TextEditingController();
  LoadingState<List<UserEmailListResponseUsers?>?> users =
      LoadingState<List<UserEmailListResponseUsers?>?>.loading();

  String? selectedUser;

  Future<void> shareWithUser() async {
    final action = await Dialogs.yesAbortDialog(
      context,
      'Add Selected User?',
      'Are you sure?',
    );
    if (action == DialogAction.yes) {
      shopingListController.shareShopList(selectedUser);
    }
  }

  Future<void> getUserList(String text) async {
    setState(() {
      users = LoadingState.loading();
    });
    var result = await apiResponse.getUserEmailList({"search": text});
    if (result.status == LoadingStatus.success) {
      setState(() {
        users = LoadingState.success(result.data?.users);
      });
    }
  }

  @override
  void dispose() {
    refreshController.dispose();
    userNameText?.dispose();
    super.dispose();
  }

  void startReload() {
    shopingListController.getSharedUserList();
    refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var list = shopingListController.sharedUserList.value;
      var isOwner = shopingListController.isOwner.value;

      var isLoading = list == LoadingStatus.loading;

      if (isLoading) {
        return Center(child: CircularProgressIndicator());
      }
      return Scaffold(
        appBar: AppBar(title: Text("Share user list")),
        body: PullToLoadList(
          refreshController: refreshController,
          onLoading: () => {},
          onRefresh: startReload,
          child: ListView.builder(
            itemCount: list.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return ListTile(
                  title: Autocomplete<String>(
                    fieldViewBuilder: (
                      context,
                      controller,
                      focusNode,
                      onEditingComplete,
                    ) {
                      userNameText = controller;
                      return TextField(
                        enabled: isOwner,
                        controller: userNameText,
                        focusNode: focusNode,
                        onChanged: (value) {
                          getUserList(value);
                        },
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
                          FocusScope.of(context).unfocus();
                          // getUserList(value);
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
                        return [];
                      }
                      final List<String> suggestions =
                          users.data
                              ?.whereType<UserEmailListResponseUsers>()
                              .map((user) => user.email)
                              .whereType<String>()
                              .toList() ??
                          [];

                      return suggestions;
                    },
                    onSelected: (suggestion) {
                      var item =
                          users.data
                              ?.where((i) => i?.email == suggestion)
                              .toList();
                      var id = item?[0]?.userId;
                      setState(() {
                        selectedUser = id;
                      });
                      shareWithUser();
                    },
                  ),
                );
              }
              var item = list[index - 1]!;
              return ListTile(
                title: Text(item.user?.firstName ?? ""),
                subtitle: Text(item.user?.email ?? ""),
              );
            },
          ),
        ),
      );
    });
  }
}
