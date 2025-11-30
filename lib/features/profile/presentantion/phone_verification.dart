import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PhoneVerificationPage extends StatefulWidget {
  final String phoneNumber;
  final VoidCallback onVerified;

  const PhoneVerificationPage({
    super.key,
    required this.phoneNumber,
    required this.onVerified,
  });

  @override
  State<PhoneVerificationPage> createState() => _PhoneVerificationPageState();
}

class _PhoneVerificationPageState extends State<PhoneVerificationPage> {
  final _otpController = TextEditingController();
  bool isSending = false;
  bool isVerifying = false;

  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    sendOTP();
  }

  Future<void> sendOTP() async {
    setState(() => isSending = true);
    try {
      await _supabase.auth.signInWithOtp(phone: widget.phoneNumber);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP sent! Check your messages.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send OTP: $e')));
    } finally {
      setState(() => isSending = false);
    }
  }

  Future<void> verifyOTP() async {
    if (_otpController.text.isEmpty) return;

    setState(() => isVerifying = true);
    try {
      final res = await _supabase.auth.verifyOTP(
        phone: widget.phoneNumber,
        token: _otpController.text,
        type: OtpType.signup, // or login depending on Supabase
      );

      if (res.user != null) {
        // Mark as verified in your profile table
        await _supabase
            .from('profiles')
            .update({
              'isVerified': true,
            })
            .eq('id', _supabase.auth.currentUser!.id);

        //onverified callback
        widget.onVerified();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP verification failed.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isVerifying = false);
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Phone')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text('Enter the OTP sent to ${widget.phoneNumber}'),
            const SizedBox(height: 16),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'OTP',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isVerifying ? null : verifyOTP,
              child: isVerifying
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Verify'),
            ),
            TextButton(
              onPressed: isSending ? null : sendOTP,
              child: isSending
                  ? const CircularProgressIndicator()
                  : const Text('Resend OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
