import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../services/sound_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Start background music when entering home screen
    SoundManager().playBackgroundMusic();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              
              // Logo/Title
              Text(
                "CLONACIÓN",
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppTheme.primary,
                  shadows: AppTheme.hardShadow,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Multiplica tu mente",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.secondary,
                ),
              ),
              const SizedBox(height: 30),

              // Sheep GIF
              Hero(
                tag: 'sheep_gif',
                child: Image.asset(
                  'assets/ovejas/clon.gif',
                  fit: BoxFit.contain,
                  width: MediaQuery.of(context).size.width * 0.4,
                ),
              ),
              const SizedBox(height: 30),

              // Buttons
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: "JUGAR",
                  onPressed: () {
                     Navigator.pushNamed(context, '/game_list');
                  },
                ),
              ),
              const SizedBox(height: 20),
              
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: "RANKING",
                  color: AppTheme.secondary,
                  onPressed: () {
                    Navigator.pushNamed(context, '/ranking');
                  },
                ),
              ),
              const SizedBox(height: 20),
              
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: "OPCIONES",
                  color: AppTheme.accent,
                  onPressed: () {
                    Navigator.pushNamed(context, '/options');
                  },
                ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}
