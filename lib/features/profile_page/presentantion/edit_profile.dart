import 'package:flutter/material.dart';
import 'package:kabetex/features/profile_page/data/profile_services.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _profileService = ProfileServices();

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController yearController;

  Future<void> fetchProfile() async {
    final profile = await _profileService.getProfile();

    setState(() {
      nameController.text = profile!['full_name'] ?? 'loading';
      emailController.text = profile['email'] ?? 'loading';
      phoneController.text = profile['phone_number'] ?? 'loading';
      yearController.text = profile['year'] ?? 'loading';
    });
  }

  @override
  void initState() {
    super.initState();
    fetchProfile();
    // Initialize controllers with user's current data
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    yearController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    yearController.dispose();
    super.dispose();
  }

  void updateProfile() async {
    await _profileService.updateProfile({
      'full_name': nameController.text,
      'email': emailController.text,
      'phone_number': phoneController.text,
      'year': yearController.text,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: Theme.of(context).textTheme.titleLarge!,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              readOnly: true, // optional, maybe user can't change email
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: yearController,
              decoration: const InputDecoration(labelText: 'Year'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(onPressed: updateProfile, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}
