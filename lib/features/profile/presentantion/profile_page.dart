import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/common/slide_routing.dart';
import 'package:kabetex/features/auth/data/auth_services.dart';
import 'package:kabetex/features/auth/presentation/login.dart';
import 'package:kabetex/features/profile/presentantion/change_password.dart';
import 'package:kabetex/features/profile/presentantion/edit_profile.dart';
import 'package:kabetex/features/profile/widgets/not_logged_In.dart';
import 'package:kabetex/providers/home/profile_provider.dart';
import 'package:kabetex/providers/nav_bar.dart';
import 'package:kabetex/providers/theme_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _user = Supabase.instance.client.auth.currentUser;
  final _authService = AuthService();

  String? fName;
  bool? isVerified;
  bool isDeleting = false;
  bool isLoggingOut = false;

  bool get isLoggedIn => _user != null;

  Future<bool?> showDeleteConfirmation(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Text(
          'Are you sure you want to delete your account? This cannot be undone.',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge!.copyWith(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              'Delete',
              style: Theme.of(
                context,
              ).textTheme.bodySmall!.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);
    final asyncProfile = ref.watch(futureProfileProvider);

    // If not logged in, just return the NotLoggedIn widget
    if (!isLoggedIn) return const NotLoggedIn();

    return SafeArea(
      child: Column(
        children: [
          if (isDeleting)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else ...[
            // Top container
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(color: isDark ? null : null),
              child: Padding(
                padding: const EdgeInsets.only(top: 32.0, bottom: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.account_circle_rounded,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),

                    asyncProfile.when(
                      loading: () => const CircularProgressIndicator(),
                      error: (e, st) => Text(
                        'Error loading name',
                        style: TextStyle(
                          color: isDark ? Colors.red : Colors.red,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      data: (data) {
                        final fullName = data?['full_name'];
                        final bool isVerified = data?['isVerified'] ?? false;

                        return Column(
                          children: [
                            Text(
                              fullName,
                              style: Theme.of(context).textTheme.bodyLarge!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black,
                                    fontSize: 24,
                                  ),
                            ),
                            const SizedBox(height: 8),

                            Container(
                              margin: const EdgeInsets.all(4),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: isVerified
                                    ? Colors.green
                                    : Colors.red.withAlpha(200),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isVerified ? 'Verified seller' : 'Not Verified',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Edit profile tile
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
                    'Change password',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  leading: Icon(
                    Icons.password,
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
                      SlideRouting(page: const ChangePasswordPage()),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Delete account tile
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
                      setState(() => isDeleting = true);
                      final success = await _authService
                          .deleteUserFromSupabase();
                      if (success) {
                        await Supabase.instance.client.auth.signOut();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                          (route) => false,
                        );
                        ref.read(tabsProvider.notifier).state = 0;
                        setState(() => isDeleting = false);
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

            // Logout button at bottom
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () {
                  setState(() => isLoggingOut = true);
                  Supabase.instance.client.auth.signOut();
                  setState(() => isLoggingOut = false);
                },
                child: isLoggingOut
                    ? const Center(child: CircularProgressIndicator())
                    : const Text(
                        'Log Out',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
