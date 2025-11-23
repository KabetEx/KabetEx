import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kabetex/providers/theme_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Settings page',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: const IconThemeData(
          color: Colors.deepOrange, // changes back arrow color
          size: 28, // optional: change size
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 4),
            child: Text(
              'Theme Prefrences',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: isDarkMode ? Colors.grey : Colors.black,
                fontSize: 18,
              ),
            ),
          ),

          ListTile(
            leading: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: Colors.orange,
            ),
            title: Text(
              'Dark Mode',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: 18,
              ),
            ),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (val) async {
                ref.read(isDarkModeProvider.notifier).state = val;

                // persist to Hive
                final box = Hive.box('settings');
                await box.put('isDarkMode', val);
              },
            ),
          ),
        ],
      ),
    );
  }
}
