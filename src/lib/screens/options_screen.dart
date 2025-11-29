import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../services/postgres_service.dart';

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
              const SizedBox(height: 20),

              // Interface Theme Selector
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  final isNeo = themeProvider.themeStyle == AppThemeStyle.neoBrutalist;
                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor,
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? (isNeo ? AppTheme.darkBorder : Colors.white24) 
                            : (isNeo ? AppTheme.border : Colors.black12), 
                        width: isNeo ? 2 : 1
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isNeo ? AppTheme.smallHardShadow : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "TEMA VISUAL",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        DropdownButton<AppThemeStyle>(
                          value: themeProvider.themeStyle,
                          underline: const SizedBox(),
                          icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).primaryColor),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
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
                      ],
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
