import 'package:flutter/material.dart';
import 'dart:async';

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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Matches Auth/Home top spacing: 40 + Title(~60) + 10 + Subtitle(~24) + 30 = ~164
              const SizedBox(height: 164), 
              
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
    );
  }
}
