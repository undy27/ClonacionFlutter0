import 'package:flutter/material.dart';
import 'dart:async';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to auth screen after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/auth');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 48,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                
                // Invisible Title to preserve exact layout spacing
                Text(
                  "CLONACIÓN",
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Colors.transparent, // Invisible
                    shadows: [], // No shadows
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Multiplica tu mente",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.transparent, // Invisible
                  ),
                ),
                const SizedBox(height: 30),
                
                Hero(
                  tag: 'sheep_gif',
                  child: Image.asset(
                    'assets/ovejas/clon.gif',
                    fit: BoxFit.contain,
                    width: MediaQuery.of(context).size.width * 0.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
