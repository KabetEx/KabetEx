import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/common/slide_routing.dart';
import 'package:kabetex/features/auth/data/auth_services.dart';
import 'package:kabetex/features/auth/presentation/sign_up.dart';
import 'package:kabetex/features/auth/providers/auth_provider.dart';
import 'package:kabetex/features/auth/providers/user_provider.dart';
import 'package:kabetex/features/auth/widgets/error_BotttomSheet.dart';
import 'package:kabetex/features/home/presentations/tabs_screen.dart';
import 'package:kabetex/features/home/providers/nav_bar.dart';
import 'package:kabetex/providers/theme_provider.dart';
import 'package:kabetex/utils/snackbars.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool isLogging = false;
  bool hidePass = true;

  late AnimationController _animController;
  late Animation<double> _fadeInAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeInAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeIn));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLogging = true);

    if (!mounted) return;

    try {
      await AuthService().signInfcn(
        email: _emailController.text.trim(),
        password: _passController.text.trim(),
      );

      final user = ref.watch(authStateProvider);

      if (user.value != null) {
        ref.read(tabsProvider.notifier).state = 0;
        Navigator.pushReplacement(
          context,
          SlideRouting(page: const TabsScreen()),
        );
      }

      Future.microtask(() {
        if (mounted) {
          SuccessSnackBar.show(
            context: context,
            message: 'Welcome back! Login successful 🥂',
            isDark: ref.read(isDarkModeProvider),
          );
        }
      });

      if (mounted) {
        ref.invalidate(userByIDProvider);
        ref.invalidate(currentUserIdProvider);
      }
    } catch (e) {
      String error = e.toString();
      if (e is SocketException) {
        error = 'Please check your internet connection';
      } else if (e.toString().contains('Failed host lookup')) {
        error = 'Cannot reach the server. Check your internet connection';
      }

      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF1E1E1E),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        builder: (_) => ErrorBottomSheet(error: error),
      );
    } finally {
      setState(() => isLogging = false);
      ref.invalidate(currentUserIdProvider);
      ref.invalidate(authStateProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = ref.watch(isDarkModeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            FadeTransition(
              opacity: _fadeInAnim,
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Brand Logo
                        Text(
                          'KabetEx',
                          style: theme.textTheme.headlineMedium!.copyWith(
                            color: Colors.deepOrange.shade400,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Welcome back 👋\nLet's make today productive!",
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Email & Password form
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              AnimatedInputField(
                                controller: _emailController,
                                hint: 'Email',
                                icon: Icons.email,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) => v != null && v.contains('@')
                                    ? null
                                    : 'Enter a valid email',
                                isDark: isDark,
                              ),
                              const SizedBox(height: 16),
                              AnimatedInputField(
                                controller: _passController,
                                hint: 'Password',
                                icon: Icons.lock,
                                obscureText: hidePass,
                                suffixIcon: IconButton(
                                  onPressed: () =>
                                      setState(() => hidePass = !hidePass),
                                  icon: Icon(
                                    hidePass
                                        ? Icons.remove_red_eye_outlined
                                        : Icons.visibility_off,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                validator: (v) => v != null && v.length >= 6
                                    ? null
                                    : 'Min 6 characters',
                                isDark: isDark,
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {},
                                  child: const Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Sign in button
                        AnimatedButton(
                          isLoading: isLogging,
                          label: 'Sign In',
                          onTap: login,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),

                        // OR divider
                        const OrDivider(),

                        const SizedBox(height: 16),

                        // Continue as Guest
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              SlideRouting(page: const TabsScreen()),
                            );
                          },
                          child: Text(
                            'Continue as Guest',
                            style: TextStyle(
                              color: Colors.deepOrange.shade400,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Sign up
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account?  ",
                              style: TextStyle(color: Colors.white70),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  SlideRouting(page: const SignupPage()),
                                );
                              },
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepOrange.shade400,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------
// Reusable Widgets
// --------------------

class AnimatedInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool isDark;

  const AnimatedInputField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.deepOrange.shade400),
          filled: true,
          fillColor: isDark
              ? Colors.white.withAlpha(15)
              : Colors.black.withAlpha(15),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.deepOrange.shade400, width: 2),
          ),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}

class AnimatedButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isLoading;
  final bool isDark;

  const AnimatedButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isLoading
              ? Colors.deepOrange.shade100
              : Colors.deepOrange.shade600,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.deepOrange.shade900.withAlpha(100),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
        ),
      ),
    );
  }
}

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(thickness: 1, color: Colors.white.withAlpha(50)),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'OR',
            style: TextStyle(
              color: Colors.white54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Divider(thickness: 1, color: Colors.white.withAlpha(50)),
        ),
      ],
    );
  }
}
