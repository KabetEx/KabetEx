import 'package:flutter/material.dart';
import 'package:kabetex/custom%20widgets/theme/gradient_container.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const MyGradientContainer(child: Text('Profile Page')),
      ),
    );
  }
}
