import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/profile/data/profile_services.dart';
import 'package:kabetex/features/products/providers/user_provider.dart';
import 'package:kabetex/providers/theme_provider.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _profileService = ProfileServices();
  String? _selectedYear;
  bool isUpdating = false;
  final GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController yearController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    yearController = TextEditingController();
  }

  void updateProfile() async {
    if (_formKey1.currentState!.validate()) {
      setState(() => isUpdating = true);
      try {
        await _profileService.updateProfile({
          'full_name': nameController.text,
          'email': emailController.text,
          'phone_number': phoneController.text,
          'year': _selectedYear,
        });

        Navigator.pop(context);

        // Refresh profile data
        ref.refresh(futureProfileProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
      } finally {
        if(!mounted) return;
        setState(() => isUpdating = false);
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncProfile = ref.watch(futureProfileProvider);
    final isDark = ref.watch(isDarkModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: Theme.of(context).textTheme.titleLarge!,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: asyncProfile.when(
            data: (data) {
              //prevent overwriting user edits
              if (nameController.text.isEmpty) {
                nameController.text = data!['full_name'] ?? '';
              }
              if (emailController.text.isEmpty) {
                emailController.text = data!['email'] ?? '';
              }
              if (phoneController.text.isEmpty) {
                phoneController.text = data!['phone_number'] ?? '';
              }
              if (yearController.text.isEmpty) {
                yearController.text = data!['year'] ?? '';
              }
              _selectedYear ??= data!['year'];

              return Form(
                key: _formKey1,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      //name
                      child: TextFormField(
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person),
                          label: Text('Full Name'),
                        ),
                        controller: nameController,
                        validator: (val) => val == null || val.isEmpty
                            ? 'Enter your name'
                            : null,
                        style: Theme.of(context).textTheme.labelMedium!
                            .copyWith(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Email
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.email),
                          label: Text('Email Address'),
                        ),
                        controller: emailController,
                        validator: (val) {
                          if (val == null ||
                              !val.contains('@') ||
                              val.length < 4) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                        style: Theme.of(context).textTheme.labelMedium!
                            .copyWith(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    //phone
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: TextFormField(
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.phone),
                          label: Text('Whatsapp Number'),
                          counterText: '',
                        ),
                        controller: phoneController,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Enter a number';
                          }
                          if (!RegExp(r'^(07\d{8}|01\d{8})$').hasMatch(val)) {
                            return 'Invalid number (07xx or 01xx)';
                          }
                          return null;
                        },
                        style: Theme.of(context).textTheme.labelMedium!
                            .copyWith(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Center(
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                              alignment:
                                  Alignment.center, // CENTER the selected text
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
                                          child: Center(
                                            child: Text(
                                              year,
                                              style: TextStyle(
                                                color: isDark
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedYear = val),
                              validator: (val) => val == null || val.isEmpty
                                  ? 'Select your campus year'
                                  : null,
                              dropdownColor: isDark
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isUpdating ? null : updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: isUpdating
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    backgroundColor: Colors.deepOrange,
                                  ),
                                )
                              : Text(
                                  'Update Profile',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            error: (error, stackTrace) {
              return Center(child: Text('Error loading profile: $error'));
            },
            loading: () {
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }
}
