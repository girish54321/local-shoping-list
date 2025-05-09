import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:local_app/DataBase/shop-list-database.dart';
import 'package:local_app/Networking/unti/AppConst.dart';
import 'package:local_app/app/Auth/LoginScreen/loginScreen.dart';
import 'package:local_app/app/SettingsScreen/SettingsScreen.dart';
import 'package:local_app/app/homeScreen/MainHomeScreen.dart';
import 'package:local_app/app/getx/SettingController.dart';
import 'package:local_app/app/getx/ShoppingController.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://tfymgnrlymhxollhewim.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRmeW1nbnJseW1oeG9sbGhld2ltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI0MDExNjEsImV4cCI6MjA1Nzk3NzE2MX0.kLdU99asa1g6IQrMbigKn9iWiQ6Fdz80pIXlz5zmAr8',
  );
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    GetInstance().put<SettingController>(SettingController());
    GetInstance().put<ShoppingController>(ShoppingController());
    final SupabaseClient supabaseClient = DatabaseService.supabase;
    // AppNetworkState appNetworkState = settingController.appNetworkState.value;
    GetStorage box = GetStorage();

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return GetMaterialApp(
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: darkDynamic,
            scaffoldBackgroundColor: Colors.black,
          ),
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: lightDynamic,
          ),
          title: 'Flutter Demo',
          getPages: [
            GetPage(
              name: '/',
              page: () {
                if (box.hasData(OFFLINE_MODE_KEY)) {
                  var offlineMode = box.read(OFFLINE_MODE_KEY);
                  if (offlineMode == AppNetworkState.offline.toString()) {
                    return box.hasData(JWT_KEY) || box.hasData(OFFLINE_MODE_KEY)
                        ? MainHomeScreen()
                        : LoginScreen();
                  } else if (offlineMode == AppNetworkState.api.toString()) {
                    return box.hasData(JWT_KEY) || box.hasData(OFFLINE_MODE_KEY)
                        ? MainHomeScreen()
                        : LoginScreen();
                  } else if (offlineMode ==
                      AppNetworkState.superbase.toString()) {
                    return StreamBuilder(
                      stream: supabaseClient.auth.onAuthStateChange,
                      builder: (context, snapshot) {
                        final authData = snapshot.data;
                        if (authData == null) {
                          return LoginScreen();
                        } else {
                          return MainHomeScreen();
                        }
                      },
                    );
                  }
                }
                return LoginScreen();
              },
            ),
          ],
        );
      },
    );
  }
}
