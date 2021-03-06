import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:prapare/controllers/theme_controller.dart';
import 'package:prapare/ui/localization.dart';
import 'package:prapare/routes/routes.dart';

import 'controllers/controllers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initServices();
  runApp(MyApp());
}

// Theme uses GetxService so that it isn't closed during app lifecycle
Future<void> _initServices() async {
  await GetStorage.init();
  Get.put<StorageController>(StorageController());
  await StorageController.to.getFirstLoadInfoFromStore();
  Get.put<LocaleController>(LocaleController());
  Get.put<ThemeController>(ThemeController());
  await ThemeController.to.getThemeModeFromStore();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // *** LOCALES ***
      locale: LocaleController.to.getLocale(), // <- Current locale
      // ignore: prefer_const_literals_to_create_immutables
      localizationsDelegates: [
        const AppLocalizationsDelegate(), // <- Your custom delegate
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales:
          AppLocalizations.languages.keys.toList(), // <- Supported locales

      // *** THEMES ***
      theme: ThemeController.to.lightTheme.themeData,
      darkTheme: ThemeController.to.darkTheme.themeData,
      themeMode: ThemeController.to.themeMode,

      // *** ROUTES ***
      initialRoute:
          StorageController.to.isFirstLoad ? Routes.INFO : Routes.HOME,
      // home: ,
      getPages: AppPages.pages,
      debugShowCheckedModeBanner: false,
      // defaultTransition: Transition.fade,
    );
  }
}
