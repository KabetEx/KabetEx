import 'package:flutter/material.dart';

class CommunityProfilePage extends StatefulWidget {
  const CommunityProfilePage({super.key});

  @override
  State<CommunityProfilePage> createState() => _CommunityProfilePageState();
}

class _CommunityProfilePageState extends State<CommunityProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Profile')));
  }
}
