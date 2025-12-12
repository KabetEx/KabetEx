import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GithubStyleBottomBar extends StatefulWidget {
  final Function(int) onTap;
  final int currentIndex;
  final bool isDarkMode;

  const GithubStyleBottomBar({
    super.key,
    required this.onTap,
    required this.currentIndex,
    required this.isDarkMode,
  });

  @override
  State<GithubStyleBottomBar> createState() => _GithubStyleBottomBarState();
}

class _GithubStyleBottomBarState extends State<GithubStyleBottomBar> {
  final List<IconData> icons = [
    CupertinoIcons.home,
    CupertinoIcons.group_solid,
    CupertinoIcons.profile_circled,
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 86,
      decoration: const BoxDecoration(color: Colors.transparent),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(icons.length, (index) {
          final isSelected = widget.currentIndex == index;
          return Column(
            children: [
              GestureDetector(
                onTap: () => widget.onTap(index),
                child: AnimatedContainer(
                  width: 52,
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? isSelected
                              ? Colors.grey[900]
                              : Colors.transparent
                        : isSelected
                        ? Colors.black12
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    icons[index],
                    size: 24,
                    color: isSelected
                        ? Colors.deepOrange
                        : (isDarkMode ? Colors.white70 : Colors.black54),
                  ),
                ),
              ),

              //text indicator
              const SizedBox(height: 4),
              Text(
                index == 0
                    ? 'Home'
                    : index == 1
                    ? 'Community'
                    : 'Account',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontSize: 12,
                  color: isSelected
                      ? Colors.deepOrange
                      : (isDarkMode ? Colors.white70 : Colors.black54),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
