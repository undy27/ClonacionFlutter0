import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';

import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/game_list_screen.dart';
import 'screens/game_screen.dart';
import 'screens/ranking_screen.dart';
import 'screens/options_screen.dart';
import 'screens/card_theme_screen.dart';
import 'screens/waiting_room_screen.dart';

import 'providers/auth_provider.dart';
import 'screens/auth_screen.dart';

import 'providers/theme_provider.dart';
import 'providers/online_game_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        ChangeNotifierProxyProvider<AuthProvider, OnlineGameProvider>(
          create: (_) => OnlineGameProvider(),
          update: (_, auth, onlineGame) => onlineGame!..setUser(auth.currentUser),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'Clonación',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(themeProvider.themeStyle, Brightness.light),
      darkTheme: AppTheme.getTheme(themeProvider.themeStyle, Brightness.dark),
      themeMode: themeProvider.themeMode,
      initialRoute: '/',
      builder: (context, child) {
        // Print screen resolution on startup
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final size = MediaQuery.of(context).size;
          final pixelRatio = MediaQuery.of(context).devicePixelRatio;
          print('Screen Resolution: ${size.width.toStringAsFixed(1)}x${size.height.toStringAsFixed(1)} (Logical), ${size.width * pixelRatio}x${size.height * pixelRatio} (Physical), Pixel Ratio: $pixelRatio');
        });
        return child!;
      },
      routes: {
        '/': (context) => const SplashScreen(),
        '/auth': (context) => const AuthScreen(),
        '/home': (context) => const HomeScreen(),
        '/game_list': (context) => const GameListScreen(),
        '/game': (context) => const GameScreen(),
        '/ranking': (context) => const RankingScreen(),
        '/options': (context) => const OptionsScreen(),
        '/card_theme': (context) => const CardThemeScreen(),
        '/waiting_room': (context) => const WaitingRoomScreen(),
      },
    );
  }
}
