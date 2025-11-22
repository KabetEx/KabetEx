import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/common/slide_routing.dart';
import 'package:kabetex/features/profile_page/data/profile_services.dart';
import 'package:kabetex/features/profile_page/presentantion/edit_profile.dart';
import 'package:kabetex/features/profile_page/widgets/not_logged_In.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _user = Supabase.instance.client.auth.currentUser;
  final _profileService = ProfileServices();

  bool get isLoggedIn => _user != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My profile'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 165, 55, 21),
      ),
      bottomNavigationBar: isLoggedIn
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 165, 55, 21),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  'Log Out',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          : null,
      body: isLoggedIn
          ? Column(
              children: [
                //top container
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 165, 55, 21),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    //crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        backgroundImage: AssetImage(
                          'assets/images/avatar1.png',
                        ),
                        radius: 32,
                      ), // to be worked on later...
                      const SizedBox(height: 16),

                      Text(
                        'Email...',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    splashColor: Colors.grey,
                    child: ListTile(
                      title: Text(
                        'Edit profile',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      leading: const Icon(
                        Icons.supervised_user_circle,
                        color: Colors.white,
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_outlined,
                        color: Colors.white,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          SlideRouting(page: const EditProfilePage()),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    splashColor: Colors.grey,
                    child: ListTile(
                      title: Text(
                        'Delete account',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      leading: const Icon(Icons.delete, color: Colors.white),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_outlined,
                        color: Colors.white,
                      ),
                      onTap: () {
                        //show dialog to confirm account deletion
                      },
                    ),
                  ),
                ),

                const Spacer(),
              ],
            )
          : const NotLoggedIn(),
    );
  }
}
