import 'package:club_model/backend/navigation/navigation_operation.dart';
import 'package:club_model/backend/navigation/navigation_operation_parameters.dart';
import 'package:club_model/utils/my_print.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../views/authentication/screens/login_screen.dart';
import '../../views/club_products/screens/club_products.dart';
import '../../views/homescreen/screens/homescreen.dart';
import '../../views/photo_gallery/screens/add_photo_gallery.dart';
import '../../views/photo_gallery/screens/photo_gallery_screeen.dart';
import '../../views/splash/splash_screen.dart';
import '../../views/system/screen/system_main_screen.dart';
import 'navigation_arguments.dart';

class NavigationController {
  static NavigationController? _instance;
  static String chatRoomId = "";
  static bool isNoInternetScreenShown = false;
  static bool isFirst = true;

  factory NavigationController() {
    _instance ??= NavigationController._();
    return _instance!;
  }

  NavigationController._();

  static final GlobalKey<NavigatorState> mainScreenNavigator =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> systemProfileNavigator =
  GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> photoGalleryScreenNavigator =
  GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> clubProductsScreenNavigator =
  GlobalKey<NavigatorState>();

  // static final GlobalKey<NavigatorState> brandScreenNavigator =
  //     GlobalKey<NavigatorState>();

  static bool isUserProfileTabInitialized = false;

  static bool checkDataAndNavigateToSplashScreen() {
    MyPrint.printOnConsole(
        "checkDataAndNavigateToSplashScreen called, isFirst:$isFirst");

    if (isFirst) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        isFirst = false;
        Navigator.pushNamedAndRemoveUntil(mainScreenNavigator.currentContext!,
            SplashScreen.routeName, (route) => false);
      });
    }

    return isFirst;
  }

  static Route? onMainAppGeneratedRoutes(RouteSettings settings) {
    MyPrint.printOnConsole(
        "onAdminMainGeneratedRoutes called for ${settings.name} with arguments:${settings.arguments}");

    // if(navigationCount == 2 && Uri.base.hasFragment && Uri.base.fragment != "/") {
    //   return null;
    // }

    if (kIsWeb) {
      if (!["/", SplashScreen.routeName].contains(settings.name) &&
          NavigationController.checkDataAndNavigateToSplashScreen()) {
        return null;
      }
    }
    /*if(!["/", SplashScreen.routeName].contains(settings.name)) {
      if(NavigationController.checkDataAndNavigateToSplashScreen()) {
        return null;
      }
    }
    else {
      if(!kIsWeb) {
        if(isFirst) {
          isFirst = false;
        }
      }
    }*/

    MyPrint.printOnConsole("First Page:$isFirst");
    Widget? page;

    switch (settings.name) {
      case "/":
        {
          page = const SplashScreen();
          break;
        }
      case SplashScreen.routeName:
        {
          page = const SplashScreen();
          break;
        }
      case LoginScreen.routeName:
        {
          page = parseLoginScreen(settings: settings);
          break;
        }
      case HomeScreen.routeName:
        {
          page = parseHomeScreen(settings: settings);
          break;
        }
    }

    if (page != null) {
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => page!,
        //transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
        transitionsBuilder: (c, anim, a2, child) =>
            SizeTransition(sizeFactor: anim, child: child),
        transitionDuration: const Duration(milliseconds: 0),
        settings: settings,
      );
    }
    return null;
  }

  static Route? onSystemProfileGeneratedRoutes(RouteSettings settings) {
    MyPrint.printOnConsole(
        "User Generated Routes called for ${settings.name} with arguments:${settings.arguments}");

    if (kIsWeb) {
      if (!["/", SplashScreen.routeName].contains(settings.name) &&
          NavigationController.checkDataAndNavigateToSplashScreen()) {
        return null;
      }
    }

    MyPrint.printOnConsole("First Page:$isFirst");
    Widget? page;

    switch (settings.name) {
      case "/":
        {
          page = const SystemMainScreen();
          break;
        }

      case LoginScreen.routeName:
        {
          page = parseLoginScreen(settings: settings);
          break;
        }
    }



    if (page != null) {
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => page!,
        //transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
        transitionsBuilder: (c, anim, a2, child) =>
            SizeTransition(sizeFactor: anim, child: child),
        transitionDuration: const Duration(milliseconds: 0),
        settings: settings,
      );
    }
    return null;
  }

  static Route? onPhotoGalleryGeneratedRoutes(RouteSettings settings) {
    MyPrint.printOnConsole("photo Gallery Generated Routes called for ${settings.name} with arguments:${settings.arguments}");

    if (kIsWeb) {
      if (!["/", SplashScreen.routeName].contains(settings.name) && NavigationController.checkDataAndNavigateToSplashScreen()) {
        return null;
      }
    }

    MyPrint.printOnConsole("First Page:$isFirst");
    Widget? page;

    switch (settings.name) {
      case "/":
        {
          page = const PhotoGalleryScreen();
          break;
        }

      case AddPhotoGalleryScreen.routeName:
        {
          page = parseAddPhotoGalleryScreen(settings: settings);
          break;
        }
    }

    if (page != null) {
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => page!,
        //transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
        transitionsBuilder: (c, anim, a2, child) => SizeTransition(sizeFactor: anim, child: child),
        transitionDuration: const Duration(milliseconds: 0),
        settings: settings,
      );
    }
    return null;
  }

  static Route? onClubProductsRoutes(RouteSettings settings) {
    MyPrint.printOnConsole("photo Gallery Generated Routes called for ${settings.name} with arguments:${settings.arguments}");

    if (kIsWeb) {
      if (!["/", SplashScreen.routeName].contains(settings.name) && NavigationController.checkDataAndNavigateToSplashScreen()) {
        return null;
      }
    }

    MyPrint.printOnConsole("First Page:$isFirst");
    Widget? page;

    switch (settings.name) {
      case "/":
        {
          page = const ClubProductsListScreen();
          break;
        }

      // case AddPhotoGalleryScreen.routeName:
      //   {
      //     page = parseAddPhotoGalleryScreen(settings: settings);
      //     break;
      //   }
    }

    if (page != null) {
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => page!,
        //transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
        transitionsBuilder: (c, anim, a2, child) => SizeTransition(sizeFactor: anim, child: child),
        transitionDuration: const Duration(milliseconds: 0),
        settings: settings,
      );
    }
    return null;
  }



/*
  static Route? onBrandGeneratedRoutes(RouteSettings settings) {
    MyPrint.printOnConsole(
        "Brand Routes called for ${settings.name} with arguments:${settings.arguments}");

    if (kIsWeb) {
      if (!["/", SplashScreen.routeName].contains(settings.name) &&
          NavigationController.checkDataAndNavigateToSplashScreen()) {
        return null;
      }
    }

    MyPrint.printOnConsole("First Page:$isFirst");
    Widget? page;

    switch (settings.name) {
      case "/":
        {
          page = const BrandListScreen();
          break;
        }

      case AddBrand.routeName:
        {
          page = parseAddBrandScreen(settings: settings);
          break;
        }
    }

    if (page != null) {
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => page!,
        //transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
        transitionsBuilder: (c, anim, a2, child) =>
            SizeTransition(sizeFactor: anim, child: child),
        transitionDuration: const Duration(milliseconds: 0),
        settings: settings,
      );
    }
    return null;
  }

*/

  //region Parse Page From RouteSettings
  static Widget? parseLoginScreen({required RouteSettings settings}) {
    return const LoginScreen();
  }

  static Widget? parseHomeScreen({required RouteSettings settings}) {
    return HomeScreen();
  }

  static Widget? parseAddPhotoGalleryScreen({required RouteSettings settings}) {
    if (settings.arguments is AddPhotoGalleryNavigationArguments) {
      AddPhotoGalleryNavigationArguments arguments = settings.arguments as AddPhotoGalleryNavigationArguments;
      return AddPhotoGalleryScreen(
        arguments: arguments,
      );
    } else {
      return null;
    }
  }


/*  static Widget? parseAddBannerScreen({required RouteSettings settings}) {
    if (settings.arguments is AddBannerScreenNavigationArguments) {
      AddBannerScreenNavigationArguments arguments =
      settings.arguments as AddBannerScreenNavigationArguments;
      return AddBannerScreen(
        arguments: arguments,
      );
    } else {
      return null;
    }
  }
  */

  //endregion

  static Future<dynamic> navigateToLoginScreen(
      {required NavigationOperationParameters navigationOperationParameters}) {
    return NavigationOperation.navigate(
        navigationOperationParameters: navigationOperationParameters.copyWith(
      routeName: LoginScreen.routeName,
    ));
  }

  static Future<dynamic> navigateToHomeScreen(
      {required NavigationOperationParameters navigationOperationParameters}) {
    return NavigationOperation.navigate(
        navigationOperationParameters: navigationOperationParameters.copyWith(
      routeName: HomeScreen.routeName,
    ));
  }

  static Future<dynamic> navigateToAddPhotoGalleryScreen({
    required NavigationOperationParameters navigationOperationParameters,
    required AddPhotoGalleryNavigationArguments addPhotoGalleryScreenNavigationArguments,
  }) {
    return NavigationOperation.navigate(
      navigationOperationParameters: navigationOperationParameters.copyWith(
        routeName: AddPhotoGalleryScreen.routeName,
        arguments: addPhotoGalleryScreenNavigationArguments,
      ),
    );
  }


/*
  static Future<dynamic> navigateToAddBannerScreen(
      {required NavigationOperationParameters navigationOperationParameters,required AddBannerScreenNavigationArguments addBannerScreenNavigationArguments}) {
    return NavigationOperation.navigate(
        navigationOperationParameters: navigationOperationParameters.copyWith(
          routeName: AddBannerScreen.routeName,
          arguments: addBannerScreenNavigationArguments
        ));
  }
*/

}
