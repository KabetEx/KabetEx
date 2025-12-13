import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/auth/providers/user_provider.dart';
import 'package:kabetex/features/auth/widgets/error_BotttomSheet.dart';
import 'package:kabetex/features/home/presentations/tabs_screen.dart';
import 'package:kabetex/common/slide_routing.dart';
import 'package:kabetex/features/auth/data/auth_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage>
    with SingleTickerProviderStateMixin {
  final authService = AuthService();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _selectedYear;

  bool hidePassword = true;
  bool isSigningUp = false;

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
    _passwordController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  final Map<String, int> yearMap = {
    '1st Year': 1,
    '2nd Year': 2,
    '3rd Year': 3,
    '4th Year': 4,
  };

  void submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSigningUp = true);
    final int selectedYearInt = yearMap[_selectedYear]!;

    try {
      await authService.signUp(
        email: _emailController.text.trim().toLowerCase(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        year: selectedYearInt,
      );

      final session = Supabase.instance.client.auth.currentSession;

      if (session != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign Up successful! 🎉'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          SlideRouting(page: const TabsScreen()),
        );
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
      setState(() {
        isSigningUp = false;
      });
      ref.invalidate(userByIDProvider);
      ref.refresh(userByIDProvider(null));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: FadeTransition(
          opacity: _fadeInAnim,
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'KabetEx',
                    style: theme.textTheme.headlineLarge!.copyWith(
                      color: Colors.deepOrange.shade400,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Connect with students ',
                          style: theme.textTheme.labelLarge!.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        const TextSpan(
                          text: '👩‍🎓👨‍🎓',
                          style: TextStyle(fontSize: 26),
                        ),
                        TextSpan(
                          text: ',\n buy & sell ',
                          style: theme.textTheme.labelLarge!.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const TextSpan(
                          text: '🛍️💸',
                          style: TextStyle(fontSize: 26),
                        ),
                        TextSpan(
                          text: ' on campus!',
                          style: theme.textTheme.labelLarge!.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        //NAME FIELD
                        AnimatedInputField(
                          controller: _nameController,
                          hint: 'Full Name',
                          icon: Icons.person,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Enter your name' : null,
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 16),

                        //EMAIL FIELD
                        AnimatedInputField(
                          controller: _emailController,
                          hint: 'Email',
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => v != null && v.contains('@')
                              ? null
                              : 'Enter valid email',
                        ),
                        const SizedBox(height: 16),

                        //Phone number field
                        AnimatedInputField(
                          controller: _phoneController,
                          hint: 'WhatsApp Number',
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Enter number';
                            if (!RegExp(r'^(07\d{8}|01\d{8})$').hasMatch(v)) {
                              return 'Invalid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Dropdown for year
                        AnimatedDropdown(
                          value: _selectedYear,
                          items: yearMap.keys.toList(),
                          onChanged: (v) => setState(() => _selectedYear = v),
                          hint: 'Select your campus year',
                          yearMap: yearMap,
                        ),
                        const SizedBox(height: 16),

                        //PASSWORD FIELD
                        AnimatedInputField(
                          controller: _passwordController,
                          hint: 'Password',
                          icon: Icons.lock,
                          obscureText: hidePassword,
                          suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => hidePassword = !hidePassword),
                            icon: Icon(
                              hidePassword
                                  ? Icons.remove_red_eye_outlined
                                  : Icons.visibility_off,
                              color: Colors.grey[600],
                            ),
                          ),
                          validator: (v) => v != null && v.length >= 6
                              ? null
                              : 'Password too short',
                        ),
                        const SizedBox(height: 24),

                        //SIGN UP BUTTON
                        AnimatedButton(
                          label: 'Sign Up',
                          onTap: submitForm,
                          isLoading: isSigningUp,
                        ),

                        const SizedBox(height: 16),

                        //ALREADY HAVE AN ACCOUNT
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Already have an account? Login',
                            style: theme.textTheme.bodyMedium!.copyWith(
                              color: Colors.deepOrange.shade400,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              SlideRouting(page: const TabsScreen()),
                            );
                          },
                          child: const Text(
                            'Continue as Guest',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
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
  final int? maxLength;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;

  const AnimatedInputField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
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
        maxLength: maxLength,
        textCapitalization: textCapitalization,
        validator: validator,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          counter: null,
          counterText: '',
          errorStyle: const TextStyle(color: Colors.red),
          prefixIcon: Icon(icon, color: Colors.deepOrange.shade400),
          filled: true,
          fillColor: Colors.white.withAlpha(15),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.deepOrange.shade400, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}

class AnimatedDropdown extends StatelessWidget {
  final String? value;
  final List<String> items;
  final void Function(String?)? onChanged;
  final String hint;
  final Map<String, int> yearMap;

  const AnimatedDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.hint,
    required this.yearMap,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      builder: (context, valueAnim, child) {
        return Opacity(
          opacity: valueAnim,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - valueAnim)),
            child: child,
          ),
        );
      },
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.deepOrange.shade400, width: 0.5),
        ),
        child: DropdownButtonFormField<String>(
          initialValue: yearMap.keys.first,
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Center(
                    child: Text(e, style: const TextStyle(color: Colors.white)),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
          decoration: const InputDecoration(
            border: InputBorder.none,
            isDense: true,
          ),
          dropdownColor: const Color(0xFF1E1E1E),
          validator: (v) => v == null || v.isEmpty ? hint : null,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class AnimatedButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isLoading;

  const AnimatedButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
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
          color: isLoading ? Colors.deepOrange.shade200 : Colors.deepOrange,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.deepOrange.shade300.withAlpha(60),
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
