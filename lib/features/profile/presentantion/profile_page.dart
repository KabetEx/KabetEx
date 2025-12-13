import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/common/slide_routing.dart';
import 'package:kabetex/features/1community/presentation/pages/edit_profile_page.dart';
import 'package:kabetex/features/auth/presentation/login.dart';
import 'package:kabetex/features/auth/providers/auth_provider.dart';
import 'package:kabetex/features/profile/presentantion/change_password.dart';
import 'package:kabetex/features/profile/presentantion/phone_verification.dart';
import 'package:kabetex/features/profile/widgets/not_logged_In.dart';
import 'package:kabetex/features/auth/providers/user_provider.dart';
import 'package:kabetex/providers/theme_provider.dart';
import 'package:kabetex/utils/snackbars.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kabetex/features/auth/data/auth_services.dart';

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key});

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  final _authService = AuthService();
  bool isLoggingOut = false;
  bool isDeleting = false;

  Future<bool?> confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text("Are you sure? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);
    final userID = ref.watch(currentUserIdProvider);
    final profileAsync = ref.watch(userByIDProvider(userID));

    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) return const NotLoggedIn();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Account',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ============================================
              // USER CARD — Clean, top, always visible
              // ============================================
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                child: profileAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, st) => const Text("Error loading profile"),
                  data: (data) {
                    if (data == null) return const Text("Profile not found");

                    return Column(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: CachedNetworkImageProvider(
                            data.avatarUrl,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // User name
                        Text(
                          data.name,
                          style: Theme.of(context).textTheme.bodyLarge!
                              .copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                        ),
                        const SizedBox(height: 8),

                        // Verified badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: data.isVerified
                                ? Colors.green
                                : Colors.orange.shade700,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            data.isVerified
                                ? "Verified Seller"
                                : "Not Verified",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),

                        // Verify button
                        if (!data.isVerified)
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                SlideRouting(
                                  page: PhoneVerificationPage(
                                    phoneNumber: data.pNumber,
                                    onVerified: () =>
                                        ref.refresh(userByIDProvider(userID)),
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              "Verify Now",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),

              const Divider(),

              // ============================================
              // ACCOUNT SECTION – Edit profile etc.
              // ============================================
              _sectionTitle("ACCOUNT", isDark),

              _settingTile(
                icon: CupertinoIcons.person_circle,
                title: "Edit Profile",
                context: context,
                onTap: () {
                  profileAsync.whenData(
                    (value) => Navigator.push(
                      context,
                      SlideRouting(
                        page: CommunityEditProfilePage(
                          user: profileAsync.value!,
                        ),
                      ),
                    ),
                  );
                },
              ),

              // ============================================
              // SECURITY
              // ============================================
              _sectionTitle("SECURITY", isDark),
              _settingTile(
                icon: CupertinoIcons.lock_fill,
                title: "Change Password",
                context: context,
                onTap: () {
                  if (!mounted) return;
                  Navigator.push(
                    context,
                    SlideRouting(page: const ChangePasswordPage()),
                  );
                },
              ),

              // ============================================
              // DELETE ACCOUNT
              // ============================================
              _sectionTitle("DANGER ZONE", isDark),
              _settingTile(
                icon: CupertinoIcons.delete,
                title: "Delete Account",
                context: context,
                color: Colors.red,
                onTap: () async {
                  if (!mounted) return;

                  final sure = await confirmDelete(context);
                  if (sure == true) {
                    setState(() => isDeleting = true);

                    final ok = await _authService.deleteUserFromSupabase();
                    if (ok) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                        (_) => false,
                      );

                      await Supabase.instance.client.auth.signOut();

                      //invalidate user provider
                      ref.invalidate(currentUserIdProvider);
                    }

                    setState(() => isDeleting = false);
                  }
                },
              ),

              // ============================================
              // LOGOUT BUTTON
              // ============================================
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Colors.deepOrange,
                  ),
                  onPressed: isLoggingOut
                      ? null
                      : () async {
                          setState(() => isLoggingOut = true);

                          try {
                            await Supabase.instance.client.auth.signOut();

                            if (!mounted) return;

                            //invalidate user provider
                            ref.invalidate(authStateProvider);
                            ref.invalidate(currentUserIdProvider);
                          } catch (_) {
                            FailureSnackBar.show(
                              context: context,
                              message: 'Failed to sign out, please try again',
                              isDark: isDark,
                            );
                          } finally {
                            setState(() => isLoggingOut = false);
                          }
                        },
                  child: isLoggingOut
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Log Out",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Helpers
  // ============================================================

  Widget _sectionTitle(String title, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.grey[700],
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _settingTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color ?? Colors.deepOrange),
      title: Text(title),
      trailing: const Icon(CupertinoIcons.chevron_right),
    );
  }
}
