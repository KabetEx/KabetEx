import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/custom%20widgets/theme/gradient_container.dart';
import 'package:kabetex/providers/theme_provider.dart';

class Mydrawer extends ConsumerStatefulWidget {
  const Mydrawer({super.key});

  @override
  ConsumerState<Mydrawer> createState() => _MydrawerState();
}

class _MydrawerState extends ConsumerState<Mydrawer> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Drawer(
      backgroundColor: isDarkMode
          ? Theme.of(context).colorScheme.primary
          : Colors.orange,
      child: MyGradientContainer(
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person_rounded,
                        size: 40,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'JohnDoe@gmail.com',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isDarkMode ? Colors.white : Colors.black,
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
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
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
                'Add products',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
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
                'My products',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
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
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
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
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isDarkMode ? Colors.white : Colors.black,
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
              leading: Icon(
                Icons.logout_rounded,
                color: isDarkMode
                    ? Colors.white
                    : Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              title: Text(
                'SIGN OUT',
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
