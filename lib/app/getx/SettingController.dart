import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:local_app/Networking/unti/AppConst.dart';
import 'package:local_app/app/SettingsScreen/SettingsScreen.dart';

class LocaleWidgetPair {
  Locale locale;
  Widget widget;

  LocaleWidgetPair(this.locale, this.widget);
}

class SettingController extends GetxController {
  RxBool isDark = false.obs;
  // RxBool offlineMode = false.obs;
  Rx<AppNetworkState> appNetworkState = AppNetworkState.offline.obs;

  GetStorage box = GetStorage();
  @override
  void onReady() {
    loadOfflineMode();
    loadThem();
    super.onReady();
  }

  void skipLogin() {
    saveOfflineMode(AppNetworkState.offline);
  }

  void loadOfflineMode() {
    if (box.hasData(OFFLINE_MODE_KEY)) {
      var offlineMode = box.read(OFFLINE_MODE_KEY);
      if (offlineMode == AppNetworkState.offline.toString()) {
        appNetworkState.value = AppNetworkState.offline;
        Get.changeThemeMode(ThemeMode.dark);
      } else if (offlineMode == AppNetworkState.api.toString()) {
        appNetworkState.value = AppNetworkState.api;
        Get.changeThemeMode(ThemeMode.light);
      } else if (offlineMode == AppNetworkState.superbase.toString()) {
        appNetworkState.value = AppNetworkState.superbase;
        Get.changeThemeMode(ThemeMode.light);
      }
    }
  }

  void saveOfflineMode(AppNetworkState value) {
    appNetworkState.value = value;
    box.write(OFFLINE_MODE_KEY, value.toString());
  }

  //* Local Settings
  void loadThem() {
    if (box.hasData('darkThem')) {
      var isSavedDark = box.read('darkThem');
      if (isSavedDark) {
        isDark.value = true;
        Get.changeThemeMode(ThemeMode.dark);
      } else {
        isDark.value = false;
        Get.changeThemeMode(ThemeMode.light);
      }
    } else {
      isDark.value = false;
      saveThemSetting(false);
      Get.changeThemeMode(ThemeMode.light);
    }
  }

  void saveThemSetting(bool value) {
    box.write("darkThem", value);
  }

  void toggleThem() {
    isDark.value = !isDark.value;
    if (isDark.value == true) {
      saveThemSetting(true);
      Get.changeThemeMode(ThemeMode.dark);
    } else if (isDark.value == false) {
      saveThemSetting(false);
      Get.changeThemeMode(ThemeMode.light);
    }
  }
}
