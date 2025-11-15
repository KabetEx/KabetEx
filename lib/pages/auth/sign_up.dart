import 'package:flutter/material.dart';
import 'package:kabetex/pages/tabs_screen.dart';
import 'package:kabetex/utils/slide_routing.dart';
import 'package:kabetex/services/auth_services.dart';

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
    if (_formKey.currentState!.validate()) {
      setState(() => isSigningUp = true);

      try {
        await authService.signUp(
          email: _emailController.text,
          password: _passwordController.text,
          name: _nameController.text,
          phone: _phoneController.text,
          year: _selectedYear!,
        );

        // Navigate only after successful signup
        Navigator.pushReplacement(
          context,
          SlideRouting(page: const TabsScreen()),
        );
      } catch (e) {
        // Handle errors
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Signup failed: $e')));
      } finally {
        setState(() => isSigningUp = false);
      }
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
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
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
                            decoration: inputDecoration.copyWith(
                              prefixIcon: const Icon(Icons.person),
                              hintText: 'Full Name',
                            ),
                            controller: _nameController,
                            validator: (val) => val == null || val.isEmpty
                                ? 'Enter your name'
                                : null,
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
                              prefixIcon: const Icon(Icons.email),
                              hintText: 'Email',
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
                              prefixIcon: const Icon(Icons.phone),
                              hintText: 'WhatsApp number',
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
                            decoration: inputDecoration.copyWith(
                              prefixIcon: const Icon(Icons.lock),
                              hintText: 'Password',
                              suffixIcon: IconButton(
                                onPressed: () => setState(
                                  () => hidePassword = !hidePassword,
                                ),
                                icon: Icon(
                                  hidePassword
                                      ? Icons.remove_red_eye_outlined
                                      : Icons.visibility_off,
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: isSigningUp
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

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
                            Navigator.push(
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
    );
  }
}
