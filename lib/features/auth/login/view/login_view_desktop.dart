import 'package:_96sooq_admin/constants/colors.dart';
import 'package:_96sooq_admin/constants/strings.dart';
import 'package:_96sooq_admin/constants/themes.dart';
import 'package:_96sooq_admin/features/auth/widgets/custom_textformfield.dart';
import 'package:_96sooq_admin/features/home/view/home_view.dart';
import 'package:_96sooq_admin/features/root/view/admin_root_view_.dart';
import 'package:_96sooq_admin/features/shared/global_widgets/custom_button_widgets.dart';
import 'package:flutter/material.dart';

class LoginViewDesktop extends StatefulWidget {
  const LoginViewDesktop({super.key});

  @override
  State<LoginViewDesktop> createState() => _LoginViewDesktopState();
}

class _LoginViewDesktopState extends State<LoginViewDesktop> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 150, vertical: 100),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  height: 722,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(60),
                      bottomLeft: Radius.circular(60),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      SizedBox(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 70),
                        child: Image.asset(AssetPath.logo),
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 50),
                            child: Align(
                              alignment: .centerLeft,
                              child: Text(
                                "96 Sooq Admin",
                                style: AppThemes.f28w500.copyWith(
                                  color: AppColors.whiteTextColor,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 50),
                            child: Align(
                              alignment: .centerLeft,
                              child: Text(
                                "Empowering your platform with powerful insights and seamless management tools.",
                                textAlign: .left,
                                maxLines: 3,
                                overflow: .ellipsis,
                                style: AppThemes.f16w300.copyWith(
                                  color: AppColors.whiteTextColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: Container(
                  height: 722,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(60),
                      bottomRight: Radius.circular(60),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 80,
                        vertical: 80,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Welcome", style: AppThemes.f36w600),
                          Text(
                            "Please enter your details to sign in.",
                            style: AppThemes.f18w400,
                          ),
                          const SizedBox(height: 50),
                          Text("Email Address", style: AppThemes.f20w500),
                          const SizedBox(height: 10),
                          CustomTextFormField(
                            controller: emailController,
                            labelText: "Email Address",
                          ),
                          const SizedBox(height: 20),
                          Text("Password", style: AppThemes.f20w500),
                          const SizedBox(height: 10),
                          CustomTextFormField(
                            controller: passwordController,
                            labelText: "Password",
                            obscureText: true,
                            isPassword: true,
                          ),
                          const SizedBox(height: 30),
                          CustomButton(
                            text: "Login",
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => AdminRootView(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
