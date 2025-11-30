import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kabetex/features/search/presentation/search_page.dart';
import 'package:kabetex/features/products/providers/user_provider.dart';
import 'package:kabetex/providers/theme_provider.dart';

class AppTitleRow extends ConsumerWidget {
  const AppTitleRow({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final asyncProfile = ref.watch(futureProfileProvider);

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
                Builder(
                  builder: (context) {
                    return GestureDetector(
                      onTap: () {
                        Scaffold.of(context).openDrawer();
                      },
                      child: Icon(
                        Icons.menu_rounded,
                        size: 35,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    );
                  },
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
                          : Theme.of(context).scaffoldBackgroundColor,
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
                          : Theme.of(context).scaffoldBackgroundColor,

                      onToggle: (val) async {
                        ref.read(isDarkModeProvider.notifier).state = val;

                        // persist to Hive
                        final box = Hive.box('settings');
                        await box.put('isDarkMode', val);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          //2nd row
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 32,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Hello ',
                            style: Theme.of(context).textTheme.bodyLarge!
                                .copyWith(
                                  color: isDarkMode
                                      ? Colors.deepOrange
                                      : Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 20,
                                  fontFamily: 'Roboto', // Clean and reliable
                                ),
                          ),
                          asyncProfile.when(
                            loading: () => const TextSpan(
                              text: '...',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            data: (data) {
                              if (data == null || data.isEmpty) {
                                return const TextSpan(
                                  text: '...',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              }

                              final fullName =
                                  data['full_name']?.toString() ?? '';
                              final email = data['email']?.toString();

                              String displayName;
                              if (fullName.trim().isNotEmpty) {
                                displayName = fullName.trim().split(' ')[0];
                              } else if (email != null && email.isNotEmpty) {
                                displayName = email.split('@')[0];
                              } else {
                                displayName = 'Guest';
                              }

                              return TextSpan(
                                text: displayName,
                                style: TextStyle(
                                  fontWeight: FontWeight
                                      .w600, // Slightly bolder than "Hello"
                                  fontSize: 20,
                                  color: isDarkMode
                                      ? Colors.deepOrange
                                      : Colors.black,
                                  fontFamily: 'Poppins', // Warm and friendly
                                  height: 1.1,
                                ),
                              );
                            },
                            error: (e, st) => const TextSpan(
                              text: '...',
                              style: TextStyle(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    'Lets shop!',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: isDarkMode ? Colors.grey : Colors.black,
                      fontFamily: 'lato',
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
