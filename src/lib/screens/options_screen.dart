import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../services/postgres_service.dart';
import 'package:flutter/services.dart';

class OptionsScreen extends StatelessWidget {
  const OptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("OPCIONES"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Dark Mode Toggle
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return _buildCompactOptionContainer(
                      context,
                      child: SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        dense: true,
                        title: Text(
                          "MODO OSCURO",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        value: themeProvider.isDarkMode,
                        activeColor: AppTheme.primary,
                        onChanged: (value) {
                          SystemSound.play(SystemSoundType.click);
                          themeProvider.toggleTheme(value);
                          final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
                          if (user != null && !user.isGuest) {
                             PostgresService().updateThemePreference(user.id, value);
                          }
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Variable Font Size Toggle
                Consumer<GameProvider>(
                  builder: (context, gameProvider, child) {
                    return _buildCompactOptionContainer(
                      context,
                      child: SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        dense: true,
                        title: Text(
                          "TAMAÑO FUENTE VARIABLE",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        value: gameProvider.variableFontSize,
                        activeColor: AppTheme.primary,
                        onChanged: (value) {
                          SystemSound.play(SystemSoundType.click);
                          gameProvider.toggleVariableFontSize();
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Sounds Settings
                Consumer<GameProvider>(
                  builder: (context, gameProvider, child) {
                    return Column(
                      children: [
                        // Music Toggle
                        _buildCompactOptionContainer(
                          context,
                          child: SwitchListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                            dense: true,
                            title: Text(
                              "MÚSICA",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            value: gameProvider.musicEnabled,
                            activeColor: AppTheme.primary,
                            onChanged: (value) {
                              SystemSound.play(SystemSoundType.click);
                              gameProvider.toggleMusic();
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Sound Effects Toggle
                        _buildCompactOptionContainer(
                          context,
                          child: SwitchListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                            dense: true,
                            title: Text(
                              "EFECTOS SONOROS",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            value: gameProvider.soundEffectsEnabled,
                            activeColor: AppTheme.primary,
                            onChanged: (value) {
                              SystemSound.play(SystemSoundType.click);
                              gameProvider.toggleSoundEffects();
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Interface Theme Selector
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return _buildCompactOptionContainer(
                      context,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        dense: true,
                        title: Text(
                          "TEMA VISUAL",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        trailing: DropdownButtonHideUnderline(
                          child: DropdownButton<AppThemeStyle>(
                            value: themeProvider.themeStyle,
                            icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).primaryColor),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 12),
                            isDense: true,
                            items: [
                              DropdownMenuItem(
                                value: AppThemeStyle.neoBrutalist,
                                child: Text("NEO-BRUTALISTA", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                              ),
                              DropdownMenuItem(
                                value: AppThemeStyle.classic,
                                child: Text("CLÁSICO", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                              ),
                              DropdownMenuItem(
                                value: AppThemeStyle.glassmorphism,
                                child: Text("GLASSMORPHISM", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                              ),
                              DropdownMenuItem(
                                value: AppThemeStyle.claymorphism,
                                child: Text("CLAYMORPHISM", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                              ),
                              DropdownMenuItem(
                                value: AppThemeStyle.skeuomorphism,
                                child: Text("SKEUOMORPHISM", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                              ),
                            ],
                            onChanged: (AppThemeStyle? newValue) {
                              if (newValue != null) {
                                SystemSound.play(SystemSoundType.click);
                                themeProvider.setThemeStyle(newValue);
                                final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
                                if (user != null && !user.isGuest) {
                                   String themeStr = 'neo_brutalista';
                                   if (newValue == AppThemeStyle.classic) themeStr = 'clasico';
                                   else if (newValue == AppThemeStyle.glassmorphism) themeStr = 'glassmorphism';
                                   else if (newValue == AppThemeStyle.claymorphism) themeStr = 'claymorphism';
                                   else if (newValue == AppThemeStyle.skeuomorphism) themeStr = 'skeuomorphism';
                                   
                                   PostgresService().updateTemaInterfaz(
                                     user.id, 
                                     themeStr
                                   );
                                }
                              }
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Card Theme Button
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: CustomButton(
                    text: "ESTILO DE CARTA",
                    color: AppTheme.primary,
                    onPressed: () {
                      Navigator.pushNamed(context, '/card_theme');
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Change Password Button (disabled for now)
                SizedBox(
                  width: double.infinity,
                  height: 45,
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
                const SizedBox(height: 12),

                // Avatar Button (disabled for now)
                SizedBox(
                  width: double.infinity,
                  height: 45,
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
      ),
    );
  }

  Widget _buildCompactOptionContainer(BuildContext context, {required Widget child}) {
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
      child: child,
    );
  }
}
