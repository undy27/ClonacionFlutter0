import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';

import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../services/postgres_service.dart';
import 'package:flutter/services.dart';
import '../utils/avatar_helper.dart';
import '../models/usuario.dart';

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
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate dynamic heights
          // Available height minus vertical padding (16*2) and spacing (8*6)
          final double availableHeight = constraints.maxHeight - 32 - 48;
          
          // We have 6 standard slots + 1 large slot (avatar, counts as ~2.2 slots)
          // Total units = 8.2
          double unitHeight = availableHeight / 8.2;
          
          // Clamp to reasonable limits
          // Min 45 (compact), Max 75 (spacious)
          unitHeight = unitHeight.clamp(45.0, 75.0);
          
          final double standardHeight = unitHeight;
          final double avatarHeight = unitHeight * 2.2;
          
          return Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Dark Mode Toggle
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, child) {
                        return _buildCompactOptionContainer(
                          context,
                          height: standardHeight,
                          child: SwitchListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            title: Text(
                              "MODO OSCURO",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
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
                    const SizedBox(height: 8),

                    // Variable Font Size Toggle
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, child) {
                        return _buildCompactOptionContainer(
                          context,
                          height: standardHeight,
                          child: SwitchListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            title: Text(
                              "TAMAÑO FUENTE VARIABLE",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            value: themeProvider.variableFontSize,
                            activeColor: AppTheme.primary,
                            onChanged: (value) {
                              SystemSound.play(SystemSoundType.click);
                              themeProvider.toggleVariableFontSize();
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),

                    // Sounds Settings
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, child) {
                        return Row(
                          children: [
                            Expanded(
                              child: _buildCompactOptionContainer(
                                context,
                                height: standardHeight,
                                child: SwitchListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                  dense: true,
                                  visualDensity: VisualDensity.compact,
                                  title: Text(
                                    "MÚSICA",
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  value: themeProvider.musicEnabled,
                                  activeColor: AppTheme.primary,
                                  onChanged: (value) {
                                    SystemSound.play(SystemSoundType.click);
                                    themeProvider.toggleMusic();
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildCompactOptionContainer(
                                context,
                                height: standardHeight,
                                child: SwitchListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                  dense: true,
                                  visualDensity: VisualDensity.compact,
                                  title: Text(
                                    "EFECTOS",
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  value: themeProvider.soundEffectsEnabled,
                                  activeColor: AppTheme.primary,
                                  onChanged: (value) {
                                    SystemSound.play(SystemSoundType.click);
                                    themeProvider.toggleSoundEffects();
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 8),

                    // Interface Theme Selector
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, child) {
                        return _buildCompactOptionContainer(
                          context,
                          height: standardHeight,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            title: Text(
                              "TEMA VISUAL",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
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
                    const SizedBox(height: 8),

                    // Avatar Selector
                    _buildCompactOptionContainer(
                      context,
                      height: avatarHeight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                            child: Text(
                              "AVATAR",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                          Expanded(
                            child: Consumer<AuthProvider>(
                              builder: (context, authProvider, _) {
                                final currentAvatar = authProvider.currentUser?.avatar ?? 'cientifico';
                                return ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  itemCount: AvatarHelper.availableAvatars.length,
                                  itemBuilder: (context, index) {
                                    final avatarName = AvatarHelper.availableAvatars[index];
                                    final isSelected = currentAvatar == avatarName;
                                    
                                    // Calculate avatar size based on container height
                                    final size = avatarHeight - 30; // Subtract text and padding
                                    
                                    return GestureDetector(
                                      onTap: () async {
                                        SystemSound.play(SystemSoundType.click);
                                        // Update locally
                                        if (authProvider.currentUser != null) {
                                          // Create updated user object
                                          final updatedUser = Usuario(
                                            id: authProvider.currentUser!.id,
                                            alias: authProvider.currentUser!.alias,
                                            avatar: avatarName, // Update avatar
                                            rating: authProvider.currentUser!.rating,
                                            partidasJugadas: authProvider.currentUser!.partidasJugadas,
                                            victorias: authProvider.currentUser!.victorias,
                                            derrotas: authProvider.currentUser!.derrotas,
                                            mejorTiempoVictoria: authProvider.currentUser!.mejorTiempoVictoria,
                                            mejorTiempoVictoria2j: authProvider.currentUser!.mejorTiempoVictoria2j,
                                            mejorTiempoVictoria3j: authProvider.currentUser!.mejorTiempoVictoria3j,
                                            mejorTiempoVictoria4j: authProvider.currentUser!.mejorTiempoVictoria4j,
                                            temaCartas: authProvider.currentUser!.temaCartas,
                                            temaInterfaz: authProvider.currentUser!.temaInterfaz,
                                            isGuest: authProvider.currentUser!.isGuest,
                                            isDarkMode: authProvider.currentUser!.isDarkMode,
                                          );
                                          
                                          // Update provider
                                          authProvider.updateUser(updatedUser);
                                          
                                          // Update DB
                                          await PostgresService().updateAvatar(authProvider.currentUser!.id, avatarName);
                                        }
                                      },
                                        child: Container(
                                          margin: const EdgeInsets.only(right: 8, bottom: 8),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                              color: isSelected ? AppTheme.primary : Colors.transparent,
                                              width: 2,
                                            ),
                                            boxShadow: isSelected ? [
                                              BoxShadow(
                                                color: AppTheme.primary.withOpacity(0.4),
                                                blurRadius: 6,
                                                spreadRadius: 1,
                                              )
                                            ] : null,
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.asset(
                                              AvatarHelper.getAvatarPath(avatarName, 0),
                                              width: size,
                                              height: size,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) {
                                                return Container(
                                                  width: size,
                                                  height: size,
                                                  color: Colors.grey[200],
                                                  child: const Icon(Icons.person, color: Colors.grey),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Card Theme Button
                    _buildCompactOptionContainer(
                      context,
                      height: standardHeight,
                      child: Material(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(10), // Match container radius - border width
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            SystemSound.play(SystemSoundType.click);
                            Navigator.pushNamed(context, '/card_theme');
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              "ESTILO DE CARTA",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold, 
                                fontSize: 13,
                                color: Colors.white
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Change Password Button (disabled for now)
                    Opacity(
                      opacity: 0.5,
                      child: _buildCompactOptionContainer(
                        context,
                        height: standardHeight,
                        child: Material(
                          color: AppTheme.accent,
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              // TODO: Implement password change
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                "MODIFICAR CONTRASEÑA",
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 13,
                                  color: Colors.white
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }

  Widget _buildCompactOptionContainer(BuildContext context, {required Widget child, double? height}) {
    return Container(
      height: height,
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
      alignment: Alignment.center,
      child: child,
    );
  }
}
