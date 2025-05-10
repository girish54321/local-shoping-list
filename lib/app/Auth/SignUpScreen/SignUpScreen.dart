import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:local_app/Helper/helper.dart';
import 'package:local_app/Networking/AuthDataSource/AuthDataSource.dart';
import 'package:local_app/Networking/unti/result.dart';
import 'package:local_app/app/Auth/LoginScreen/loginScreen.dart';
import 'package:local_app/app/Auth/SignUpScreen/SignUpScreenUI.dart';
import 'package:local_app/app/SettingsScreen/SettingsScreen.dart';
import 'package:local_app/app/getx/SettingController.dart';
import 'package:local_app/app/homeScreen/MainHomeScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpScreen extends StatefulWidget {
  SignUpScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameNameController = TextEditingController();
  final SettingController settingController = Get.find();

  final supabase = Supabase.instance.client;

  bool validEmail = false, validPassword = false, rememberMe = true;

  void goBack(context) {
    Helper().goBack();
  }

  void changeVaildEmail(bool value) {
    setState(() {
      validEmail = value;
    });
  }

  void changevalidPassword(bool value) {
    setState(() {
      validPassword = value;
    });
  }

  void changeRemember(bool value) {
    setState(() {
      rememberMe = value;
    });
  }

  Future<void> signUpUser() async {
    GetStorage box = GetStorage();
    if (_formKey.currentState!.validate()) {
      Helper().dismissKeyBoard(context);
      Helper().showLoading();

      AuthDataSource apiResponse = AuthDataSource();
      var parameter = {
        "email": emailController.text,
        "password": passwordController.text,
        "firstName": firstNameController.text,
        "lastName": lastNameNameController.text,
      };

      if (settingController.appNetworkState.value ==
          AppNetworkState.superbase) {
        final AuthResponse res = await supabase.auth.signUp(
          email: emailController.text,
          password: passwordController.text,
        );
        Get.off(LoginScreen());
        return;
      }

      var result = await apiResponse.signUpUser(parameter);
      if (result.status == LoadingStatus.success) {
        box.write('token', result.data?.accessToken);
        Get.off(MainHomeScreen());
      }
    } else {
      // Helper().vibratPhone();
    }
  }

  void createAccount() {
    Helper().dismissKeyBoard(context);
    // Helper().goToPage(context: context, child: SignUpScreen());
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    lastNameNameController.dispose();
    firstNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SignUpScreenUI(
      emailController: emailController,
      lastNameNameController: lastNameNameController,
      firstNameController: firstNameController,
      passwordController: passwordController,
      changeRemember: changeRemember,
      rememberMe: rememberMe,
      formKey: _formKey,
      createAccount: createAccount,
      signUpUser: signUpUser,
    );
  }
}
