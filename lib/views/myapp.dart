
import 'package:club_model/backend/admin/admin_provider.dart';
import 'package:club_model/club_model.dart';
import 'package:club_sub_admin/backend/authentication/authentication_provider.dart';
import 'package:club_sub_admin/backend/club_operator/club_operator_provider.dart';
import 'package:club_sub_admin/backend/common/menu_provider.dart';
import 'package:flutter/material.dart';

import '../backend/club_backend/club_provider.dart';
import '../backend/navigation/navigation_controller.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MyPrint.printOnConsole("MyApp Build Called");

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppThemeProvider>(
            create: (_) => AppThemeProvider(), lazy: false),
        ChangeNotifierProvider<AdminProvider>(
            create: (_) => AdminProvider(), lazy: false),
        ChangeNotifierProvider<MenuProvider>(
            create: (_) => MenuProvider(), lazy: false),
        ChangeNotifierProvider<ClubProvider>(
            create: (_) => ClubProvider(), lazy: false),
        ChangeNotifierProvider<AuthenticationProvider>(
            create: (_) => AuthenticationProvider(), lazy: false),
        ChangeNotifierProvider<ClubOperatorProvider>(
            create: (_) => ClubOperatorProvider(), lazy: false),
      ],
      child: MainApp(),
    );
  }
}

class MainApp extends StatelessWidget {
  MainApp({Key? key}) : super(key: key);
  final FirebaseAnalytics firebaseAnalytics = FirebaseAnalytics.instance;

  @override
  Widget build(BuildContext context) {
    MyPrint.printOnConsole("MainApp Build Called");

    return Consumer<AppThemeProvider>(
      builder: (BuildContext context, AppThemeProvider appThemeProvider,
          Widget? child) {
        //MyPrint.printOnConsole("ThemeMode:${appThemeProvider.themeMode}");

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: NavigationController.mainScreenNavigator,
          title: "SubAdmin",
          theme: appThemeProvider.getThemeData(),
          onGenerateRoute: NavigationController.onMainAppGeneratedRoutes,
          navigatorObservers: [
            FirebaseAnalyticsObserver(analytics: firebaseAnalytics),
          ],
        );
      },
    );
  }
}
