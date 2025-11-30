import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kabetex/features/auth/widgets/error_BotttomSheet.dart';
import 'package:kabetex/features/home/presentations/tabs_screen.dart';
import 'package:kabetex/common/slide_routing.dart';
import 'package:kabetex/features/auth/data/auth_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final authService = AuthService();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _selectedYear;

  bool hidePassword = true;
  bool isSigningUp = false;

  void submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSigningUp = true);

    try {
      await authService.signUp(
        email: _emailController.text.trim().toLowerCase(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        year: _selectedYear!,
      );

      final session = Supabase.instance.client.auth.currentSession;

      //successful signup
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
        backgroundColor: Colors.grey[900],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        builder: (_) => ErrorBottomSheet(error: error),
      );
    } finally {
      setState(() {
        isSigningUp = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: const Color.fromARGB(21, 255, 86, 34),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'KabetEx',
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                      color: Colors.deepOrange,
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
                          style: Theme.of(context).textTheme.labelLarge!
                              .copyWith(
                                color: Colors.black,
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
                          style: Theme.of(context).textTheme.labelLarge!
                              .copyWith(
                                color: Colors.black,
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
                          style: Theme.of(context).textTheme.labelLarge!
                              .copyWith(
                                color: Colors.black,
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
                        // Full Name
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          child: TextFormField(
                            keyboardType: TextInputType.name,
                            textCapitalization: TextCapitalization.words,
                            decoration: inputDecoration.copyWith(
                              prefixIcon: Icon(
                                Icons.person,
                                color: Colors.grey[600],
                              ),
                              hintText: 'Full Name',
                              hintStyle: TextStyle(color: Colors.grey[600]),
                            ),

                            controller: _nameController,
                            validator: (val) => val == null || val.isEmpty
                                ? 'Enter your name'
                                : null,
                            style: Theme.of(context).textTheme.labelMedium!
                                .copyWith(color: Colors.black),
                          ),
                        ),

                        // Email
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          child: TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            decoration: inputDecoration.copyWith(
                              prefixIcon: Icon(
                                Icons.email,
                                color: Colors.grey[600],
                              ),
                              hintText: 'Email',
                              hintStyle: TextStyle(color: Colors.grey[600]),
                            ),
                            controller: _emailController,
                            validator: (val) {
                              if (val == null ||
                                  !val.contains('@') ||
                                  val.length < 4) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                            style: Theme.of(context).textTheme.labelMedium!
                                .copyWith(color: Colors.black),
                          ),
                        ),

                        // WhatsApp Number
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          child: TextFormField(
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            decoration: inputDecoration.copyWith(
                              prefixIcon: Icon(
                                Icons.phone,
                                color: Colors.grey[600],
                              ),
                              hintText: 'WhatsApp number',
                              hintStyle: TextStyle(color: Colors.grey[600]),
                              counterText: '',
                            ),
                            controller: _phoneController,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Enter a number';
                              }
                              if (!RegExp(
                                r'^(07\d{8}|01\d{8})$',
                              ).hasMatch(val)) {
                                return 'Invalid number (07xx or 01xx)';
                              }
                              return null;
                            },
                            style: Theme.of(context).textTheme.labelMedium!
                                .copyWith(color: Colors.black),
                          ),
                        ),

                        // Campus Year Dropdown
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          child: Center(
                            child: Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.deepOrange.withAlpha(
                                  10,
                                ), // subtle fill
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.deepOrange,
                                  width: 0.5,
                                ),

                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.deepOrange.withAlpha(25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  initialValue: _selectedYear,
                                  isExpanded: true,
                                  alignment: Alignment
                                      .center, // CENTER the selected text
                                  icon: const Icon(
                                    Icons.arrow_drop_down_circle,
                                    color: Colors.deepOrange,
                                    size: 28, // slightly bigger for balance
                                  ),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  items:
                                      [
                                            '1st Year',
                                            '2nd Year',
                                            '3rd Year',
                                            '4th Year',
                                          ]
                                          .map(
                                            (year) => DropdownMenuItem(
                                              value: year,
                                              child: Center(child: Text(year)),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (val) =>
                                      setState(() => _selectedYear = val),
                                  validator: (val) => val == null || val.isEmpty
                                      ? 'Select your campus year'
                                      : null,
                                  dropdownColor: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Password
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: hidePassword,
                            style: Theme.of(context).textTheme.labelMedium!
                                .copyWith(color: Colors.black),
                            decoration: inputDecoration.copyWith(
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Colors.grey[600],
                              ),
                              hintText: 'Password',
                              hintStyle: TextStyle(color: Colors.grey[600]),
                              suffixIcon: IconButton(
                                onPressed: () => setState(
                                  () => hidePassword = !hidePassword,
                                ),
                                icon: Icon(
                                  hidePassword
                                      ? Icons.remove_red_eye_outlined
                                      : Icons.visibility_off,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),

                            validator: (val) => val == null || val.length < 6
                                ? 'Password too short'
                                : null,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Sign Up Button
                        const SizedBox(height: 12),
                        _buildSignUpBtn(submitForm, isSigningUp),

                        // Already have account
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Already have an account? Login',
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  color: Colors.deepOrange,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),

                        // Continue as Guest
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
                              color: Colors.black,
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

Widget _buildSignUpBtn(VoidCallback onPressed, bool isSigningUp) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: isSigningUp
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Sign Up',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
      ),
    ),
  );
}
