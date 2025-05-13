import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators/form_validators.dart';
import '../../../../core/widgets/accessible_button.dart';
import '../../../../core/services/speech_service.dart';
import '../../data/services/auth_service.dart';
import '../../../../core/services/navigation_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _speechService = SpeechService();
  final _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _createTestUser();
  }

  Future<void> _createTestUser() async {
    await _authService.createInitialUser();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        await _authService.login(
          _emailController.text,
          _passwordController.text,
        );
        NavigationService.replaceTo('/home');
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _startVoiceCommand() async {
    final result = await _speechService.startListening();
    if (result != null) {
      // Procesar comandos como "login test@example.com password123"
      final parts = result.toLowerCase().split(' ');
      if (parts.isNotEmpty) {
        switch (parts[0]) {
          case 'login':
            if (parts.length >= 3) {
              _emailController.text = parts[1];
              _passwordController.text = parts[2];
              await _handleLogin();
            }
            break;
          case 'clear':
            _emailController.clear();
            _passwordController.clear();
            break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.base,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'TEMPO',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'SAGE',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.mocha.mauve
                            : AppColors.latte.mauve,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                // Welcome Text
                Text(
                  l10n.welcome,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.signInMessage,
                  style: const TextStyle(
                    color: AppColors.subtext1,
                    fontSize: 14,
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.mocha.red
                          : AppColors.latte.red,
                      fontSize: 14,
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                // Login/Register Tabs
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface0,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface1,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            l10n.login,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppColors.mocha.mauve
                                  : AppColors.latte.mauve,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.mocha.subtext0
                                    : AppColors.latte.subtext0,
                          ),
                          child: Text(l10n.register),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Login Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppColors.mocha.subtext0
                                  : AppColors.latte.subtext0),
                          filled: true,
                          fillColor: AppColors.surface0,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: AppColors.text),
                        validator: FormValidators.validateEmail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppColors.mocha.subtext0
                                  : AppColors.latte.subtext0),
                          filled: true,
                          fillColor: AppColors.surface0,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: AppColors.text),
                        validator: FormValidators.validatePassword,
                        obscureText: true,
                      ),
                      const SizedBox(height: 24),
                      AccessibleButton.primary(
                        text: 'Iniciar Sesión',
                        onPressed: _handleLogin,
                        isLoading: _isLoading,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Voice Commands
                Text(
                  'Try voice commands',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.mocha.subtext0
                        : AppColors.latte.subtext0,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                IconButton(
                  onPressed: _startVoiceCommand,
                  icon: Icon(Icons.mic,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.mocha.mauve
                          : AppColors.latte.mauve),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.surface0,
                    padding: const EdgeInsets.all(16),
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
