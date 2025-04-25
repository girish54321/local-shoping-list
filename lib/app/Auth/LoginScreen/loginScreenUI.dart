import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:local_app/Helper/appInputText.dart';
import 'package:local_app/Helper/buttons.dart';
import 'package:rules/rules.dart';

class LoginScreenUI extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final GlobalKey<FormState> formKey;
  final Function loginUser;
  final Function createAccount;
  final bool rememberMe;
  final Function(bool) changeRemember;

  const LoginScreenUI({
    super.key,
    required this.emailController,
    required this.formKey,
    required this.loginUser,
    required this.createAccount,
    required this.passwordController,
    required this.rememberMe,
    required this.changeRemember,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppBar(
                      title: FadeInRight(
                        duration: const Duration(milliseconds: 500),
                        child: const Text("Login"),
                      ),
                    ),
                    Column(
                      children: [
                        FadeInRight(
                          duration: const Duration(milliseconds: 500),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 46),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("LogIn"),
                                const SizedBox(height: 4),
                                const Text("Enter your Number"),
                                InputText(
                                  textInputType: TextInputType.emailAddress,
                                  textEditingController: emailController,
                                  hint: "Email",
                                  validator: (text) {
                                    final emailRule = Rule(
                                      text,
                                      name: 'Email',
                                      isRequired: true,
                                      isEmail: true,
                                    );
                                    if (emailRule.hasError) {
                                      return emailRule.error;
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                                InputText(
                                  textInputType: TextInputType.phone,
                                  textEditingController: passwordController,
                                  hint: "Password",
                                  validator: (text) {
                                    final passwordRule = Rule(
                                      text,
                                      name: 'Password',
                                      isRequired: true,
                                      minLength: 4,
                                    );
                                    if (passwordRule.hasError) {
                                      return passwordRule.error;
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                                AppButton(
                                  function: () {
                                    loginUser();
                                  },
                                  child: const Center(
                                    child: Text(
                                      "Log In",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Text(""),
                    const Text(""),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
