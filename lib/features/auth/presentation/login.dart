import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/1community/providers/user_provider.dart';
import 'package:kabetex/features/auth/presentation/sign_up.dart';
import 'package:kabetex/features/auth/widgets/error_BotttomSheet.dart';
import 'package:kabetex/features/home/presentations/tabs_screen.dart';
import 'package:kabetex/features/auth/data/auth_services.dart';
import 'package:kabetex/common/slide_routing.dart';
import 'package:kabetex/features/products/providers/user_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  AuthService authService = AuthService();
  bool isLogging = false;
  bool hidePass = true;

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLogging = true);

    if (!mounted) return;

    try {
      await authService.signInfcn(
        email: _emailController.text.trim(),
        password: _passController.text.trim(),
      );

      final user = Supabase.instance.client.auth.currentUser;

      if (user != null) {
        Navigator.pushReplacement(
          context,
          SlideRouting(page: const TabsScreen()),
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login successful🥂')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed, check your credentials')),
        );
      }
      await ref.refresh(futureProfileProvider.future);
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
      setState(() => isLogging = false);
      await ref.refresh(futureProfileProvider.future);
      ref.invalidate(userByIDProvider);
      ref.refresh(userByIDProvider(null));
      ref.invalidate(currentUserIdProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Focus(
              autofocus: true,
              child: Builder(
                builder: (context) => GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus(); // dismiss keyboard
                  },
                  //behavior: HitTestBehavior.translucent,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4.0,
                      vertical: 100,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Login here',
                          style: Theme.of(context).textTheme.titleLarge!
                              .copyWith(
                                color: Colors.deepOrange,
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                              ),
                        ),

                        const SizedBox(height: 16),

                        //welcome text
                        Text(
                          "Welcome back you've \n been missed!",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge!
                              .copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                        ),

                        const SizedBox(height: 16),

                        //email input
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              //email
                              SizedBox(
                                width: double.infinity,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0,
                                    vertical: 16,
                                  ),
                                  child: TextFormField(
                                    autocorrect: false,
                                    autofocus: false,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .copyWith(color: Colors.black),
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.email,
                                        color: Colors.grey[600],
                                      ),
                                      filled: true,
                                      fillColor: const Color.fromARGB(
                                        21,
                                        255,
                                        86,
                                        34,
                                      ),
                                      hintText: 'Email',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                      errorBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.red,
                                          width: 1.5,
                                        ),
                                      ),
                                      enabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.deepOrange,
                                          width: 1.5,
                                        ),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    controller: _emailController,
                                    validator: (value) {
                                      if (value == null ||
                                          value.isEmpty ||
                                          !value.contains('@') ||
                                          value.length < 4) {
                                        return 'Please enter a valid Email address';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),

                              // password field
                              SizedBox(
                                width: double.infinity,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0,
                                    vertical: 16,
                                  ),
                                  child: TextFormField(
                                    autocorrect: false,
                                    autofocus: false,
                                    obscureText: hidePass,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .copyWith(color: Colors.black),
                                    keyboardType: TextInputType.visiblePassword,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.lock,
                                        color: Colors.grey[600],
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            hidePass = !hidePass;
                                          });
                                        },
                                        icon: Icon(
                                          hidePass
                                              ? Icons.remove_red_eye_outlined
                                              : Icons.visibility_off,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: const Color.fromARGB(
                                        21,
                                        255,
                                        86,
                                        34,
                                      ),
                                      hintText: 'Password',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                      enabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                      ),
                                      errorBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.red,
                                          width: 1.5,
                                        ),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.deepOrange,
                                          width: 1.5,
                                        ),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    controller: _passController,
                                    validator: (value) {
                                      if (value == null ||
                                          value.isEmpty ||
                                          value.length < 6) {
                                        return 'Password must be more than 6 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                              //forgot pass
                              Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0,
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    'Forgot your password?',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              ),

                              //sign in btn
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                  vertical: 8,
                                ),
                                child: GestureDetector(
                                  onTap: login,
                                  child: Container(
                                    height: 50,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.deepOrange,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 5,
                                          color: Colors.grey[700]!,
                                          offset: const Offset(1, 3),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: isLogging
                                          ? const SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                              ),
                                            )
                                          : Text(
                                              'Sign in',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              //create an acc
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    SlideRouting(page: const SignupPage()),
                                  );
                                },
                                child: Text(
                                  'Create an account',
                                  style: Theme.of(context).textTheme.bodyLarge!
                                      .copyWith(
                                        color: Colors.deepOrange,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 8),

                              Text(
                                'Or',
                                style: TextStyle(color: Colors.grey[500]),
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
                                    fontSize: 16,
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
          ),
        ),
      ),
    );
  }
}
