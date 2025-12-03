import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/common/slide_routing.dart';
import 'package:kabetex/features/1community/providers/user_provider.dart';
import 'package:kabetex/features/auth/presentation/login.dart';
import 'package:kabetex/features/settings/presentations/settings_page.dart';
import 'package:kabetex/providers/theme_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyCommunityDrawer extends ConsumerStatefulWidget {
  const MyCommunityDrawer({super.key});

  @override
  ConsumerState<MyCommunityDrawer> createState() => _MyCommunityDrawerState();
}

class _MyCommunityDrawerState extends ConsumerState<MyCommunityDrawer> {
  final user = Supabase.instance.client.auth.currentUser;
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);
    final userProfileAsync = ref.watch(currentUserProvider);

    return Drawer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isDark
              ? Colors.black
              : Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            right: BorderSide(color: Colors.grey[700]!, width: 0.6),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------------------------------------
            //  HEADER with fixed height
            // ------------------------------------------
            user == null
                ? SizedBox(
                    height: 190,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.person_crop_circle,
                            size: 60,
                            color: isDark ? Colors.white : Colors.grey[700],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Guest",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Sign in to access more features",
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SizedBox(
                    height: 190,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 35, 20, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CircleAvatar(
                            radius: 32,
                            backgroundImage: NetworkImage(
                              'https://i.pravatar.cc/150?img=3',
                            ),
                          ),
                          const SizedBox(height: 12),

                          userProfileAsync.when(
                            data: (user) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.name ?? 'loading...',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    "${user?.year ?? ' '},  BCom",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[700],
                                    ),
                                  ),
                                ],
                              );
                            },
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (error, stackTrace) =>
                                const Text('Error loading name'),
                          ),
                        ],
                      ),
                    ),
                  ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(
                thickness: 0.7,
                color: isDark ? Colors.grey[800] : Colors.grey[700],
                height: 0,
              ),
            ),

            const SizedBox(height: 10),

            // ------------------------------------------
            // LIST TILES WITH X-LIKE PADDING
            // ------------------------------------------
            Expanded(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 6,
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        CupertinoIcons.house,
                        size: 26,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      title: Text(
                        "Home Feed",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 6,
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        CupertinoIcons.doc_text,
                        size: 26,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      title: Text(
                        "My Posts",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 6,
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        CupertinoIcons.gear,
                        size: 26,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      title: Text(
                        "Settings",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          SlideRouting(page: const SettingsPage()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ------------------------------------------
            // LOGOUT + FOOTER
            // ------------------------------------------
            Divider(
              thickness: 0.7,
              color: isDark ? Colors.grey[800] : Colors.grey[300],
              height: 0,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: user != null
                    ? Icon(
                        CupertinoIcons.arrow_right_square,
                        size: 26,
                        color: isDark ? Colors.white : Colors.black,
                      )
                    : Icon(
                        CupertinoIcons.profile_circled,
                        size: 26,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                title: user != null
                    ? Text(
                        "Logout",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: isDark ? Colors.deepOrange : Colors.black,
                        ),
                      )
                    : Text(
                        "Sign In",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                onTap: () async {
                  user == null
                      ? Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                const LoginPage(),
                          ),
                          (Route<dynamic> route) => false,
                        )
                      : {
                          await supabase.auth.signOut(),
                          ref.invalidate(currentUserProvider),
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                            (route) => false,
                          ),
                        };
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 16),
              child: Text(
                "© 2025 KabetEx",
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
