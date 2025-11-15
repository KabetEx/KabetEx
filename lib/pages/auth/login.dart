import 'package:flutter/material.dart';
import 'package:kabetex/pages/auth/sign_up.dart';
import 'package:kabetex/pages/tabs_screen.dart';
import 'package:kabetex/utils/slide_routing.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool hidePass = true;
  final _formKey = GlobalKey<FormState>();
  bool isLogging = false;

  void login() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLogging = true;
      });
      _formKey.currentState!.save();

      setState(() {
        isLogging = false;
      });
      Navigator.push(context, SlideRouting(page: const TabsScreen()));
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
                behavior: HitTestBehavior.translucent,
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
