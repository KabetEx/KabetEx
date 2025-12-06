import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/1community/data/community_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
  
final communityRepoProvider = Provider(
  (ref) => CommunityRepository(client: Supabase.instance.client),
);
