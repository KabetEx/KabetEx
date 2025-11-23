import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/common/slide_routing.dart';
import 'package:kabetex/features/auth/data/auth_services.dart';
import 'package:kabetex/features/auth/presentation/login.dart';
import 'package:kabetex/features/profile_page/data/profile_services.dart';
import 'package:kabetex/features/profile_page/presentantion/edit_profile.dart';
import 'package:kabetex/features/profile_page/widgets/not_logged_In.dart';
import 'package:kabetex/providers/theme_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with AutomaticKeepAliveClientMixin {
  final _user = Supabase.instance.client.auth.currentUser;
  final _profileService = ProfileServices();
  final _authService = AuthService();

  String? fName;
  bool? isVerified;

  @override
  void initState() {
    super.initState();
    _loadFname();
    _loadVerification();
  }

  @override
  bool get wantKeepAlive => true;
  bool get isLoggedIn => _user != null;

  Future<void> _loadFname() async {
    final name = await _profileService.getUserFname();
    if (mounted) {
      setState(() {
        fName = name;
      });
    }
  }

  String getVerText() {
    if (isVerified == null) return 'Loading...';
    return isVerified! ? 'Verified' : 'Not Verified';
  }

  Future<void> _loadVerification() async {
    final isVer = await _profileService.isVerified();
    if (mounted) {
      setState(() {
        isVerified = isVer;
      });
      print(isVer);
    }
  }

  Future<bool?> showDeleteConfirmation(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My profile',
          style: TextStyle(color: isDark ? null : Colors.black),
        ),
        centerTitle: true,
        backgroundColor: isDark ? const Color.fromARGB(255, 165, 55, 21) : null,
      ),
      bottomNavigationBar: isLoggedIn
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Supabase.instance.client.auth.signOut();
                },
                child: const Text(
                  'Log Out',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          : null,
      body: isLoggedIn
          ? Column(
              children: [
                //top container
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color.fromARGB(255, 165, 55, 21)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    //crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        backgroundImage: AssetImage(
                          'assets/images/avatar1.png',
                        ),
                        radius: 32,
                      ), // to be worked on later...
                      const SizedBox(height: 16),

                      Text(
                        fName ?? 'loading...',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        getVerText(),
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isVerified == true
                              ? Colors.green
                              : isVerified == false
                              ? Colors.red
                              : Colors.grey, // if null
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    splashColor: Colors.grey,
                    child: ListTile(
                      title: Text(
                        'Edit profile',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      leading: Icon(
                        Icons.supervised_user_circle,
                        color: isDark ? Colors.white : Colors.black,
                        size: 32,
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_outlined,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          SlideRouting(page: const EditProfilePage()),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    splashColor: Colors.grey,
                    child: ListTile(
                      title: Text(
                        'Delete account',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      leading: Icon(
                        Icons.delete,
                        color: isDark ? Colors.white : Colors.black,
                        size: 32,
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_outlined,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      onTap: () async {
                        final confirmed = await showDeleteConfirmation(context);
                        if (confirmed == true) {
                          final success = await _authService
                              .deleteUserFromSupabase();
                          if (success) {
                            // Sign out locally
                            await Supabase.instance.client.auth.signOut();
                            // Navigate to login page
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to delete account.'),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ),

                const Spacer(),
              ],
            )
          : const NotLoggedIn(),
    );
  }
}
