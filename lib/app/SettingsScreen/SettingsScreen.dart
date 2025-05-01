import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:local_app/DataBase/shop-list-database.dart';
import 'package:local_app/Helper/helper.dart';
import 'package:local_app/Networking/unti/AppConst.dart';
import 'package:local_app/app/Auth/LoginScreen/loginScreen.dart';
import 'package:local_app/app/SavedItemsList/SavedItemsList.dart';
import 'package:local_app/app/getx/SettingController.dart';
import 'package:local_app/app/getx/ShoppingController.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AppNetworkState { offline, api, superbase }

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingController settingController = GetInstance()
      .put<SettingController>(SettingController());

  final ShoppingController shopingListController = GetInstance()
      .put<ShoppingController>(ShoppingController());

  final SupabaseClient supabase = DatabaseService.supabase;

  GetStorage box = GetStorage();
  Future<void> logout() async {
    if (settingController.appNetworkState.value == AppNetworkState.superbase) {
      await supabase.auth.signOut();
    }
    box.remove(JWT_KEY);
    Get.offAll(LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: Expanded(
                child: SegmentedButton<AppNetworkState>(
                  segments: const <ButtonSegment<AppNetworkState>>[
                    ButtonSegment<AppNetworkState>(
                      value: AppNetworkState.offline,
                      label: Text('Offline'),
                      icon: Icon(Icons.calendar_view_day),
                    ),
                    ButtonSegment<AppNetworkState>(
                      value: AppNetworkState.api,
                      label: Text('API'),
                      icon: Icon(Icons.calendar_view_week),
                    ),
                    ButtonSegment<AppNetworkState>(
                      value: AppNetworkState.superbase,
                      label: Text('Supabase'),
                      icon: Icon(Icons.calendar_view_month),
                    ),
                  ],
                  selected: <AppNetworkState>{
                    settingController.appNetworkState.value,
                  },
                  onSelectionChanged: (Set<AppNetworkState> newSelection) {
                    settingController.saveOfflineMode(newSelection.first);
                  },
                ),
              ),
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
                settingController.appNetworkState.value ==
                        AppNetworkState.offline
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
                !(settingController.appNetworkState.value ==
                        AppNetworkState.offline)
                    ? Text("Access to your Coman Items")
                    : Text("Not available in offline mode"),
            trailing:
                settingController.appNetworkState.value ==
                        AppNetworkState.offline
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
