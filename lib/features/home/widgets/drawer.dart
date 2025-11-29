import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/common/slide_routing.dart';
import 'package:kabetex/features/auth/presentation/login.dart';
import 'package:kabetex/features/contact_report/presentation/report_page.dart';
import 'package:kabetex/features/products/presentation/post_product_page.dart';
import 'package:kabetex/features/products/presentation/my_products_page.dart';
import 'package:kabetex/features/settings/presentations/settings_page.dart';
import 'package:kabetex/features/products/providers/user_provider.dart';
import 'package:kabetex/providers/theme_provider.dart';
import 'package:kabetex/features/auth/data/auth_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Mydrawer extends ConsumerStatefulWidget {
  const Mydrawer({super.key});

  @override
  ConsumerState<Mydrawer> createState() => _MydrawerState();
}

class _MydrawerState extends ConsumerState<Mydrawer> {
  bool isSigningOut = false;
  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final authService = AuthService();
    final user = Supabase.instance.client.auth.currentUser;

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.black
              : const Color.fromARGB(255, 237, 228, 225),
        ),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color.fromARGB(255, 108, 103, 101)
                      : Colors.deepOrange,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'KabetEx \n',
                            style: Theme.of(context).textTheme.titleMedium!
                                .copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 32,
                                  fontFamily: 'poppins',
                                ),
                          ),
                          TextSpan(
                            text: '-Where deals are made',
                            style: Theme.of(context).textTheme.bodyLarge!
                                .copyWith(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            //all user's section
            //menu items
            ListTile(
              leading: Icon(
                Icons.home_work_outlined,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              title: Text(
                'Home',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontFamily: 'Quicksand',
                ),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            //settings
            ListTile(
              leading: Icon(
                Icons.settings,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              title: Text(
                'Settings',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontFamily: 'Quicksand',
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),

            //seller's section
            const Divider(),

            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8,
                ),
                child: Text(
                  'Seller\'s Section',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontSize: 15,
                    color: isDarkMode
                        ? Colors.white
                        : Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.add_box_outlined,
                color: isDarkMode
                    ? Colors.white
                    : Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              title: Text(
                'Upload ',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontFamily: 'Quicksand',
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                Future.delayed(const Duration(microseconds: 500), () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const PostProductPage();
                      },
                    ),
                  );
                });
              },
            ),
            ListTile(
              leading: Icon(
                Icons.list_rounded,
                color: isDarkMode
                    ? Colors.white
                    : Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              title: Text(
                'My listings',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontFamily: 'Quicksand',
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Future.delayed(const Duration(microseconds: 500), () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const MyProductsPage();
                      },
                    ),
                  );
                });
              },
            ),

            //feedback section
            const Divider(),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8,
                ),
                child: Text(
                  'Feedback & support',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontSize: 15,
                    color: isDarkMode
                        ? Colors.white
                        : Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.note_alt_outlined,
                color: isDarkMode
                    ? Colors.white
                    : Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              title: Text(
                'Report a problem',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontFamily: 'Quicksand',
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, SlideRouting(page: const ReportPage()));
              },
            ),

            ListTile(
              leading: Icon(
                Icons.contact_page_outlined,
                color: isDarkMode
                    ? Colors.white
                    : Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              title: Text(
                'Contact us',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontFamily: 'Quicksand',
                ),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Spacer(),

            //sign out
            const Divider(),
            ListTile(
              leading: user == null
                  ? const Icon(Icons.supervised_user_circle_rounded)
                  : Icon(
                      Icons.logout_rounded,
                      color: isDarkMode
                          ? Colors.white
                          : Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
              title: isSigningOut
                  ? const SizedBox(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 1,
                        ),
                      ),
                    )
                  : user == null
                  ? Text(
                      'Log in',
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.green,
                        fontFamily: 'roboto',
                      ),
                    )
                  : Text(
                      'SIGN OUT',
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: Colors.red,
                        fontFamily: 'Quicksand',
                      ),
                    ),
              onTap: () async {
                //user is logged in - signout
                if (user != null) {
                  setState(() => isSigningOut = true);
                  await Supabase.instance.client.auth.signOut();

                  if (!mounted) return; // safety check

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false, // remove all previous pages
                  );
                  setState(() => isSigningOut = false);

                  if (mounted) ref.invalidate(futureProfileProvider);
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                  ref.invalidate(futureProfileProvider);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
