import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'providers/inheritance_provider.dart';
import 'ui/screens/home_screen.dart';

class FaraidApp extends StatelessWidget {
  const FaraidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InheritanceProvider(),
      child: MaterialApp(
        title: 'app_title'.tr(),
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          EasyLocalization.of(context)!.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: EasyLocalization.of(context)!.supportedLocales,
        locale: EasyLocalization.of(context)!.locale,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}