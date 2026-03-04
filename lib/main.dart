import 'package:_96sooq_admin/constants/colors.dart';
import 'package:_96sooq_admin/core/bloc/language/bloc/language_bloc.dart';
import 'package:_96sooq_admin/core/bloc/language/bloc/language_event.dart';
import 'package:_96sooq_admin/core/bloc/language/bloc/language_state.dart';
import 'package:_96sooq_admin/features/auth/bloc/auth_bloc.dart';
import 'package:_96sooq_admin/features/auth/bloc/auth_event.dart';
import 'package:_96sooq_admin/features/ad_bannner/bloc/ad_banner_bloc.dart';
import 'package:_96sooq_admin/features/ad_bannner/services/ad_banner_service.dart';
import 'package:_96sooq_admin/features/category/bloc/category_bloc.dart';
import 'package:_96sooq_admin/features/category/services/category_service.dart';
import 'package:_96sooq_admin/core/bloc/s3_upload/s3_upload_bloc.dart';
import 'package:_96sooq_admin/core/bloc/s3_upload/s3_upload_service.dart';
import 'package:_96sooq_admin/features/promotion/bloc/subscription_bloc.dart';
import 'package:_96sooq_admin/features/promotion/services/subscription_service.dart';
import 'package:_96sooq_admin/features/subcategory/bloc/subcategory_bloc.dart';
import 'package:_96sooq_admin/features/subcategory/services/subcategory_service.dart';
import 'package:_96sooq_admin/features/stores/bloc/store_bloc.dart';
import 'package:_96sooq_admin/features/stores/services/store_service.dart';
import 'package:_96sooq_admin/features/home/bloc/dashboard_bloc.dart';
import 'package:_96sooq_admin/features/home/services/dashboard_service.dart';
import 'package:_96sooq_admin/features/request_approval/bloc/listing_bloc.dart';
import 'package:_96sooq_admin/features/request_approval/services/listing_service.dart';
import 'package:_96sooq_admin/features/user_management/bloc/user_bloc.dart';
import 'package:_96sooq_admin/features/user_management/bloc/user_event.dart';
import 'package:_96sooq_admin/features/user_management/services/user_service.dart';
import 'package:_96sooq_admin/features/payments/bloc/payment_bloc.dart';
import 'package:_96sooq_admin/features/payments/bloc/payment_event.dart';
import 'package:_96sooq_admin/features/payments/services/payment_service.dart';
import 'package:_96sooq_admin/features/root/cubit/admin_navigation_cubit.dart';
import 'package:_96sooq_admin/features/shared/dio_setup/dio_services.dart';
import 'package:_96sooq_admin/features/shared/router/app_router.dart';
import 'package:_96sooq_admin/core/utils/image_picker_platform_stub.dart'
    if (dart.library.html) 'package:_96sooq_admin/core/utils/image_picker_platform_web.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setImagePickerPlatform();

  /// AUTH
  final authBloc = AuthBloc()..add(AppStarted());

  /// LANGUAGE
  final translationBloc = TranslationBloc()..add(LoadSavedLanguage());

  /// NAVIGATION
  final navigationCubit = AdminNavigationCubit();

  /// DIO (shared instance)
  final dio = BaseDio().dio;
  BaseDio.setAuthBloc(authBloc);

  /// CATEGORY
  final categoryRepository = CategoryServices(dio);
  final categoryBloc = CategoryBloc(categoryRepository);
  final s3UploadService = S3UploadService(dio);
  final s3UploadBloc = S3UploadBloc(s3UploadService);
  final subscriptionService = SubscriptionService(dio);
  final subscriptionBloc = SubscriptionBloc(subscriptionService);
  final subcategoryService = SubcategoryService(dio);
  final subcategoryBloc = SubcategoryBloc(subcategoryService);
  final adBannerService = AdBannerService(dio);
  final adBannerBloc = AdBannerBloc(adBannerService);
  final storeService = StoreService(dio);
  final storeBloc = StoreBloc(storeService);
  final dashboardService = DashboardService(dio);
  final dashboardBloc = DashboardBloc(dashboardService);
  final listingService = ListingService(dio);
  final listingBloc = ListingBloc(listingService)
    ..add(const LoadListings(status: 'pending_approval'));
  final userService = UserService(dio);
  final userBloc = UserBloc(userService)..add(const LoadUsers());
  final paymentService = PaymentService(dio);
  final paymentBloc = PaymentBloc(paymentService)
    ..add(const LoadTransactions());

  runApp(
    DevicePreview(
      enabled: kDebugMode,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: authBloc),
          BlocProvider.value(value: translationBloc),
          BlocProvider.value(value: navigationCubit),
          BlocProvider.value(value: categoryBloc),
          BlocProvider.value(value: s3UploadBloc),
          BlocProvider.value(value: subscriptionBloc),
          BlocProvider.value(value: subcategoryBloc),
          BlocProvider.value(value: adBannerBloc),
          BlocProvider.value(value: storeBloc),
          BlocProvider.value(value: dashboardBloc),
          BlocProvider.value(value: listingBloc),
          BlocProvider.value(value: userBloc),
          BlocProvider.value(value: paymentBloc),
        ],
        child: MyApp(authBloc: authBloc),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthBloc authBloc;
  const MyApp({super.key, required this.authBloc});

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
            snackBarTheme: SnackBarThemeData(
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.primaryColor,
              contentTextStyle: const TextStyle(color: Colors.white),
            ),
          ),
          routerConfig: createRouter(authBloc),
        );
      },
    );
  }
}
