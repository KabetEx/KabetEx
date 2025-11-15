import 'package:flutter/material.dart';
import 'package:kabetex/pages/tabs_screen.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Text(
              'Login here',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
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
                          fillColor: const Color.fromARGB(50, 255, 149, 0),
                          hintText: 'Email',
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.orangeAccent,
                              width: 1,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
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
                        obscureText: true,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: const Icon(Icons.remove_red_eye_outlined),
                          filled: true,
                          fillColor: const Color.fromARGB(21, 255, 86, 34),
                          hintText: 'Password',
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.orangeAccent,
                              width: 1,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  //forgot pass
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 8,
                      ),
                      child: Text('Forgot your password?'),
                    ),
                  ),

                  //sign in btn
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 8,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TabsScreen(),
                          ),
                        );
                      },
                      child: Container(
                        height: 45,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.deepOrange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Center(child: Text('Sign in')),
                      ),
                    ),
                  ),
                  //create an acc
                  const Text('Create an account'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
