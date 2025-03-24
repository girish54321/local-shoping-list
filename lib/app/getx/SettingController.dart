import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:local_app/Networking/unti/AppConst.dart';

class LocaleWidgetPair {
  Locale locale;
  Widget widget;

  LocaleWidgetPair(this.locale, this.widget);
}

class SettingController extends GetxController {
  RxBool isDark = false.obs;
  RxBool offlineMode = false.obs;
  GetStorage box = GetStorage();
  @override
  void onReady() {
    loadOfflineMode();
    loadThem();
    super.onReady();
  }

  void loadOfflineMode() {
    if (box.hasData(OFFLINE_MODE_KEY)) {
      if (box.read(OFFLINE_MODE_KEY)) {
        saveOfflineMode(true);
      } else {
        saveOfflineMode(false);
      }
    }
  }

  void saveOfflineMode(bool value) {
    offlineMode.value = value;
    box.write(OFFLINE_MODE_KEY, value);
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
      print("No Them car");
      isDark.value = false;
      saveThemSetting(false);
      Get.changeThemeMode(ThemeMode.light);
    }
  }

  void saveThemSetting(bool value) {
    print("Save the team");
    box.write("darkThem", value);
  }

  void toggleThem() {
    isDark.value = !isDark.value;
    if (isDark.value == true) {
      saveThemSetting(true);
      // Get.changeTheme(_darkTheme);
      Get.changeThemeMode(ThemeMode.dark);
    } else if (isDark.value == false) {
      saveThemSetting(false);
      // Get.changeTheme(_lightTheme);
      Get.changeThemeMode(ThemeMode.light);
    }
  }
}
