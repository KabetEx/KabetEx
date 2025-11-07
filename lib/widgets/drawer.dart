import 'package:flutter/material.dart';

class Mydrawer extends StatefulWidget {
  const Mydrawer({super.key});

  @override
  State<Mydrawer> createState() => _MydrawerState();
}

class _MydrawerState extends State<Mydrawer> {
  bool get isLightMode {
    return Theme.of(context).brightness == Brightness.light;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: isLightMode
          ? Theme.of(context).colorScheme.primary
          : const Color.fromARGB(255, 65, 64, 64),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: isLightMode
                    ? Theme.of(context).colorScheme.primary
                    : Colors.black,
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
              color: isLightMode ? Colors.black : Colors.white,
            ),
            title: Text(
              'HOME',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isLightMode ? Colors.black : Colors.white,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.category_outlined,
              color: isLightMode ? Colors.black : Colors.white,
            ),
            title: Text(
              'CART',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isLightMode ? Colors.black : Colors.white,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.person_rounded,
              color: isLightMode ? Colors.black : Colors.white,
            ),
            title: Text(
              'EXPLORE CATEGORIES',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isLightMode ? Colors.black : Colors.white,
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
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isLightMode ? Colors.black : Colors.white,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add_box_rounded, color: Colors.green),
            title: Text(
              'ADD PRODUCT',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isLightMode ? Colors.black : Colors.white,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.list_rounded, color: Colors.green),
            title: Text(
              'MY PRODUCTS',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isLightMode ? Colors.black : Colors.white,
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
            leading: const Icon(Icons.logout_rounded),
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
    );
  }
}
