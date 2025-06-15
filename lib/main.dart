import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sheba_app/providers/history_provider.dart';
import 'package:sheba_app/screens/home_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sheba_app/theme/app_theme.dart';
import 'package:sheba_app/services/token_manager.dart'; // Import TokenManager

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TokenManager().initialize();

  runApp(
    ChangeNotifierProvider(
      create: (context) => HistoryProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'استعلام شماره شبا',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fa', 'IR'),
      ],
      locale: const Locale('fa', 'IR'),
      home: const HomeScreen(),
    );
  }
}


