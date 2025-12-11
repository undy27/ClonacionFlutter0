import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/custom_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

enum AuthMode { menu, login, register, guest }

class _AuthScreenState extends State<AuthScreen> {
  AuthMode _mode = AuthMode.menu;
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();
  final _guestFormKey = GlobalKey<FormState>();
  final _aliasController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Init DB schema
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 48,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                
                // Title
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

                // Content based on mode
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildContent(),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_mode) {
      case AuthMode.menu:
        return Column(
          key: const ValueKey('menu'),
          children: [
            _buildMenuButton("JUGAR SIN REGISTRARSE", () => setState(() => _mode = AuthMode.guest)),
            const SizedBox(height: 16),
            _buildMenuButton("INICIAR SESIÓN", () => setState(() => _mode = AuthMode.login)),
            const SizedBox(height: 16),
            _buildMenuButton("REGISTRO", () => setState(() => _mode = AuthMode.register)),
          ],
        );
      case AuthMode.login:
        return _buildForm("INICIAR SESIÓN", isLogin: true);
      case AuthMode.register:
        return _buildForm("REGISTRO", isRegister: true);
      case AuthMode.guest:
        return _buildForm("JUGAR COMO INVITADO", isGuest: true);
    }
  }

  Widget _buildMenuButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: text,
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildForm(String title, {bool isLogin = false, bool isRegister = false, bool isGuest = false}) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    GlobalKey<FormState> currentKey;
    if (isLogin) currentKey = _loginFormKey;
    else if (isRegister) currentKey = _registerFormKey;
    else currentKey = _guestFormKey;
    
    return Container(
      key: ValueKey(title),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.border, 
          width: 3
        ),
        boxShadow: AppTheme.hardShadow,
      ),
      child: Form(
        key: currentKey,
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
                  onPressed: () {
                    _aliasController.clear();
                    _passwordController.clear();
                    setState(() => _mode = AuthMode.menu);
                  },
                ),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48), // Balance back button
              ],
            ),
            const SizedBox(height: 24),
            
            TextFormField(
              controller: _aliasController,
              decoration: const InputDecoration(labelText: "Usuario"),
              validator: (value) => value!.isEmpty ? "Requerido" : null,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            
            if (!isGuest)
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Contraseña"),
                obscureText: true,
                validator: (value) => value!.isEmpty ? "Requerido" : null,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              child: authProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton(
                      text: "ENTRAR",
                      color: AppTheme.success,
                      onPressed: () async {
                        if (currentKey.currentState!.validate()) {
                          bool success = false;
                          final alias = _aliasController.text;
                          final password = _passwordController.text;

                          if (isLogin) {
                            success = await authProvider.login(alias, password);
                          } else if (isRegister) {
                            success = await authProvider.register(alias, password);
                          } else if (isGuest) {
                            success = await authProvider.loginAsGuest(alias);
                          }

                          if (success && mounted) {
                             final user = authProvider.currentUser;
                             if (user != null) {
                                Provider.of<ThemeProvider>(context, listen: false).syncFromUser(user.isDarkMode, user.temaInterfaz);
                             }
                             Navigator.pushReplacementNamed(context, '/home');
                          } else if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Error de autenticación")),
                            );
                          }
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
