import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:kabetex/features/search/search_page.dart';
import 'package:kabetex/providers/theme_provider.dart';
import 'package:kabetex/features/auth/data/auth_services.dart';

class AppTitleRow extends ConsumerStatefulWidget {
  const AppTitleRow({super.key});

  @override
  ConsumerState<AppTitleRow> createState() => _AppTitleRowState();
}

class _AppTitleRowState extends ConsumerState<AppTitleRow> {
  String? firstName = '';

  @override
  void initState() {
    super.initState();
    loadUserName();
  }

  //capitalize name
  String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  void loadUserName() async {
    final profile = await AuthService().getProfile();

    if (profile != null) {
      final fullName = profile['full_name'] ?? '';
      final first = fullName.split(' ').first;

      setState(() {
        firstName = capitalize(first);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2),
      child: Column(
        children: [
          //first row
          Padding(
            padding: const EdgeInsets.only(
              top: 2,
              right: 8,
              left: 8,
              bottom: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                //menu icon
                GestureDetector(
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: Icon(
                    Icons.menu_rounded,
                    size: 35,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),

                const Spacer(),

                //theme switch
                Row(
                  children: [
                    //search Icon
                    IconButton(
                      icon: Icon(
                        Icons.search_outlined,
                        size: 28,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SearchPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    FlutterSwitch(
                      value: isDarkMode,
                      width: 60,
                      height: 35,
                      //inactive
                      inactiveColor: isDarkMode
                          ? Colors.white
                          : Theme.of(context).colorScheme.secondaryContainer,
                      inactiveIcon: const Icon(
                        Icons.wb_sunny,
                        color: Colors.yellow,
                      ),
                      inactiveToggleColor: isDarkMode
                          ? Colors.black
                          : Colors.black,
                      inactiveSwitchBorder: isDarkMode
                          ? Border.all(color: Colors.grey, width: 1.5)
                          : Border.all(color: Colors.grey, width: 1.5),

                      //active
                      activeIcon: const Icon(
                        Icons.nightlight_round,
                        color: Colors.black,
                      ),
                      activeColor: isDarkMode
                          ? const Color.fromARGB(255, 66, 60, 51)
                          : Theme.of(context).colorScheme.primaryContainer,

                      onToggle: (newval) {
                        ref.read(isDarkModeProvider.notifier).state = newval;
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          //2nd row
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Hello ',
                          style: Theme.of(context).textTheme.titleSmall!
                              .copyWith(
                                color: isDarkMode
                                    ? Colors.deepOrange
                                    : Colors.black,
                                fontWeight: FontWeight.w400,
                              ),
                        ),
                        TextSpan(
                          text: firstName!.isEmpty ? 'guest' : firstName,
                          style: Theme.of(context).textTheme.titleSmall!
                              .copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDarkMode
                                    ? Colors.deepOrange
                                    : Colors.black,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Lets shop!',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.grey : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
