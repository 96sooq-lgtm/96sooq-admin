import 'package:_96sooq_admin/constants/colors.dart';
import 'package:_96sooq_admin/core/bloc/language/bloc/language_state.dart';
import 'package:_96sooq_admin/features/auth/bloc/auth_bloc.dart';
import 'package:_96sooq_admin/features/auth/bloc/auth_event.dart';
import 'package:_96sooq_admin/features/root/cubit/admin_navigation_cubit.dart';
import 'package:_96sooq_admin/features/shared/router/app_router.dart';
import 'package:_96sooq_admin/core/bloc/language/bloc/language_bloc.dart';
import 'package:_96sooq_admin/core/bloc/language/bloc/language_event.dart'; // Import events
import 'package:_96sooq_admin/core/bloc/navigation/navigation_cubit.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final navKey = GlobalKey<NavigatorState>();

// Changed main to async
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authBloc = AuthBloc()..add(AppStarted());

  // Initialize and load saved language immediately
  final translationBloc = TranslationBloc()..add(LoadSavedLanguage());
  final navigationCubit = AdminNavigationCubit();

  runApp(
    DevicePreview(
      enabled: kDebugMode,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: authBloc),
          BlocProvider.value(value: translationBloc),
          BlocProvider.value(value: navigationCubit),
        ],
        child: MyApp(authBloc: authBloc),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthBloc authBloc;
  const MyApp({required this.authBloc, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationBloc, TranslationState>(
      builder: (context, state) {
        return MaterialApp.router(
          key: ValueKey(state.languageCode),
          debugShowCheckedModeBanner: false,
          title: '96 SOOQ ADMIN',
          locale: Locale(state.languageCode),
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primaryColor,
            ),
            fontFamily: "Poppins",
          ),
          routerConfig: createRouter(authBloc),
        );
      },
    );
  }
}
