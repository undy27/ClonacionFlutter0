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
import '../models/carta.dart';
import '../widgets/carta_widget.dart';

import '../services/sound_manager.dart';

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
          onPressed: () {
            SoundManager().playMenuButton();
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
         builder: (context, constraints) {
          // Calculate dynamic heights
          // Calculate dynamic heights
          // Vertical Padding: 16 (top) + 16 (bottom) = 32
          // Spacing Gaps: 8 * 7 (gaps between 8 items/blocks) = 56
          // Total Fixed Vertical Space: 32 + 56 = 88
          final double availableHeight = constraints.maxHeight - 88;
          
          // Units Calculation:
          // Server Pref: 1
          // Dark Mode: 1
          // Font Size: 1
          // Music/Sound: 1
          // Theme: 1
          // Avatar: 2.65
          // Cards: 2.65
          // Password: 1
          // Total Units = 6 + 5.3 = 11.3
          
          double unitHeight = availableHeight / 11.3;
          
          // Clamp to reasonable limits
          // Min 30 (very compact to fit all), Max 60 (spacious)
          unitHeight = unitHeight.clamp(30.0, 60.0);
          
          final double standardHeight = unitHeight;
          final double avatarHeight = unitHeight * 2.65;
          
          return Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Server Preference Toggle
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return _buildCompactOptionContainer(
                          context,
                          height: standardHeight,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "SERVIDOR INTERNET",
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    Text(
                                      authProvider.currentUser?.useInternetServer == true ? "clonacion.duckdns.org" : "192.168.1.7",
                                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                Transform.scale(
                                  scale: 0.8, // Slightly smaller switch to fit better
                                  child: Switch(
                                    value: authProvider.currentUser?.useInternetServer ?? true,
                                    activeColor: AppTheme.primary,
                                    onChanged: (value) {
                                      SystemSound.play(SystemSoundType.click);
                                      authProvider.toggleServerPreference(value);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),

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
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
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
                                    
                                    // Control background music based on new setting
                                    if (value) {
                                      SoundManager().playBackgroundMusic(musicEnabled: true);
                                    } else {
                                      SoundManager().stopBackgroundMusic();
                                    }
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
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                  dense: true,
                                  visualDensity: VisualDensity.compact,
                                  title: Text(
                                    "SONIDO",
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
                                icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).textTheme.bodyMedium?.color),
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

                    // Card Theme Selector
                    _buildCompactOptionContainer(
                      context,
                      height: avatarHeight, // Same height as avatar selector
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                            child: Text(
                              "ESTILO DE CARTA",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                          Expanded(
                            child: Consumer<AuthProvider>(
                              builder: (context, authProvider, _) {
                                final currentTheme = authProvider.currentUser?.temaCartas ?? 'moderno';
                                final themes = ['moderno', 'clasico'];
                                
                                return ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  itemCount: themes.length,
                                  itemBuilder: (context, index) {
                                    final themeName = themes[index];
                                    final isSelected = currentTheme == themeName;
                                    
                                    // Calculate card size based on container height
                                    // Available height for card: total - text - padding
                                    final cardHeight = avatarHeight - 34; // Adjusted for padding
                                    final cardWidth = cardHeight * 0.74; // Aspect ratio
                                    
                                    return GestureDetector(
                                      onTap: () async {
                                        SystemSound.play(SystemSoundType.click);
                                        // Update locally
                                        if (authProvider.currentUser != null) {
                                          // Create updated user object
                                          final updatedUser = Usuario(
                                            id: authProvider.currentUser!.id,
                                            alias: authProvider.currentUser!.alias,
                                            avatar: authProvider.currentUser!.avatar,
                                            rating: authProvider.currentUser!.rating,
                                            partidasJugadas: authProvider.currentUser!.partidasJugadas,
                                            victorias: authProvider.currentUser!.victorias,
                                            derrotas: authProvider.currentUser!.derrotas,
                                            mejorTiempoVictoria: authProvider.currentUser!.mejorTiempoVictoria,
                                            mejorTiempoVictoria2j: authProvider.currentUser!.mejorTiempoVictoria2j,
                                            mejorTiempoVictoria3j: authProvider.currentUser!.mejorTiempoVictoria3j,
                                            mejorTiempoVictoria4j: authProvider.currentUser!.mejorTiempoVictoria4j,
                                            temaCartas: themeName, // Update theme
                                            temaInterfaz: authProvider.currentUser!.temaInterfaz,
                                            isGuest: authProvider.currentUser!.isGuest,
                                            isDarkMode: authProvider.currentUser!.isDarkMode,
                                          );
                                          
                                          // Update provider
                                          authProvider.updateUser(updatedUser);
                                          
                                          // Update DB
                                          await PostgresService().updateTemaCartas(authProvider.currentUser!.id, themeName);
                                        }
                                      },
                                        child: Container(
                                          margin: const EdgeInsets.only(right: 12, bottom: 8),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: isSelected ? AppTheme.primary : Colors.transparent,
                                              width: 3,
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
                                            borderRadius: BorderRadius.circular(5),
                                            child: IgnorePointer( // Ignore taps on the card itself so the container handles it
                                              child: CartaWidget(
                                                carta: Carta(
                                                  id: 'sample_option',
                                                  multiplicaciones: [[3, 7], [10, 4], [6, 6]],
                                                  division: [24, 8],
                                                  resultados: [21, 40, 36],
                                                ),
                                                tema: themeName,
                                                width: cardWidth,
                                                height: cardHeight,
                                                isVisible: true,
                                                maxCharsInBoard: 2, // Example
                                              ),
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
