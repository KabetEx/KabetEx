import 'package:supabase_flutter/supabase_flutter.dart';

class ReportServices {
  final _user = Supabase.instance.client.auth.currentUser;
  final _supabase = Supabase.instance.client;

  //send report
  Future<void> sendReport(
    String message,
    String suggestions,
    String reportType,
  ) async {
    try {
      await _supabase.from('reports').insert({
        'reporter': _user?.id ?? 'GUEST',
        'report_type': reportType,
        'message': message,
        'suggestions': suggestions,
      });
      print('reported');
    } catch (e) {
      print('Error reporting : $e');
      rethrow;
    }
  }
}
