import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_app/DataBase/shop-list-database.dart';
import 'package:local_app/Helper/DialogHelper.dart';
import 'package:local_app/Helper/PullToLoadList.dart';
import 'package:local_app/Networking/ShopListDataSource/ShopListDataSource.dart';
import 'package:local_app/Networking/modal/error_modal.dart';
import 'package:local_app/Networking/unti/result.dart';
import 'package:local_app/app/SettingsScreen/SettingsScreen.dart';
import 'package:local_app/app/getx/SettingController.dart';
import 'package:local_app/app/getx/ShoppingController.dart';
import 'package:local_app/modal/user_email_list_response.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SelectedUser {
  String? id;
  String? email;

  SelectedUser({this.id, this.email});
}

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

  final SettingController settingController = Get.find();
  final supabase = SupabaseClient(
    'https://tfymgnrlymhxollhewim.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRmeW1nbnJseW1oeG9sbGhld2ltIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0MjQwMTE2MSwiZXhwIjoyMDU3OTc3MTYxfQ.YWNnIxz9UDN7NpUfHbGIyDxknBdP7C6-VvhxsZ65Co0',
  );

  SelectedUser? selectedUser;

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
    AppNetworkState appNetworkState = settingController.appNetworkState.value;
    if (appNetworkState == AppNetworkState.offline ||
        appNetworkState == AppNetworkState.superbase) {
      try {
        final List<User> users = await supabase.auth.admin.listUsers();
        setState(() {
          this.users = LoadingState.success(
            users
                .map(
                  (e) => UserEmailListResponseUsers(
                    email: e.userMetadata?['email'],
                    userId: e.id,
                  ),
                )
                .toList(),
          );
        });
      } catch (e) {}

      return;
    }
    var result = await apiResponse.getUserEmailList({"search": text});
    if (result.status == LoadingStatus.success) {
      setState(() {
        users = LoadingState.success(result.data?.users);
      });
    }
  }

  void updateShareList() {
    if (settingController.appNetworkState.value != AppNetworkState.superbase) {
      return;
    }
    supabase.from('user-shop-lists').stream(primaryKey: ['id']).listen((
      List<Map<String, dynamic>> data,
    ) {
      shopingListController.getSharedUserList();
    });
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
    getSharedUserList();
  }

  @override
  void initState() {
    startReload();
    super.initState();
  }

  void getSharedUserList() {
    if (settingController.appNetworkState.value != AppNetworkState.superbase) {
      return;
    }
    supabase.from('user-shop-lists').stream(primaryKey: ['id']).listen((
      List<Map<String, dynamic>> data,
    ) {
      shopingListController.getSharedUserList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var list = shopingListController.sharedUserList.value;
      var isOwner = true;
      // var isOwner = shopingListController.isOwner.value;

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
                              userNameText?.text = "";
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
                    onSelected: (suggestion) async {
                      var item =
                          users.data
                              ?.where((i) => i?.email == suggestion)
                              .toList();
                      var id = item?[0]?.userId;
                      final SupabaseClient localSupabase =
                          DatabaseService.supabase;
                      final User? user = localSupabase.auth.currentUser;
                      if (user?.id == id) {
                        DialogHelper.showErrorDialog(
                          error: ErrorModalError(
                            message: 'You can\'t share with yourself',
                          ),
                          description: "You can't share with yourself",
                        );
                        return;
                      }
                      setState(() {
                        selectedUser = SelectedUser(
                          id: id,
                          email: item?[0]?.email,
                        );
                      });
                      shareWithUser();
                    },
                  ),
                );
              }
              var item = list[index - 1]!;
              return ListTile(
                leading: Icon(Icons.people_outline),
                title: Text(item.user?.firstName ?? item.email ?? ""),
                subtitle: Text(item.user?.email ?? ""),
              );
            },
          ),
        ),
      );
    });
  }
}
