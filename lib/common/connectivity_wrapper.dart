import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;

  const ConnectivityWrapper({super.key, required this.child});

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  bool isOnline = true;

  @override
  void initState() {
    super.initState();
    // check initial connectivity
    Connectivity().checkConnectivity().then((status) {
      setState(() {
        isOnline = status != ConnectivityResult.none;
      });
    });
    // listen to connectivity changes
    Connectivity().onConnectivityChanged.listen((status) {
      setState(() {
        isOnline = status != ConnectivityResult.none;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isOnline) {
      return const Center(
        child: Text(
          'No Internet Connection 😞',
          style: TextStyle(fontSize: 18),
        ),
      );
    }
    return widget.child;
  }
}
