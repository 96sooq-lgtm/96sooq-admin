import 'package:_96sooq_admin/constants/colors.dart';
import 'package:_96sooq_admin/features/auth/login/view/login_view.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(DevicePreview(enabled: kDebugMode, builder: (context) => MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return
    // MultiBlocProvider(
    // providers: [],
    // child:
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '96 SOOQ ADMIN',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: AppColors.primaryColor),
        fontFamily: "Poppins",
      ),
      home: LoginView(),
      // ),
    );
  }
}
