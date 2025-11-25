import 'package:flutter/material.dart';
import 'package:kabetex/features/auth/presentation/sign_up.dart';
import 'package:kabetex/features/home/presentations/tabs_screen.dart';
import 'package:kabetex/features/auth/data/auth_services.dart';
import 'package:kabetex/common/slide_routing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  AuthService authService = AuthService();
  bool isLogging = false;
  bool hidePass = true;

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLogging = true);

    try {
      await authService.signInfcn(
        email: _emailController.text.trim(),
        password: _passController.text.trim(),
      );

      final user = Supabase.instance.client.auth.currentUser;

      //i.e if an account is logged in
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
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unexpected error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLogging = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
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
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
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
                                    prefixIcon: const Icon(Icons.email),
                                    filled: true,
                                    fillColor: const Color.fromARGB(
                                      21,
                                      255,
                                      86,
                                      34,
                                    ),
                                    hintText: 'Email',
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
                                    prefixIcon: const Icon(Icons.lock),
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
                                  style: Theme.of(context).textTheme.bodyMedium!
                                      .copyWith(
                                        color: Colors.deepOrange,
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
                                      color: Colors.black,
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
                                  color: Colors.deepOrange,
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
    );
  }
}
