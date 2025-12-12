import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/common/slide_routing.dart';
import 'package:kabetex/features/auth/providers/auth_provider.dart';
import 'package:kabetex/utils/snackbars.dart';
import 'package:kabetex/features/1community/presentation/pages/profile_page.dart';
import 'package:kabetex/features/auth/providers/user_provider.dart';
import 'package:kabetex/features/auth/presentation/login.dart';
import 'package:kabetex/features/home/providers/nav_bar.dart';
import 'package:kabetex/features/settings/presentations/settings_page.dart';
import 'package:kabetex/providers/theme_provider.dart';
import 'package:shimmer/shimmer.dart';
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
    final userProfileAsync = ref.watch(userByIDProvider(user?.id));

    return SafeArea(
      child: Drawer(
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
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 32,
                      ),
                      child: userProfileAsync.when(
                        data: (user) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundImage: CachedNetworkImageProvider(
                                  user!.avatarUrl,
                                ),
                              ),
                              const SizedBox(height: 12),

                              Text(
                                user.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                "${user.year},  BCom",
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
                        loading: () => Shimmer.fromColors(
                          baseColor: isDark
                              ? Colors.grey[800]!
                              : Colors.grey[400]!,
                          highlightColor: isDark
                              ? Colors.grey[600]!
                              : Colors.grey[400]!,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //avatar
                              Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark
                                      ? Colors.grey[600]!
                                      : Colors.grey[400]!,
                                ),
                              ),
                              const SizedBox(height: 10),

                              //name
                              Container(
                                height: 24,
                                width: 140,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.grey[600]!
                                      : Colors.grey[400]!,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              const SizedBox(height: 8),

                              //details
                              Container(
                                height: 24,
                                width: 100,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.grey[600]!
                                      : Colors.grey[400]!,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        error: (error, stackTrace) => const Center(
                          child: Text('Error fetching details🥲'),
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
              // LIST TILES
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

                    //profile
                    user == null
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 6,
                            ),
                            child: ListTile(
                              enabled: userProfileAsync.hasValue,
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                CupertinoIcons.person,
                                size: 26,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              title: Text(
                                "Profile",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              onTap: () {
                                userProfileAsync.when(
                                  data: (userProfile) {
                                    Navigator.push(
                                      context,
                                      SlideRouting(
                                        page: CommunityProfilePage(
                                          userID: user!.id,
                                        ),
                                      ),
                                    );
                                  },
                                  loading: () {
                                    // Optional: show a snackbar or loading indicator
                                    return const CircularProgressIndicator();
                                  },
                                  error: (error, stack) {
                                    // Optional: show an error message
                                    FailureSnackBar.show(
                                      context: context,
                                      message: 'Failure fetching profile',
                                      isDark: isDark,
                                    );
                                  },
                                );
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Divider(
                  thickness: 0.7,
                  color: isDark ? Colors.grey[800] : Colors.grey[700],
                  height: 0,
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),
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
                    //no logged in user => loginPage
                    if (user == null) {
                      if (mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                const LoginPage(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                        await Future.delayed(Durations.medium2);

                        ref.read(tabsProvider.notifier).state = 0;
                      }
                    } else {
                      //sign out
                      if (mounted) {
                        await supabase.auth.signOut();

                        ref.invalidate(authStateProvider);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Navigator.pop(context);
                        });
                      }
                    }
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
      ),
    );
  }
}
