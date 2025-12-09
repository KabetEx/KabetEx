import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/common/slide_routing.dart';
import 'package:kabetex/features/1community/providers/user_provider.dart';
import 'package:kabetex/features/auth/data/auth_services.dart';
import 'package:kabetex/features/auth/presentation/login.dart';
import 'package:kabetex/features/profile/presentantion/change_password.dart';
import 'package:kabetex/features/profile/presentantion/edit_profile.dart';
import 'package:kabetex/features/profile/presentantion/phone_verification.dart';
import 'package:kabetex/features/profile/widgets/not_logged_In.dart';
import 'package:kabetex/features/products/providers/user_provider.dart';
import 'package:kabetex/features/home/providers/nav_bar.dart';
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
      builder: (context) {
        final isDark = ref.watch(isDarkModeProvider);

        return AlertDialog(
          title: Text(
            'Delete Account',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 24,
            ),
          ),
          content: Text(
            'Are you sure you want to delete your account? This cannot be undone.',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: isDark ? Colors.grey[300] : Colors.black,
              fontSize: 18,
            ),
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
        );
      },
    );
  }

  void onVerified() {
    setState(() {
      isVerified = true;
    });
    ref.refresh(futureProfileProvider);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);
    final userID = ref.watch(currentUserIdProvider);
    final userProfileAsync = ref.watch(userByIDProvider(userID));

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
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(color: isDark ? null : null),
              child: Padding(
                padding: const EdgeInsets.only(top: 32.0, bottom: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    userProfileAsync.when(
                      loading: () => const CircularProgressIndicator(),
                      error: (e, st) => Text(
                        'Error loading name',
                        style: TextStyle(
                          color: isDark ? Colors.red : Colors.red,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      data: (data) {
                        final userProfile = data;

                        if (userProfile == null) {
                          return const Text('Not logged in');
                        }
                        final fullName = data!.name;
                        final bool isVerified = data.isVerified;

                        return Column(
                          children: [
                            CircleAvatar(
                              radius: 48,
                              backgroundImage: CachedNetworkImageProvider(
                                data.avatarUrl,
                              ),
                            ),
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
                            if (!isVerified)
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    SlideRouting(
                                      page: PhoneVerificationPage(
                                        phoneNumber: data.pNumber,
                                        onVerified: onVerified,
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Verify Now',
                                  style: Theme.of(context).textTheme.bodyLarge!
                                      .copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                        fontSize: 16,
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

            _buildProfileCard(
              isDark: isDark,
              leadingIcon: CupertinoIcons.profile_circled,
              trailingIcon: CupertinoIcons.right_chevron,
              title: 'Edit profile',
              onTap: () {
                Navigator.push(
                  context,
                  SlideRouting(page: const EditProfilePage()),
                );
              },
            ),

            _buildProfileCard(
              isDark: isDark,
              leadingIcon: CupertinoIcons.padlock,
              trailingIcon: CupertinoIcons.right_chevron,
              title: 'Change password',
              onTap: () {
                Navigator.push(
                  context,
                  SlideRouting(page: const ChangePasswordPage()),
                );
              },
            ),
            _buildProfileCard(
              isDark: isDark,
              leadingIcon: CupertinoIcons.delete,
              title: 'Delete account',
              onTap: () async {
                final confirmed = await showDeleteConfirmation(context);
                if (confirmed == true) {
                  setState(() => isDeleting = true);
                  final success = await _authService.deleteUserFromSupabase();
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

            // Edit profile tile
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
                onPressed: isLoggingOut
                    ? null
                    : () async {
                        setState(() => isLoggingOut = true);

                        try {
                          await Supabase.instance.client.auth.signOut();
                          ref.invalidate(futureProfileProvider);

                          if (mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginPage(),
                              ),
                              (route) => false,
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to log out: $e')),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => isLoggingOut = false);
                        }
                      },
                child: isLoggingOut
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      )
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

Widget _buildProfileCard({
  required IconData leadingIcon,
  required String title,
  required VoidCallback onTap,
  required bool isDark,
  IconData? trailingIcon,
  String? subtitle,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
      child: SizedBox(
        height: 76,
        child: Card(
          elevation: 3,
          color: isDark ? Colors.grey[900] : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          shadowColor: isDark ? Colors.grey[600] : Colors.grey[900],
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            leading: Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.deepOrange[100],
              ),
              child: Icon(leadingIcon, color: Colors.deepOrangeAccent),
            ),
            title: Text(
              title,
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            subtitle: subtitle != null ? Text(subtitle) : null,
            trailing: Icon(trailingIcon),
          ),
        ),
      ),
    ),
  );
}
