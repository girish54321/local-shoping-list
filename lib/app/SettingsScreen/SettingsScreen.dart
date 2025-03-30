import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:local_app/Helper/helper.dart';
import 'package:local_app/Networking/unti/AppConst.dart';
import 'package:local_app/app/Auth/LoginScreen/loginScreen.dart';
import 'package:local_app/app/SavedItemsList/SavedItemsList.dart';
import 'package:local_app/app/getx/SettingController.dart';
import 'package:local_app/app/getx/ShopingListController.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingController settingController = GetInstance()
      .put<SettingController>(SettingController());

  final ShopingListController shopingListController = GetInstance()
      .put<ShopingListController>(ShopingListController());
  GetStorage box = GetStorage();

  void logout() {
    box.remove(JWT_KEY);
    Get.offAll(LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        children: [
          ListTile(
            leading: Icon(Icons.network_locked),
            title: Text("Offline Mode"),
            subtitle: Text("Use app Offline only"),
            trailing: Obx(
              (() => Switch(
                value: settingController.offlineMode.value,
                onChanged: (bool val) {
                  settingController.saveOfflineMode(val);
                  shopingListController.loadEverything();
                },
              )),
            ),
          ),
          ListTile(
            leading: Icon(
              settingController.isDark.value
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            title: Text("Theme"),
            subtitle: Text("Change app theme"),
            trailing: Switch(
              value: settingController.isDark.value,
              onChanged: (bool _) => settingController.toggleThem(),
            ),
          ),
          ListTile(
            onTap:
                settingController.offlineMode.value == true
                    ? null
                    : () {
                      Helper().goToPage(
                        context: context,
                        child: SavedItemsList(),
                      );
                    },
            leading: Icon(Icons.checklist_outlined),
            title: Text("Saved Items"),
            subtitle:
                !settingController.offlineMode.value
                    ? Text("Access to your Coman Items")
                    : Text("Not available in offline mode"),
            trailing:
                settingController.offlineMode.value
                    ? Icon(Icons.no_accounts)
                    : Icon(Icons.check),
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text("Logout"),
            onTap: logout,
          ),
        ],
      );
    });
  }
}
