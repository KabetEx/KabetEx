import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/common/slide_routing.dart';
import 'package:kabetex/features/1community/providers/user_provider.dart';
import 'package:kabetex/features/auth/presentation/login.dart';
import 'package:kabetex/features/contact_report/presentation/report_page.dart';
import 'package:kabetex/features/products/presentation/upload_page.dart';
import 'package:kabetex/features/products/presentation/my_products_page.dart';
import 'package:kabetex/features/settings/presentations/settings_page.dart';
import 'package:kabetex/features/products/providers/user_provider.dart';
import 'package:kabetex/providers/theme_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Mydrawer extends ConsumerStatefulWidget {
  const Mydrawer({super.key});

  @override
  ConsumerState<Mydrawer> createState() => _MydrawerState();
}

bool isSelected = false;

class _MydrawerState extends ConsumerState<Mydrawer> {
  bool isSigningOut = false;
  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final user = Supabase.instance.client.auth.currentUser;

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.grey[900]
                      : Theme.of(context).scaffoldBackgroundColor,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.deepOrange,
                      child: Text(
                        'K', // Could be user initial
                        style: TextStyle(
                          fontFamily: 'Oswalds',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'KabetEx',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          '- Where deals happen',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            //LIST TILES
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  //HOME tile
                  MyListTile(
                    leadingIcon: CupertinoIcons.home,
                    text: 'Home',
                    onTap: () async {
                      setState(() {
                        isSelected = true;
                      });
                      // Navigator.pop(context);
                      await Future.delayed(Durations.medium4);
                      setState(() {
                        isSelected = false;
                      });
                    },
                    isDark: isDarkMode,
                  ),

                  //settings
                  MyListTile(
                    leadingIcon: CupertinoIcons.settings,
                    text: 'Settings',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        SlideRouting(page: const SettingsPage()),
                      );
                    },
                    isDark: isDarkMode,
                  ),

                  //seller's section
                  const Divider(),

                  sectionHeader(context, isDarkMode, 'Seller\'s Section'),

                  MyListTile(
                    leadingIcon: CupertinoIcons.add,
                    text: 'Upload',
                    onTap: () async {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const PostProductPage();
                          },
                        ),
                      );
                    },
                    isDark: isDarkMode,
                  ),

                  MyListTile(
                    leadingIcon: CupertinoIcons.list_bullet,
                    text: 'My listings',
                    onTap: () {
                      Navigator.pop(context);
                      Future.delayed(
                        const Duration(microseconds: 500),
                        () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const MyProductsPage();
                              },
                            ),
                          );
                        },
                      );
                    },
                    isDark: isDarkMode,
                  ),

                  //feedback section
                  const Divider(),
                  sectionHeader(context, isDarkMode, 'Feedback & support'),

                  MyListTile(
                    leadingIcon: CupertinoIcons.book,
                    text: 'Report a problem',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        SlideRouting(page: const ReportPage()),
                      );
                    },
                    isDark: isDarkMode,
                  ),

                  MyListTile(
                    leadingIcon: CupertinoIcons.phone,
                    text: 'Contact Us',
                    onTap: () {
                      Navigator.pop(context);
                    },
                    isDark: isDarkMode,
                  ),
                ],
              ),
            ),

            const Spacer(),

            //sign out
            const Divider(),
            ListTile(
              leading: user == null
                  ? const Icon(
                      CupertinoIcons.person_crop_circle_badge_plus,
                      color: Colors.green,
                    )
                  : Icon(
                      CupertinoIcons.arrow_left_circle,
                      color: isDarkMode
                          ? Colors.white
                          : Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
              title: isSigningOut
                  ? SizedBox(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: isDarkMode ? Colors.white : Colors.black,
                          strokeWidth: 1,
                        ),
                      ),
                    )
                  : user == null
                  ? Text(
                      'Log in',
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: Colors.green,
                        fontFamily: 'Roboto',
                      ),
                    )
                  : Text(
                      'Sign Out',
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: Colors.red,
                        fontFamily: 'Roboto',
                      ),
                    ),
              onTap: () async {
                //user is logged in - signout
                if (user != null) {
                  setState(() => isSigningOut = true);

                  await Supabase.instance.client.auth.signOut();
                  if (mounted) ref.invalidate(userByIDProvider(user.id));

                  if (!mounted) return; // safety check

                  setState(() => isSigningOut = false);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget sectionHeader(BuildContext context, bool isDarkMode, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
        child: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontSize: 15,
            color: isDarkMode
                ? Colors.white
                : Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class MyListTile extends StatelessWidget {
  const MyListTile({
    super.key,
    required this.leadingIcon,
    required this.text,
    required this.onTap,
    required this.isDark,
  });
  final IconData leadingIcon;
  final String text;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(leadingIcon, color: isDark ? Colors.white38 : Colors.black),
      title: Text(
        text,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
          fontWeight: isDark ? FontWeight.w200 : FontWeight.w400,
          fontSize: 18,
          color: isDark ? Colors.white : Colors.black,
          fontFamily: 'Quicksand',
        ),
      ),
      onTap: onTap,
    );
  }
}
