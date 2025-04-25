import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:local_app/Helper/appInputText.dart';
import 'package:local_app/Helper/buttons.dart';
import 'package:rules/rules.dart';

class SignUpScreenUI extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController firstNameController;
  final TextEditingController lastNameNameController;
  final GlobalKey<FormState> formKey;
  final Function signUpUser;
  final Function createAccount;
  final bool rememberMe;
  final Function(bool) changeRemember;

  const SignUpScreenUI({
    super.key,
    required this.emailController,
    required this.formKey,
    required this.signUpUser,
    required this.createAccount,
    required this.passwordController,
    required this.rememberMe,
    required this.changeRemember,
    required this.firstNameController,
    required this.lastNameNameController,
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
                        child: const Text("Sign Up"),
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
                                const Text("Sign Up"),
                                const SizedBox(height: 4),
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
                                  textInputType: TextInputType.name,
                                  textEditingController: firstNameController,
                                  hint: "First Name",
                                  validator: (text) {
                                    final firstNameRule = Rule(
                                      text,
                                      name: 'First Name',
                                      isRequired: true,
                                      minLength: 2,
                                    );
                                    if (firstNameRule.hasError) {
                                      return firstNameRule.error;
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                                InputText(
                                  textInputType: TextInputType.name,
                                  textEditingController: lastNameNameController,
                                  hint: "Last Name",
                                  validator: (text) {
                                    final lastNameRule = Rule(
                                      text,
                                      name: 'Last Name',
                                      isRequired: true,
                                      minLength: 2,
                                    );
                                    if (lastNameRule.hasError) {
                                      return lastNameRule.error;
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
                                    signUpUser();
                                  },
                                  child: const Center(
                                    child: Text(
                                      "Sign Up",
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
