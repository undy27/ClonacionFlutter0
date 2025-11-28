import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../providers/theme_provider.dart';

class OptionsScreen extends StatelessWidget {
  const OptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'OPCIONES',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Dark Mode Toggle
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? AppTheme.darkBorder 
                            : AppTheme.border, 
                        width: 2
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppTheme.smallHardShadow,
                    ),
                    child: SwitchListTile(
                      title: Text(
                        "MODO OSCURO",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      value: themeProvider.isDarkMode,
                      activeColor: AppTheme.primary,
                      onChanged: (value) {
                        themeProvider.toggleTheme(value);
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Card Theme Button
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: "ESTILO DE CARTA",
                  color: AppTheme.primary,
                  onPressed: () {
                    Navigator.pushNamed(context, '/card_theme');
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Sounds Button (disabled for now)
              SizedBox(
                width: double.infinity,
                child: Opacity(
                  opacity: 0.5,
                  child: CustomButton(
                    text: "SONIDOS",
                    color: AppTheme.secondary,
                    onPressed: () {
                      // TODO: Implement sounds settings
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Change Password Button (disabled for now)
              SizedBox(
                width: double.infinity,
                child: Opacity(
                  opacity: 0.5,
                  child: CustomButton(
                    text: "MODIFICAR CONTRASEÑA",
                    color: AppTheme.accent,
                    onPressed: () {
                      // TODO: Implement password change
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Avatar Button (disabled for now)
              SizedBox(
                width: double.infinity,
                child: Opacity(
                  opacity: 0.5,
                  child: CustomButton(
                    text: "AVATAR",
                    color: AppTheme.warning,
                    onPressed: () {
                      // TODO: Implement avatar selection
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
