import 'package:riverpod/legacy.dart';

//hme top tab
final homeTopTabProvider = StateProvider<int>((ref) => 0);

// providers.dart
final tabsProvider = StateProvider<int>((ref) => 0);

final isCommunityLoadingProvider = StateProvider<bool>((ref) => false);

final isLoadingMarketprovider = StateProvider<bool>((ref) => false);
